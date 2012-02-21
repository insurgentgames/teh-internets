//
//  MPOAuthAPIRequestLoader.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPOAuthConnection.h"
#import "MPOAuthCredentialStore.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPURLRequestParameter.h"
#import "NSURLResponse+Encoding.h"
#import "MPDebug.h"
#import "OpenFeint+Private.h"
#import "OFActionRequest.h"

NSString *MPOAuthNotificationRequestTokenReceived	= @"MPOAuthNotificationRequestTokenReceived";
NSString *MPOAuthNotificationAccessTokenReceived	= @"MPOAuthNotificationAccessTokenReceived";
NSString *MPOAuthNotificationAccessTokenRefreshed	= @"MPOAuthNotificationAccessTokenRefreshed";
NSString *MPOAuthNotificationOAuthCredentialsReady	= @"MPOAuthNotificationOAuthCredentialsReady";
NSString *MPOAuthNotificationErrorHasOccurred		= @"MPOAuthNotificationErrorHasOccurred";


@interface MPOAuthURLResponse ()
@property (nonatomic, readwrite, retain) NSURLResponse *urlResponse;
@property (nonatomic, readwrite, retain) NSDictionary *oauthParameters;
@end


@interface MPOAuthAPIRequestLoader ()
@property (nonatomic, readwrite, retain) NSData *data;
@property (nonatomic, readwrite, retain) NSString *responseString;

- (void)_interrogateResponseForOAuthData;
@end

@protocol MPOAuthAPIInternalClient;

@implementation MPOAuthAPIRequestLoader

- (id)initWithURL:(NSURL *)inURL {
	return [self initWithRequest:[[[MPOAuthURLRequest alloc] initWithURL:inURL andParameters:nil] autorelease]];
}

- (id)initWithRequest:(MPOAuthURLRequest *)inRequest {
	self = [super init];
	if (self != nil) {
		self.oauthRequest = inRequest;
		_dataBuffer = [[NSMutableData alloc] init];
	}
	return self;
}

- (oneway void)dealloc {
	[self cancel];
	
	self.credentials = nil;
	self.oauthRequest = nil;
	self.oauthResponse = nil;
	self.data = nil;
	self.responseString = nil;
	self.error = nil;

	[super dealloc];
}

@synthesize error = _error;
@synthesize credentials = _credentials;
@synthesize oauthRequest = _oauthRequest;
@synthesize oauthResponse = _oauthResponse;
@synthesize data = _dataBuffer;
@synthesize responseString = _dataAsString;

#pragma mark -

- (void)setOnSuccess:(const OFDelegate&)onSuccess
{
	_onSuccess = onSuccess;
}

- (void)setOnFailure:(const OFDelegate&)onFailure
{
	_onFailure = onFailure;
}

- (const OFDelegate&)getOnSuccess
{
	return _onSuccess;
}

- (const OFDelegate&)getOnFailure
{
	return _onFailure;
}

- (MPOAuthURLResponse *)oauthResponse {
	if (!_oauthResponse) {
		_oauthResponse = [[MPOAuthURLResponse alloc] init];
	}
	
	return _oauthResponse;
}

- (NSString *)responseString {
	if (!_dataAsString) {
		_dataAsString = [[NSString alloc] initWithData:self.data encoding:[self.oauthResponse.urlResponse encoding]];
	}
	
	return _dataAsString;
}

- (NSURLRequest*)getConfiguredRequest
{
	return [MPOAuthConnection configuredRequest:self.oauthRequest delegate:self credentials:self.credentials];
}

- (void)loadSynchronously:(BOOL)inSynchronous
{
	[_dataBuffer release];		_dataBuffer = [[NSMutableData alloc] init];
	[_oauthResponse release];	_oauthResponse = nil;
	[_dataAsString release];	_dataAsString = nil;	
	[_error release];			_error = nil;

	OFSafeRelease(_activeConnection);
	
	NSAssert(_credentials, @"Unable to load without valid credentials");
	NSAssert(_credentials.consumerKey, @"Unable to load, credentials contain no consumer key");
	
	if (!inSynchronous) {
		_activeConnection = [[MPOAuthConnection connectionWithRequest:self.oauthRequest delegate:self credentials:self.credentials] retain];
	} else {
		MPOAuthURLResponse *theOAuthResponse = nil;
		self.data = [MPOAuthConnection sendSynchronousRequest:self.oauthRequest usingCredentials:self.credentials returningResponse:&theOAuthResponse error:nil];
		self.oauthResponse = theOAuthResponse;
		[self _interrogateResponseForOAuthData];
	}
}

- (void)cancel
{
	if (_activeConnection)
	{
		[_activeConnection cancel];
		OFSafeRelease(_activeConnection);
	}

	_onSuccess = OFDelegate();
	_onFailure = OFDelegate();
}

#pragma mark -

- (void)forceSetData:(NSData*)dataToRetain
{
	[_dataBuffer release];
	_dataBuffer = [dataToRetain retain];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.error = error;

	[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationErrorHasOccurred
														object:nil
													  userInfo:nil];

	_onFailure.invoke(self);

	OFSafeRelease(_activeConnection);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.oauthResponse.urlResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	MPLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_dataBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self _interrogateResponseForOAuthData];

	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.oauthResponse.urlResponse;
	if([httpResponse statusCode] < 200 || [httpResponse statusCode] > 299)
	{
		if([httpResponse statusCode] != OpenFeintHttpStatusCodeForbidden)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationErrorHasOccurred
																object:nil
															  userInfo:nil];
		}
		_onFailure.invoke(self);
	}
	else
	{
		_onSuccess.invoke(self);
	}	

	OFSafeRelease(_activeConnection);
}

#pragma mark -

- (void)_interrogateResponseForOAuthData {
	NSString *response = self.responseString;
	NSDictionary *foundParameters = nil;
	
	if ([response length] > 5 && [[response substringToIndex:5] isEqualToString:@"oauth"]) {
		foundParameters = [MPURLRequestParameter parameterDictionaryFromString:response];
		self.oauthResponse.oauthParameters = foundParameters;
		
		if ([response length] > 13 && [[response substringToIndex:13] isEqualToString:@"oauth_problem"])
		{
			MPLog(@"oauthProblem = %@", foundParameters);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationErrorHasOccurred
																		object:nil
																	  userInfo:foundParameters];		

		}
		else if ([response length] > 11 && [[response substringToIndex:11] isEqualToString:@"oauth_token"]) 
		{
			NSString *aParameterValue = nil;
			MPLog(@"foundParameters = %@", foundParameters);

			if ([foundParameters count] && (aParameterValue = [foundParameters objectForKey:@"oauth_token"])) {
				if (!self.credentials.requestToken && !self.credentials.accessToken) {
					[_credentials setRequestToken:aParameterValue];
					[_credentials setRequestTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationRequestTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (!self.credentials.accessToken && self.credentials.requestToken) {
					[_credentials setRequestToken:nil];
					[_credentials setRequestTokenSecret:nil];
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenReceived
																		object:nil
																	  userInfo:foundParameters];
					
				} else if (self.credentials.accessToken && !self.credentials.requestToken) {
					// replace the current token
					[_credentials setAccessToken:aParameterValue];
					[_credentials setAccessTokenSecret:[foundParameters objectForKey:@"oauth_token_secret"]];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenRefreshed
																		object:nil
																	  userInfo:foundParameters];																  
				}
			}
		}
	}
}

@end
