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

#import "OFNotificationData.h"

@implementation OFNotificationData

@synthesize notificationText, notificationCategory, notificationType, notificationUserData;

+ (OFNotificationData*)foreGroundDataWithText:(NSString*)text
{
	return [OFNotificationData dataWithText:text andCategory:kNotificationCategoryForeground];
}

+ (OFNotificationData*)dataWithText:(NSString*)text andCategory:(OFNotificationCategory)notificationCategory
{
	return [OFNotificationData dataWithText:text andCategory:notificationCategory andType:kNotificationTypeNone];
}

+ (OFNotificationData*)dataWithText:(NSString*)text andCategory:(OFNotificationCategory)notificationCategory andType:(OFNotificationType)notificationType
{
	OFNotificationData* data = [[OFNotificationData new] autorelease];
	data.notificationText = text;
	data.notificationCategory = notificationCategory;
	data.notificationType = notificationType;
	data.notificationUserData = nil;
	return data;
}

- (void)dealloc
{
	self.notificationText = nil;
	self.notificationUserData = nil;
	[super dealloc];
}

@end
