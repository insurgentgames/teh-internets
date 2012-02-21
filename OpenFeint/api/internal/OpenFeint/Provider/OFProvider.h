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

#pragma once

#import "OFPointer.h"
#import "OFProviderProtocol.h"
#import "OFRequestHandle.h"

class OFDelegate;
class OFReachabilityObserver;
class OFHttpService; 
template <typename _T> class onSmartPointer;
@protocol MPOAuthAPIDelegate;
@class MPOAuthAPIRequestLoader;
@class MPOAuthAPI;
@class OFNotificationData;

@interface OFProvider : NSObject<OFCallbackable, OFProviderProtocol>
{
@private
	MPOAuthAPI* mOAuthApi;
	OFPointer<OFReachabilityObserver> mReachabilityObserver;
	NSMutableArray* mPendingRequests;
}

+ (id) providerWithProductKey:(NSString*)productKey andSecret:(NSString*)productSecret;
- (id) initWithProductKey:(NSString*)productKey andSecret:(NSString*)productSecret;

+ (OFPointer<OFHttpService>)createHttpService;

- (void)setAccessToken:(NSString*)token andSecret:(NSString*)secret;

- (void) retrieveAccessToken;
- (void) retrieveRequestToken;
- (NSString*) getRequestToken;
- (NSString*) getAccessToken;

- (bool) isAuthenticated;
- (void) loginAndBootstrapWithDeviceToken:(NSData*)deviceToken 
					   forceCreateAccount:(bool)forceCreateAccount 
								   userId:(NSString*)userId
								onSuccess:(const OFDelegate&)success 
								onFailure:(const OFDelegate&)failure;
- (void) destroyLocalCredentials;
- (void) destroyAllPendingRequests;
- (void) cancelRequest:(id)request;

- (MPOAuthAPIRequestLoader*)getRequestForAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData
		requiringAuthentication:(bool)requiringAuthentication;

- (OFRequestHandle*)performAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData;

- (OFRequestHandle*)performAction:(NSString*)action 
		withParameters:(NSArray*)parameters 
		withHttpMethod:(NSString*)method 
		withSuccess:(const OFDelegate&)success 
		withFailure:(const OFDelegate&)failure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)noticeData
		requiringAuthentication:(bool)requiringAuthentication;
@end
