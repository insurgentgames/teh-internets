////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// 
///  Copyright 2009 Aurora Feint, Inc.
/// 
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///  
///  	http://www.apache.org/licenses/LICENSE-2.0
///  	
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
/// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "OFProvider.h"
#import "MPOAuthAPI.h"
#import "MPURLRequestParameter.h"
#import "OFHttpService.h"
#import "OFActionRequest.h"
#import "OFSettings.h"
#import "OpenFeint+UserOptions.h"
#import "OFDelegateChained.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFReachabilityObserver.h"
#import "OpenFeint+Private.h"
#import "OFBootstrapService.h"
#import "FBConnect.h"
#import "OFPresenceService.h"


@implementation OFProvider

- (void)_onReachabilityStatusChanged:(NSNumber*)statusAsInt
{
	NetworkReachability status = (NetworkReachability)[statusAsInt intValue];
	if(status == NotReachable)
	{
//		[OpenFeint displayOnlineConnectionErrorMessage];
	}
}

- (id) initWithProductKey:(NSString*)productKey andSecret:(NSString*)productSecret
{
	self = [super init];
	if (self != nil)
	{
		NSDictionary* credentials = [NSDictionary dictionaryWithObjectsAndKeys:
			productKey,		kMPOAuthCredentialConsumerKey,
			productSecret,	kMPOAuthCredentialConsumerSecret,
			nil
		];
		
		NSString* apiUrlString = OFSettings::Instance()->getServerUrl();
		NSURL* apiUrl = [NSURL URLWithString:apiUrlString];

		mOAuthApi = [[MPOAuthAPI alloc] initWithCredentials:credentials	andBaseURL:apiUrl];
		
		mOAuthApi.oauthRequestTokenURL		= [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/request_token", apiUrlString]];
		mOAuthApi.oauthAuthorizeTokenURL	= [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/authorize", apiUrlString]];
		mOAuthApi.oauthGetAccessTokenURL	= [NSURL URLWithString:[NSString stringWithFormat:@"%@oauth/access_token", apiUrlString]];

		mReachabilityObserver.reset(new OFReachabilityObserver(OFDelegate(self, @selector(_onReachabilityStatusChanged:))));
		
		mPendingRequests = [[NSMutableArray alloc] initWithCapacity:4];
	}
	
	return self;
}

- (void) dealloc
{
	[self destroyAllPendingRequests];
	OFSafeRelease(mPendingRequests);
	[mOAuthApi release];
	[super dealloc];
}

+ (id) providerWithProductKey:(NSString*)productKey andSecret:(NSString*)productSecret
{
	return [[[OFProvider alloc] initWithProductKey:productKey andSecret:productSecret] autorelease];
}

- (void) destroyAllPendingRequests
{
	for (MPOAuthAPIRequestLoader* loader in mPendingRequests)
		[loader cancel];
		
	[mPendingRequests removeAllObjects];
}

- (void) cancelRequest:(id)request
{
	NSUInteger requestIndex = [mPendingRequests indexOfObjectIdenticalTo:request];
	
	if (requestIndex != NSNotFound)
	{
		if ([request isKindOfClass:[MPOAuthAPIRequestLoader class]])
			[(MPOAuthAPIRequestLoader*)request cancel];	

		[mPendingRequests removeObjectAtIndex:requestIndex];
	}
}

- (void) destroyLocalCredentials
{
	OFLog(@"destroy local credentials");
	[mOAuthApi removeAllCredentials];
	[[FBSession session] logout];
	[FBSession deleteFacebookCookies];
	[[OFPresenceService sharedInstance] disconnectAndShutdown:NO];
}

+ (OFPointer<OFHttpService>)createHttpService
{
	return new OFHttpService(OFSettings::Instance()->getServerUrl());
}

- (bool) isAuthenticated
{
	return [mOAuthApi isAuthenticated];
}

- (void)actionRequestWithLoader:(MPOAuthAPIRequestLoader*)loader withRequestType:(OFActionRequestType)requestType withNotice:(OFNotificationData*)noticeData requiringAuthentication:(bool)requiringAuthentication
{
	[mPendingRequests addObject:loader];

	OFActionRequest* ofAction = [OFActionRequest actionRequestWithLoader:loader withRequestType:requestType withNotice:noticeData requiringAuthentication:requiringAuthentication];
	[ofAction performSelectorOnMainThread:@selector(dispatch) withObject:nil waitUntilDone:YES];
}

- (void)_loaderFinished:(MPOAuthAPIRequestLoader*)loader nextCall:(OFDelegateChained*)nextCall
{
	[mPendingRequests removeObjectIdenticalTo:loader];
	[nextCall invokeWith:loader];
}

- (void) retrieveAccessToken
{
	MPOAuthAPIRequestLoader* loader = [mOAuthApi createLoaderForAccessToken];	
	[self actionRequestWithLoader:loader withRequestType:OFActionRequestForeground withNotice:[OFNotificationData dataWithText:@"Finalizing Authentication" andCategory:kNotificationCategoryLogin] requiringAuthentication:false];
}

- (void) retrieveRequestToken
{
	MPOAuthAPIRequestLoader* loader = [mOAuthApi createLoaderForRequestToken];	
	[self actionRequestWithLoader:loader withRequestType:OFActionRequestForeground withNotice:[OFNotificationData dataWithText:@"Starting Authentication" andCategory:kNotificationCategoryLogin] requiringAuthentication:false];
}

- (NSString*) getRequestToken
{
	return [mOAuthApi getRequestToken];
}

- (NSString*) getAccessToken
{
	return [mOAuthApi getAccessToken];
}

- (MPOAuthAPIRequestLoader*)getRequestForAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData
		requiringAuthentication:(bool)requiringAuthentication
{
	OFDelegate chainedSuccess(self, @selector(_loaderFinished:nextCall:), success);
	OFDelegate chainedFailure(self, @selector(_loaderFinished:nextCall:), failure);

	MPOAuthAPIRequestLoader* loader = 
		[mOAuthApi createLoaderForMethod:action 
									atURL:[NSURL URLWithString:OFSettings::Instance()->getServerUrl()]
						   withParameters:parameters
						   withHttpMethod:method					   
							  withSuccess:chainedSuccess
							  withFailure:chainedFailure];
							  
	return loader;
}

- (OFRequestHandle*)performAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData
		requiringAuthentication:(bool)requiringAuthentication
{
	if (![OpenFeint hasUserApprovedFeint])
	{
		return nil;
	}
	MPOAuthAPIRequestLoader* loader = [self 
		getRequestForAction:action
		withParameters:parameters
		withHttpMethod:method
		withSuccess:success
		withFailure:failure
		withRequestType:requestType
		withNotice:noticeData
		requiringAuthentication:requiringAuthentication];
	
	OFRequestHandle* rh = [OFRequestHandle requestHandle:loader];
	[self actionRequestWithLoader:loader withRequestType:requestType withNotice:noticeData requiringAuthentication:requiringAuthentication];
	
	return rh;
}

- (OFRequestHandle*)performAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData
{
	return [self performAction:action
			withParameters:parameters
			withHttpMethod:method
			withSuccess:success
			withFailure:failure
			withRequestType:requestType
			withNotice:noticeData
			requiringAuthentication:true];
}

- (void)setAccessToken:(NSString*)token andSecret:(NSString*)secret
{
	[mOAuthApi setAccessToken:token andSecret:secret];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void) loginAndBootstrapWithDeviceToken:(NSData*)deviceToken 
					   forceCreateAccount:(bool)forceCreateAccount 
								   userId:(NSString*)userId
								onSuccess:(const OFDelegate&)success 
								onFailure:(const OFDelegate&)failure
{
	[OFBootstrapService doBootstrapWithDeviceToken:deviceToken
							 forceCreateNewAccount:forceCreateAccount
											userId:userId
							  onSucceededLoggingIn:success 
								 onFailedLoggingIn:failure];
}

@end
