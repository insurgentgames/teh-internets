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

#import <Foundation/Foundation.h>
#import "OFService.h"
#import "OFCRVStompClient.h"

@class OFCRVStompClient;
@class OFPaginatedSeries;

@interface OFPresenceService : OFService <OFCRVStompClientDelegate> {
	NSInteger retriesAttempted;
	BOOL isConnected;
	BOOL isHttpPipeEnabled;
	BOOL isShuttingDown;
	BOOL isBroadcastingStatus;
	NSString *accessToken;
	NSString *presenceQueue;
	NSMutableDictionary *httpRequests;
	OFCRVStompClient *stompClient;
	id currentThread;
}

OPENFEINT_DECLARE_AS_SERVICE(OFPresenceService);

@property BOOL isConnected;
@property BOOL isHttpPipeEnabled;
@property BOOL isShuttingDown;
@property BOOL isBroadcastingStatus;
@property (retain) NSString *accessToken;
@property (retain) NSString *presenceQueue;
@property (retain) id currentThread;
@property (retain) NSMutableDictionary *httpRequests;
@property (retain) OFCRVStompClient *stompClient;

+(OFPresenceService *)sharedInstance;
+(BOOL)isHttpPipeEnabled;
-(void)connectToPresenceQueue:(NSString*)thePresenceQueue withOAuthAccessToken:(NSString *)theOAuthAccessToken andHttpPipeEnabled:(BOOL)theHttpPipeEnabled andBroadcastStatus:(BOOL)initializePresenceService;
-(void)connectInBackground:(id)userInfo;
-(void)disconnectAndShutdown:(BOOL)shutdown;
-(void)postInMainThread:(id)resource;
-(void)wrapUrlConnection:(id)theUrlConnection andRequest:(id)theRequest andDelegate:(id)theDelegate;
-(void)sendHttpRequest:(NSString *)theRequest;
-(void)onFailedToLoadPresenceQueue;
-(void)onPresenceQueueLoaded:(OFPaginatedSeries *)resources;
-(void)connect;

@end