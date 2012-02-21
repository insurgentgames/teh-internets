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
#import "OFCallbackable.h"
#import "OFActionRequestType.h"

@class OFNotificationData;
@class MPOAuthAPIRequestLoader;

@interface OFActionRequest : NSObject<OFCallbackable>
{
	MPOAuthAPIRequestLoader* mLoader;
	OFActionRequestType mRequestType;
	OFNotificationData* mNoticeData;
	int mPreviousHttpStatusCode;
	bool mRequiresAuthentication;
}

@property (nonatomic, readonly) OFNotificationData* notice;
@property (nonatomic, readonly) bool failedNotAuthorized;
@property (nonatomic, readonly) bool requiresAuthentication;

+ (id)actionRequestWithLoader:(MPOAuthAPIRequestLoader*)loader withRequestType:(OFActionRequestType)requestType withNotice:(OFNotificationData*)noticeData requiringAuthentication:(bool)requiringAuthentication;

- (id)initWithLoader:(MPOAuthAPIRequestLoader*)loader withRequestType:(OFActionRequestType)requestType withNotice:(OFNotificationData*)noticeData requiringAuthentication:(bool)requiringAuthentication;
- (void)dispatch;
- (bool)canReceiveCallbacksNow;

- (void)abandonInLightOfASeriousError;

@end

extern const int OpenFeintHttpStatusCodeForServerMaintanence;
extern const int OpenFeintHttpStatusCodeNotFound;
extern const int OpenFeintHttpStatusCodeForbidden;
