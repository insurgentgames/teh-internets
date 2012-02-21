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

#import "OpenFeint.h"

@class OFUser;

/////////////////////////////////////////////////////
// Online/Offline Notification
//
// This notification is posted when the user goes online
extern NSString const* OFNSNotificationUserOnline;
// This notification is posted when the user goes offline
extern NSString const* OFNSNotificationUserOffline;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// User Changed Notification
//
// This notification is posted when the user changes
extern NSString const* OFNSNotificationUserChanged;
// These are the keys for the userInfo dictionary in the UserChanged notification
extern NSString const* OFNSNotificationInfoPreviousUser;
extern NSString const* OFNSNotificationInfoCurrentUser;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// Unviewed Challenge Count Notification
//
// This notification is posted when the unviewed challenge count changes
extern NSString const* OFNSNotificationUnviewedChallengeCountChanged;
// These are the keys for the userInfo dictionary in the UnviewedChallengeCountChanged notification
extern NSString const* OFNSNotificationInfoUnviewedChallengeCount;
/////////////////////////////////////////////////////

//Presence Notifications
extern NSString const *OFNSNotificationFriendPresenceChanged;


/////////////////////////////////////////////////////
// Pending Friend Count Notification
//
// This notification is posted when the pending friend count changes
extern NSString const* OFNSNotificationPendingFriendCountChanged;
// These are the keys for the userInfo dictionary in the PendingFriendCountChanged notification
extern NSString const* OFNSNotificationInfoPendingFriendCount;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// Add/Remove Friends Notification
extern NSString const* OFNSNotificationAddFriend;
extern NSString const* OFNSNotificationRemoveFriend;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// Unread Announcement Notification
//
// This notification is posted when the unread announcement count changes
extern NSString const* OFNSNotificationUnreadAnnouncementCountChanged;
// These are the keys for the userInfo dictionary in the UnreadAnnouncementCountChanged notification
extern NSString const* OFNSNotificationInfoUnreadAnnouncementCount;
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
// Unread Inbox Notification
//
// This notification is posted when the unread inbox count changes
extern NSString const* OFNSNotificationUnreadInboxCountChanged;
// These are the keys for the userInfo dictionary in the UnreadInboxCountChanged notification
extern NSString const* OFNSNotificationInfoUnreadInboxCount;
/////////////////////////////////////////////////////

@interface OpenFeint (NSNotification)

+ (void)postUserChangedNotificationFromUser:(OFUser*)from toUser:(OFUser*)to;
+ (void)postUnviewedChallengeCountChangedTo:(NSUInteger)unviewedChallengeCount;
+ (void)postFriendPresenceChanged:(OFUser *)theUser withPresence:(NSString *)thePresence;
+ (void)postPendingFriendsCountChangedTo:(NSUInteger)pendingFriendCount;
+ (void)postAddFriend:(OFUser*)newFriend;
+ (void)postRemoveFriend:(OFUser*)oldFriend;
+ (void)postUnreadAnnouncementCountChangedTo:(NSUInteger)unreadAnnouncementCount;
+ (void)postUnreadInboxCountChangedTo:(NSUInteger)unreadInboxCount;

@end
