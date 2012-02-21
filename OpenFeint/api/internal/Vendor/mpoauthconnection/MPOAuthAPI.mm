//
//  MPOAuthAPI.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthAPI.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPURLRequestParameter.h"

#import "NSURL+MPURLParameterAdditions.h"
#import "MPOAuthAPI+KeychainAdditions.h"

#define kMPOAuthTokenRefreshDateDefaultsKey		@"MPOAuthAutomaticTokenRefreshLastExpiryDate"

NSString *kMPOAuthCredentialConsumerKey			= @"kMPOAuthCredentialConsumerKey";
NSString *kMPOAuthCredentialConsumerSecret		= @"kMPOAuthCredentialConsumerSecret";
NSString *kMPOAuthCredentialRequestToken		= @"kMPOAuthCredentialRequestToken";
NSString *kMPOAuthCredentialRequestTokenSecret	= @"kMPOAuthCredentialRequestTokenSecret";
NSString *kMPOAuthCredentialAccessToken			= @"kMPOAuthCredentialAccessToken";
NSString *kMPOAuthCredentialAccessTokenSecret	= @"kMPOAuthCredentialAccessTokenSecret";
NSString *kMPOAuthCredentialSessionHandle		= @"kMPOAuthCredentialSessionHandle";

NSString *kMPOAuthSignatureMethod				= @"kMPOAuthSignatureMethod";

NSString *MPOAuthRequestTokenURLKey				= @"MPOAuthRequestTokenURL";
NSString *MPOAuthUserAuthorizationURLKey		= @"MPOAuthUserAuthorizationURL";
NSString *MPOAuthAccessTokenURLKey				= @"MPOAuthAccessTokenURL";

@interface MPOAuthAPI ()
@property (nonatomic, readwrite, retain) NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *credentials;
@property (nonatomic, readwrite, retain) NSURL *authenticationURL;
@property (nonatomic, readwrite, retain) NSURL *baseURL;
@property (nonatomic, readwrite, retain) NSMutableArray *activeLoaders;
@property (nonatomic, readwrite, retain) NSTimer *refreshTimer;

- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)inURL;
- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer;
- (void)_invalidateLocalCredentialsIfConsumerKeyHasChanged:(NSString*)currentConsumerKey;

@end

@implementation MPOAuthAPI

- (id)initWithCredentials:(NSDictionary *)inCredentials andBaseURL:(NSURL *)inBaseURL
{
	return [self initWithCredentials:inCredentials authenticationURL:inBaseURL andBaseURL:inBaseURL];
}

- (id)initWithCredentials:(NSDictionary *)inCredentials authenticationURL:(NSURL *)inAuthURL andBaseURL:(NSURL *)inBaseURL
{
	self = [super init];
	if (self != nil)
	{
		self.authenticationURL = inAuthURL;
		self.baseURL = inBaseURL;

		NSString* currentConsumerKey = (NSString*)[inCredentials objectForKey:kMPOAuthCredentialConsumerKey];
		[self _invalidateLocalCredentialsIfConsumerKeyHasChanged:currentConsumerKey];

		NSString *requestToken = [self findValueFromKeychainUsingName:@"oauth_token_request"];
		NSString *requestTokenSecret = [self findValueFromKeychainUsingName:@"oauth_token_request_secret"];
		NSString *accessToken = [self findValueFromKeychainUsingName:@"oauth_token_access"];
		NSString *accessTokenSecret = [self findValueFromKeychainUsingName:@"oauth_token_access_secret"];
		NSString *sessionHandle = [self findValueFromKeychainUsingName:@"oauth_session_handle"];
		
		_credentials = [[MPOAuthCredentialConcreteStore alloc] initWithCredentials:inCredentials];
		[_credentials setRequestToken:requestToken];
		[_credentials setRequestTokenSecret:requestTokenSecret];
		[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:accessToken];
		[_credentials setAccessTokenSecret:accessTokenSecret];
		[_credentials setSessionHandle:sessionHandle];
		
		_activeLoaders = [[NSMutableArray alloc] initWithCapacity:10];
		
		self.signatureScheme = MPOAuthSignatureSchemeHMACSHA1;

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_requestTokenReceived:) name:MPOAuthNotificationRequestTokenReceived object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];		
	}
	return self;	
}

- (oneway void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPOAuthNotificationRequestTokenReceived object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPOAuthNotificationAccessTokenReceived object:nil];
	
	self.credentials = nil;
	self.baseURL = nil;
	self.authenticationURL = nil;
	self.oauthRequestTokenURL = nil;
	self.oauthAuthorizeTokenURL = nil;
	self.oauthGetAccessTokenURL = nil;
	self.activeLoaders = nil;
	
	[self.refreshTimer invalidate];
	self.refreshTimer = nil;
	
	[super dealloc];
}

@synthesize credentials = _credentials;
@synthesize baseURL = _baseURL;
@synthesize authenticationURL = _authenticationURL;
@synthesize oauthRequestTokenURL = _oauthRequestTokenURL;
@synthesize oauthAuthorizeTokenURL = _oauthAuthorizeTokenURL;
@synthesize oauthGetAccessTokenURL = _oauthGetAccessTokenURL;
@synthesize signatureScheme = _signatureScheme;
@synthesize activeLoaders = _activeLoaders;
@synthesize delegate = _delegate;
@synthesize refreshTimer = _refreshTimer;

#pragma mark -

- (void)setSignatureScheme:(MPOAuthSignatureScheme)inScheme {
	_signatureScheme = inScheme;
	
	NSString *methodString = @"HMAC-SHA1";
	
	switch (_signatureScheme) {
		case MPOAuthSignatureSchemePlainText:
			methodString = @"PLAINTEXT";
			break;
		case MPOAuthSignatureSchemeRSASHA1:
			methodString = @"RSA-SHA1";
		case MPOAuthSignatureSchemeHMACSHA1:
		default:
			// already initted to the default
			break;
	}
	
	_credentials.signatureMethod = methodString;
}

#pragma mark -

- (BOOL) shouldAccessTokenBeRefreshed
{
	// citron todo: right now access tokens never expire from our server
	//				they can be revoked though. How do we authorize if we've lost authorization?
	return NO;
	
	NSTimeInterval expiryDateInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kMPOAuthTokenRefreshDateDefaultsKey];
	NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceReferenceDate:expiryDateInterval];
	return [tokenExpiryDate compare:[NSDate date]] == NSOrderedAscending;
}

- (bool)isAuthenticated
{
	return _credentials.accessToken && ![self shouldAccessTokenBeRefreshed];
}

- (MPOAuthAPIRequestLoader*)createLoaderForAccessToken
{
	return [self createLoaderForMethod:nil
					atURL:self.oauthGetAccessTokenURL
					withParameters:nil
					withHttpMethod:@"GET"					
					withSuccess:OFDelegate()
					withFailure:OFDelegate()];
}

- (MPOAuthAPIRequestLoader*)createLoaderForRequestToken
{
	[_credentials setRequestToken:nil];
	[_credentials setRequestTokenSecret:nil];

	return [self createLoaderForMethod:nil 
					atURL:self.oauthRequestTokenURL 					
					withParameters:nil 
					withHttpMethod:@"GET"
					withSuccess:OFDelegate(self, @selector(_authenticationRequestForRequestTokenSuccessfulLoad:)) 
					withFailure:OFDelegate()];
}

- (NSString*)getRequestToken
{
	return _credentials.requestToken;
}

- (NSString*)getAccessToken
{
	return _credentials.accessToken;
}

- (void)_authenticationRequestForRequestTokenSuccessfulLoad:(MPOAuthAPIRequestLoader *)inLoader
{
	// citron note: this is disabled. Instead we will listen for the notification and manually move to the next step
	return;
	
	NSDictionary *oauthResponseParameters = inLoader.oauthResponse.oauthParameters;
	NSString *xoauthRequestAuthURL = [oauthResponseParameters objectForKey:@"xoauth_request_auth_url"]; // a common custom extension, used by Yahoo!
	NSURL *userAuthURL = xoauthRequestAuthURL ? [NSURL URLWithString:xoauthRequestAuthURL] : self.oauthAuthorizeTokenURL;
	NSURL *callbackURL = [self.delegate respondsToSelector:@selector(callbackURLForCompletedUserAuthorization)] ? [self.delegate callbackURLForCompletedUserAuthorization] : nil;
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:	[oauthResponseParameters objectForKey:@"oauth_token"], @"oauth_token",
																			callbackURL, @"oauth_callback",
																			nil];

	userAuthURL = [userAuthURL urlByAddingParameterDictionary:parameters];
	BOOL delegateWantsToBeInvolved = [self.delegate respondsToSelector:@selector(automaticallyRequestAuthenticationWithToken:)];

	if (!delegateWantsToBeInvolved || (delegateWantsToBeInvolved && [self.delegate automaticallyRequestAuthenticationWithToken:[oauthResponseParameters objectForKey:@"oauth_token"]])) {
		[self _authenticationRequestForUserPermissionsConfirmationAtURL:userAuthURL];
	}
}

- (void)_authenticationRequestForUserPermissionsConfirmationAtURL:(NSURL *)userAuthURL {
#ifndef TARGET_OS_IPHONE
	[[NSWorkspace sharedWorkspace] openURL:userAuthURL];
#else
	[[UIApplication sharedApplication] openURL:userAuthURL];
#endif
}

#pragma mark -

- (void)performMethod:(NSString *)inMethod withSuccess:(const OFDelegate&)onSuccess withFailure:(const OFDelegate&)onFailure
{
	[self performMethod:inMethod atURL:self.baseURL withParameters:nil withSuccess:onSuccess withFailure:onFailure];
}

- (void)performMethod:(NSString *)inMethod atURL:(NSURL *)inURL withParameters:(NSArray *)inParameters withSuccess:(const OFDelegate&)onSuccess withFailure:(const OFDelegate&)onFailure 
{
	[self performMethod:inMethod atURL:inURL withParameters:inParameters withHttpMethod:@"GET" withSuccess:onSuccess withFailure:onFailure];
}

- (MPOAuthAPIRequestLoader*)createLoaderForMethod:(NSString *)inMethod 
		atURL:(NSURL *)inURL 
		withParameters:(NSArray *)inParameters 
		withHttpMethod:(NSString*)httpMethod 
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure 
{
	if (!inMethod && ![inURL path] && ![inURL query])
	{
		[NSException raise:@"MPOAuthNilMethodRequestException" format:@"Nil was passed as the method to be performed on %@", inURL];
	}
	
	NSURL *requestURL = inMethod ? [NSURL URLWithString:inMethod relativeToURL:inURL] : inURL;
	MPOAuthURLRequest *aRequest = [[[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters] autorelease];
	aRequest.HTTPMethod = httpMethod;
	
	MPOAuthAPIRequestLoader *loader = [[[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest] autorelease];

	loader.credentials = self.credentials;
	[loader setOnSuccess:onSuccess];
	[loader setOnFailure:onFailure];
	
	return loader;
}

- (void)performMethod:(NSString *)inMethod 
		atURL:(NSURL *)inURL 
		withParameters:(NSArray *)inParameters 
		withHttpMethod:(NSString*)httpMethod 
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure 
{
	MPOAuthAPIRequestLoader* loader = [self createLoaderForMethod:inMethod atURL:inURL withParameters:inParameters withHttpMethod:httpMethod withSuccess:onSuccess withFailure:onFailure];
	[loader loadSynchronously:NO];
}

- (NSData *)dataForMethod:(NSString *)inMethod {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:nil];
}

- (NSData *)dataForMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	return [self dataForURL:self.baseURL andMethod:inMethod withParameters:inParameters];
}

- (NSData *)dataForURL:(NSURL *)inURL andMethod:(NSString *)inMethod withParameters:(NSArray *)inParameters {
	NSURL *requestURL = [NSURL URLWithString:inMethod relativeToURL:inURL];
	MPOAuthURLRequest *aRequest = [[MPOAuthURLRequest alloc] initWithURL:requestURL andParameters:inParameters];
	MPOAuthAPIRequestLoader *loader = [[MPOAuthAPIRequestLoader alloc] initWithRequest:aRequest];

	loader.credentials = self.credentials;
	[loader loadSynchronously:YES];
	
	[loader autorelease];
	[aRequest release];
	
	return loader.data;
}

#pragma mark -

- (void)_performedLoad:(MPOAuthAPIRequestLoader *)inLoader receivingData:(NSData *)inData {
//	OFLog(@"loaded %@, and got %@", inLoader, inData);
}

#pragma mark -

- (void)removeAllCredentials
{
	[self removeValueFromKeychainUsingName:@"oauth_token_request"];
	[self removeValueFromKeychainUsingName:@"oauth_token_request_secret"];
	[self removeValueFromKeychainUsingName:@"oauth_token_access"];
	[self removeValueFromKeychainUsingName:@"oauth_token_access_secret"];
	[self removeValueFromKeychainUsingName:@"oauth_session_handle"];
	
	[_credentials setRequestToken:nil];
	[_credentials setRequestTokenSecret:nil];
	[(MPOAuthCredentialConcreteStore *)_credentials setAccessToken:nil];
	[_credentials setAccessTokenSecret:nil];
	[_credentials setSessionHandle:nil];
}

- (void)_requestTokenReceived:(NSNotification *)inNotification {
	[self addToKeychainUsingName:@"oauth_token_request" andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:@"oauth_token_request_secret" andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
}

- (void)_accessTokenReceived:(NSNotification *)inNotification {
	[self removeValueFromKeychainUsingName:@"oauth_token_request"];
	[self removeValueFromKeychainUsingName:@"oauth_token_request_secret"];
	
	[self addToKeychainUsingName:@"oauth_token_access" andValue:[[inNotification userInfo] objectForKey:@"oauth_token"]];
	[self addToKeychainUsingName:@"oauth_token_access_secret" andValue:[[inNotification userInfo] objectForKey:@"oauth_token_secret"]];
	
	[self addToKeychainUsingName:@"oauth_session_handle" andValue:[[inNotification userInfo] objectForKey:@"oauth_session_handle"]];
	
	NSTimeInterval tokenRefreshInterval = (NSTimeInterval)[[[inNotification userInfo] objectForKey:@"oauth_expires_in"] intValue];
	NSDate *tokenExpiryDate = [NSDate dateWithTimeIntervalSinceNow:tokenRefreshInterval];
	[[NSUserDefaults standardUserDefaults] setDouble:[tokenExpiryDate timeIntervalSinceReferenceDate] forKey:kMPOAuthTokenRefreshDateDefaultsKey];
	
	if (!_refreshTimer && tokenRefreshInterval > 0.0) {
		self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:tokenRefreshInterval target:self selector:@selector(_automaticallyRefreshAccessToken:) userInfo:nil repeats:YES];
	}
}

#pragma mark -

- (void)_automaticallyRefreshAccessToken:(NSTimer *)inTimer
{
	MPURLRequestParameter *sessionHandleParameter = [[MPURLRequestParameter alloc] init];
	sessionHandleParameter.name = @"oauth_session_handle";
	sessionHandleParameter.value = _credentials.sessionHandle;
	
	[self performMethod:nil
				  atURL:self.oauthGetAccessTokenURL
		 withParameters:[NSArray arrayWithObject:sessionHandleParameter]
			 withSuccess:OFDelegate()
			  withFailure:OFDelegate()];
	
	[sessionHandleParameter release];
}

- (bool)canReceiveCallbacksNow
{
	return YES;
}

- (void)setAccessToken:(NSString*)token andSecret:(NSString*)secret
{
	[_credentials setAccessToken:token];
	[_credentials setAccessTokenSecret:secret];
	
	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
		token, @"oauth_token",
		secret, @"oauth_token_secret",
		nil
	];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MPOAuthNotificationAccessTokenReceived
																			object:nil
																			userInfo:parameters];	
}

- (void)_invalidateLocalCredentialsIfConsumerKeyHasChanged:(NSString*)currentConsumerKey
{
	NSString *cachedConsumerKey = [self findValueFromKeychainUsingName:kMPOAuthCredentialConsumerKey];
	if (![cachedConsumerKey isEqualToString:currentConsumerKey])
	{
		[self removeAllCredentials];
	}
	
	[self addToKeychainUsingName:kMPOAuthCredentialConsumerKey andValue:currentConsumerKey];
}

@end

