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

// Implement this delegate if you don't want OpenFeint to show standard notifications in all cases.
@protocol OFNotificationDelegate<NSObject>

@optional
////////////////////////////////////////////////////////////
///
/// @note	Return whether or not openfeint should display a notification with the provided data.
///			If false is returned, handleDisallowedNotification: gets called
//			If true is returned, notificationWillShow: gets called before the notification appears
///
////////////////////////////////////////////////////////////
- (BOOL)isOpenFeintNotificationAllowed:(OFNotificationData*)notificationData; 

////////////////////////////////////////////////////////////
///
/// @note	Gets called when isOpenFeintNotificationAllowed: returns false. It is recommended to here display some sort of game
///			specific version of the notification based on the notification data
///
////////////////////////////////////////////////////////////
- (void)handleDisallowedNotification:(OFNotificationData*)notificationData;

////////////////////////////////////////////////////////////
///
/// @note	Gets called every time a notification is about to appear
///
////////////////////////////////////////////////////////////
- (void)notificationWillShow:(OFNotificationData*)notificationData;

@end
