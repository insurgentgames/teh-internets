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

#import "OFDependencies.h"
#import "OpenFeint.h"

@class OFUser;
@class OFGameProfilePageInfo;

enum OFUserDistanceUnitType { kDistanceUnitNotDefined = 0, kDistanceUnitNotAllowed, kDistanceUnitMiles, kDistanceUnitKilometers };

@interface OpenFeint (UserOptions)

+ (void)intiailizeUserOptions;

+ (void)setDontAutomaticallyPromptLogin;
+ (bool)shouldAutomaticallyPromptLogin;

+ (void)setUserApprovedFeint;
+ (void)setUserDeniedFeint;
+ (bool)hasUserSetFeintAccess;
+ (bool)_hasUserApprovedFeint; // hasUserApprovedFeint is declared in OpenFeint.h
+ (void)_resetHasUserSetFeintAccess;
+ (void)logoutUser;

+ (NSString*)lastLoggedInUserId;
+ (NSString*)lastLoggedInUserProfilePictureUrl;
+ (BOOL)lastLoggedInUserUsesFacebookProfilePicture;
+ (NSString*)lastLoggedInUserName;

+ (void)setLoggedInUserHasSetName:(BOOL)hasSetName;
+ (BOOL)lastLoggedInUserHasSetName;
+ (void)setLoggedInUserHasNonDeviceCredential:(BOOL)hasNonDeviceCredential;
+ (BOOL)loggedInUserHasNonDeviceCredential;

+ (void)setLoggedInUserHasHttpBasicCredential:(BOOL)hasHttpBasicCredential;
+ (BOOL)loggedInUserHasHttpBasicCredential;

+ (void)setLoggedInUserHasFbconnectCredential:(BOOL)hasFbconnectCredential;
+ (BOOL)loggedInUserHasFbconnectCredential;

+ (void)setLoggedInUserHasTwitterCredential:(BOOL)hasTwitterCredential;
+ (BOOL)loggedInUserHasTwitterCredential;

+ (void)setLoggedInUserIsNewUser:(BOOL)isNewUser;
+ (BOOL)loggedInUserIsNewUser;
+ (void)setLoggedInUserHadFriendsOnBootup:(BOOL)hadFriends;
+ (BOOL)lastLoggedInUserHadFriendsOnBootup;

+ (void)setLoggedInUserSharesOnlineStatus:(BOOL)loggedInUserSharesOnlineStatus;
+ (BOOL)loggedInUserSharesOnlineStatus;

+ (void)setClientApplicationId:(NSString*)clientApplicationId;
+ (NSString*)clientApplicationId;

+ (void)setClientApplicationIconUrl:(NSString*)clientApplicationIconUrl;
+ (NSString*)clientApplicationIconUrl;

+ (void)setUnviewedChallengesCount:(NSInteger)numChallenges;
+ (NSInteger)unviewedChallengesCount;

+ (void)setPendingFriendsCount:(NSInteger)numFriends;
+ (NSInteger)pendingFriendsCount;

+ (void)setUnreadInboxCount:(NSInteger)unread;
+ (NSInteger)unreadInboxCount;

+ (void)setInitialDashboardScreen:(NSString*)initialDashboardScreen;
+ (NSString*)initialDashboardScreen;

+ (void)setUserHasRememberedChoiceForNotifications:(BOOL)hasRememberedChoice;
+ (BOOL)userHasRememberedChoiceForNotifications;

+ (void)setUserAllowsNotifications:(BOOL)choice;
+ (BOOL)userAllowsNotifications;

+ (void)setLoggedInUserHasChatEnabled:(BOOL)enabled;
+ (BOOL)loggedInUserHasChatEnabled;

+ (BOOL)appHasAchievements;
+ (BOOL)appHasChallenges;
+ (BOOL)appHasLeaderboards;
+ (BOOL)appHasFeaturedApplication;

+ (void)setLocalGameProfileInfo:(OFGameProfilePageInfo*)profileInfo;
+ (OFGameProfilePageInfo*)localGameProfileInfo;

+ (void)setLocalUser:(OFUser*)user;
+ (OFUser*)localUser;

+ (void)loggedInUserChangedNameTo:(NSString*)name;

+ (void)setShouldWarnOnIncompleteDelegates:(BOOL)shouldWarnOnIncompleteDelegates;
+ (BOOL)shouldWarnOnIncompleteDelegates;

+ (void)setUserDistanceUnit:(OFUserDistanceUnitType)distanceUnit;
+ (OFUserDistanceUnitType)userDistanceUnit;

+ (NSDate*)lastAnnouncementDateForLocalUser;
+ (void)setLastAnnouncementDateForLocalUser:(NSDate*)date;

+ (NSString*)suggestionsForumId;
+ (void)setSuggestionsForumId:(NSString*)forumId;

+ (void)setDoneWithGetTheMost:(BOOL)enabled;
+ (BOOL)doneWithGetTheMost;

@end

