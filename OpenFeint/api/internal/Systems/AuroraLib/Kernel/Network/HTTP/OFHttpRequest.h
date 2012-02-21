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

#import <UIKit/UIKit.h>

class OFHttpRequestObserver;

// If these are declared as static const, we get tons of "defined but not used" warnings
#define HttpMethodPost @"POST"
#define HttpMethodGet @"GET"
#define HttpMethodPut @"PUT"
#define HttpMethodDelete @"DELETE"


@interface OFHttpRequest : NSObject
{
	NSString* mRequestPath;
	NSString* mRequestMethod;
	NSHTTPURLResponse* mHttpResponse;
	NSMutableData* mReceivedData;
	NSURLConnection* mURLConnection;
	NSString* mBaseUrl;
	OFRetainedPtr<NSString> mPassword;
	OFRetainedPtr<NSString> mEmail;
	bool mIsRequestInProgress;
	
	OFHttpRequestObserver* mObserver;
	
	bool mHandleCookies;
}

+ (id)httpRequestWithBase:(NSString*)urlBase withObserver:(OFHttpRequestObserver*)observer;
+ (id)httpRequestWithBase:(NSString*)urlBase withObserver:(OFHttpRequestObserver*)observer withCookies:(bool)cookies;
- (id)initWithBaseUrl:(NSString*)url withObserver:(OFHttpRequestObserver*)observer;
- (id)initWithBaseUrl:(NSString*)url withObserver:(OFHttpRequestObserver*)observer withCookies:(bool)cookies;
- (void)startRequestWithPath:(NSString*)path withMethod:(NSString*)httpMethod withBody:(NSData*)httpBody;
- (void)startRequestWithPath:(NSString*)path withMethod:(NSString*)httpMethod withBody:(NSData*)httpBody withEmail:(NSString*)email withPassword:(NSString*)password multiPartBoundary:(NSString*)multiPartBoundary;
- (void)changeObserver:(OFHttpRequestObserver*)newObserver;

- (void)cancelImmediately;

+ (bool)hasCookies:urlBase;
+ (int)countCookies:urlBase;
+ (NSArray*)getCookies:urlBase;
+ (void)addCookies:(NSArray*)cookies withBase:urlBase;
- (bool)hasCookies;
- (int)countCookies;
- (NSArray*)getCookies;
- (void)addCookies:(NSArray*)cookies;

@property(nonatomic, readonly) NSString* urlPath;
@property(nonatomic, readonly) NSString* httpMethod;
@property(nonatomic, readonly) NSURLConnection* url;
@property(nonatomic, readonly) NSData* data;
@property(nonatomic, readonly) NSString* contentType;
@property(nonatomic, readonly) NSString* contentDisposition;

- (void)_releaseConnectionResources;
@end