//
//  MPOAuthConnection.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthConnection.h"
#import "MPOAuthURLRequest.h"
#import "MPOAuthURLResponse.h"
#import "MPOAuthParameterFactory.h"
#import "MPOAuthCredentialConcreteStore.h"
#import "OFPresenceService.h"

@interface MPOAuthURLResponse ()
@property (nonatomic, readwrite, retain) NSURLResponse *urlResponse;
@property (nonatomic, readwrite, retain) NSDictionary *oauthParameters;
@end

@implementation MPOAuthConnection

+ (MPOAuthConnection *)connectionWithRequest:(MPOAuthURLRequest *)inRequest delegate:(id)inDelegate credentials:(NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *)inCredentials {
	MPOAuthConnection *aConnection = [[MPOAuthConnection alloc] initWithRequest:inRequest delegate:inDelegate credentials:inCredentials];
	return [aConnection autorelease];
}

+ (NSData *)sendSynchronousRequest:(MPOAuthURLRequest *)inRequest usingCredentials:(NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *)inCredentials returningResponse:(MPOAuthURLResponse **)outResponse error:(NSError **)inError {
	[inRequest addParameters:[inCredentials oauthParameters]];
	NSURLRequest *urlRequest = [inRequest urlRequestSignedWithSecret:[inCredentials signingKey] usingMethod:[inCredentials signatureMethod]];
	NSURLResponse *urlResponse = nil;
	NSData *responseData = [self sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:inError];
	MPOAuthURLResponse *oauthResponse = [[[MPOAuthURLResponse alloc] init] autorelease];
	oauthResponse.urlResponse = urlResponse;
	*outResponse = oauthResponse;
	
	return responseData;
}

+ (NSURLRequest *)configuredRequest:(MPOAuthURLRequest *)inRequest delegate:(id)inDelegate credentials:(NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *)inCredentials
{
	return [inRequest urlRequestSignedWithSecret:[inCredentials signingKey] usingMethod:[inCredentials signatureMethod] withExtraParameters:[inCredentials oauthParameters]];
}

- (id)initWithRequest:(MPOAuthURLRequest *)inRequest delegate:(id)inDelegate credentials:(NSObject <MPOAuthCredentialStore, MPOAuthParameterFactory> *)inCredentials 
{
	NSURLRequest *urlRequest = [inRequest urlRequestSignedWithSecret:[inCredentials signingKey] usingMethod:[inCredentials signatureMethod] withExtraParameters:[inCredentials oauthParameters]];
	//OFLog(@"the url: %@", [urlRequest URL]);
	if ([OFPresenceService isHttpPipeEnabled]) {
		self = [super initWithRequest:urlRequest delegate:inDelegate startImmediately:NO];
		if (self != nil)
		{
			_credentials = [inCredentials retain];
		}
		[[OFPresenceService sharedInstance] wrapUrlConnection:self andRequest:urlRequest andDelegate:inDelegate];
	} else {
		self = [super initWithRequest:urlRequest delegate:inDelegate];
		if (self != nil)
		{
			_credentials = [inCredentials retain];
		}
	}

	return self;
}

- (oneway void)dealloc {
	[_credentials release];
	[super dealloc];
}

@synthesize credentials = _credentials;

#pragma mark -

@end
