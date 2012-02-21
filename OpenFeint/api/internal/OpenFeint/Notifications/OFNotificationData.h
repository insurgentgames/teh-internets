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

enum OFNotificationCategory 
{
	kNotificationCategoryForeground = 1,
	kNotificationCategoryLogin,
	kNotificationCategoryChallenge,
	kNotificationCategoryHighScore,
	kNotificationCategoryLeaderboard,
	kNotificationCategoryAchievement,
	kNotificationCategorySocialNotification,
	kNotificationCategoryPresence
};

enum OFNotificationType 
{
	kNotificationTypeNone = 0,
	kNotificationTypeSubmitting,
	kNotificationTypeDownloading,
	kNotificationTypeError,
	kNotificationTypeSuccess,
	kNotificationTypeNewResources,
	kNotificationTypeUserPresenceOnline,
	kNotificationTypeUserPresenceOffline,
	kNotificationTypeNewMessage,
};

@interface OFNotificationData : NSObject
{
	NSString* notificationText;
	OFNotificationCategory notificationCategory;
	OFNotificationType notificationType;
	id notificationUserData;
}

@property (nonatomic, retain) NSString* notificationText;
@property (nonatomic, assign) OFNotificationCategory notificationCategory;
@property (nonatomic, assign) OFNotificationType notificationType;
@property (nonatomic, retain) id notificationUserData;

+ (OFNotificationData*)foreGroundDataWithText:(NSString*)text;
+ (OFNotificationData*)dataWithText:(NSString*)text andCategory:(OFNotificationCategory)notificationCategory;
+ (OFNotificationData*)dataWithText:(NSString*)text andCategory:(OFNotificationCategory)notificationCategory andType:(OFNotificationType)notificationType;

@end
