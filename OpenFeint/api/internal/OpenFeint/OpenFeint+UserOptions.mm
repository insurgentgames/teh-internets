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


#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+NSNotification.h"
#import "OFLinkSocialNetworksController.h"
#import "OFGameProfilePageInfo.h"
#import "OFUser.h"
#import "OFProvider.h"

static const NSString* OpenFeintUserOptionShouldAutomaticallyPromptLogin = @"OpenFeintSettingShouldAutomaticallyPromptLogin";
static const NSString* OpenFeintUserOptionLastLoggedInUserHasSetName = @"OpenFeintSettingLastLoggedInUserHasSetName";
static const NSString* OpenFeintUserOptionLastLoggedInUserHadSetNameOnBootup = @"OpenFeintSettingLastLoggedInUserHadSetNameOnBootup";
static const NSString* OpenFeintUserOptionLastLoggedInUserNonDeviceCredential = @"OpenFeintSettingLastLoggedInUserHasNonDeviceCredential";

static const NSString* OpenFeintUserOptionLastLoggedInUserHttpBasicCredential = @"OpenFeintSettingLastLoggedInUserHasHttpBasicCredential";

static const NSString* OpenFeintUserOptionLastLoggedInUserFbconnectCredential = @"OpenFeintSettingLastLoggedInUserHasFbconnectCredential";

static const NSString* OpenFeintUserOptionLastLoggedInUserTwitterCredential = @"OpenFeintSettingLastLoggedInUserHasTwitterCredential";

static const NSString* OpenFeintUserOptionLastLoggedInUserIsNewUser = @"OpenFeintSettingsLastLoggedInUserIsNewUser";
static const NSString* OpenFeintUserOptionUserFeintApproval = @"OpenFeintUserOptionUserFeintApproval";
static const NSString* OpenFeintUserOptionClientApplicationId = @"OpenFeintSettingClientApplicationId";
static const NSString* OpenFeintUserOptionInitialDashboardScreen = @"OpenFeintUserOptionInitialDashboardScreen";
static const NSString* OpenFeintUserOptionClientApplicationIconUrl = @"OpenFeintSettingClientApplicationIconUrl";
static const NSString* OpenFeintUserOptionUnviewedChallengesCount = @"OpenFeintSettingUnviewedChallengesCount";
static const NSString* OpenFeintUserOptionUserHasRememberedChoiceForNotifications = @"OpenFeintUserOptionUserHasRememberedChoiceForNotifications";
static const NSString* OpenFeintUserOptionUserAllowsNotifications = @"OpenFeintUserOptionUserAllowsNotifications";
static const NSString* OpenFeintUserOptionLastLoggedInUserHasChatEnabled = @"OpenFeintUserOptionLastLoggedInUserHasChatEnabled";
static const NSString* OpenFeintUserOptionLoggedInUserSharesOnlineStatus = @"OpenFeintUserOptionLoggedInUserSharesOnlineStatus";
static const NSString* OpenFeintUserOptionLocalGameInfo = @"OpenFeintUserOptionLocalGameInfo";
static const NSString* OpenFeintUserOptionLocalUser = @"OpenFeintUserOptionLocalUser";
static const NSString* OpenFeintUserOptionPendingFriendsCount = @"OpenFeintSettingPendingFriendsCount";
static const NSString* OpenFeintUserOptionUnreadInboxCount = @"OpenFeintUserOptionUnreadInboxCount";

static const NSString* OpenFeintUserOptionShouldWarnOnIncompleteDelegates = @"OpenFeintUserOptionShouldWarnOnIncompleteDelegates";

static const NSString* OpenFeintUserOptionDistanceUnit = @"OpenFeintUserOptionDistanceUnit";

static const NSString* OpenFeintUserOptionLastAnnouncementDate = @"OpenFeintLastAnnouncementDate_UserID";
static const NSString* OpenFeintUserOptionSuggestionsForumId = @"OpenFeintUserOptionSuggestionsForumId";
static const NSString* OpenFeintUserOptionDoneWithGetTheMost = @"OpenFeintUserOptionDoneWithGetTheMost";


@implementation OpenFeint (UserOptions)

+ (void)intiailizeUserOptions
{
	NSData* user = [NSKeyedArchiver archivedDataWithRootObject:[OFUser invalidUser]];
	NSData* game = [NSKeyedArchiver archivedDataWithRootObject:[OFGameProfilePageInfo defaultInfo]];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"YES", OpenFeintUserOptionShouldAutomaticallyPromptLogin,
								 @"YES", OpenFeintUserOptionLastLoggedInUserHasChatEnabled,
								 user, OpenFeintUserOptionLocalUser,
								 game, OpenFeintUserOptionLocalGameInfo,
								 nil
								 ];

	[defaults registerDefaults:appDefaults];
}

+ (void)setDontAutomaticallyPromptLogin
{
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:OpenFeintUserOptionShouldAutomaticallyPromptLogin];
}

+ (bool)shouldAutomaticallyPromptLogin
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:OpenFeintUserOptionShouldAutomaticallyPromptLogin];
}

+ (void)setUserApprovedFeint
{
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:OpenFeintUserOptionUserFeintApproval];
}

+ (void)setUserDeniedFeint
{
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:OpenFeintUserOptionUserFeintApproval];
}

+ (bool)hasUserSetFeintAccess
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:OpenFeintUserOptionUserFeintApproval] != nil;
}

+ (bool)_hasUserApprovedFeint
{
	return [[[NSUserDefaults standardUserDefaults] stringForKey:OpenFeintUserOptionUserFeintApproval] isEqualToString:@"YES"];
}

+ (void)_resetHasUserSetFeintAccess
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:OpenFeintUserOptionUserFeintApproval];
	[OpenFeint setLocalUser:[OFUser invalidUser]];
	[[OpenFeint provider] destroyLocalCredentials];
}

+ (void)setShouldWarnOnIncompleteDelegates:(BOOL)shouldWarnOnIncompleteDelegates
{
	[[NSUserDefaults standardUserDefaults] setBool:shouldWarnOnIncompleteDelegates forKey:OpenFeintUserOptionShouldWarnOnIncompleteDelegates];
}

+ (BOOL)shouldWarnOnIncompleteDelegates
{
#if defined(_DEBUG) || defined(DEBUG)
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionShouldWarnOnIncompleteDelegates];
	// If the setting isn't there, then we should warn.  Otherwise, do what it says.
	return !asNumber || [asNumber boolValue];
#else
	return false;
#endif
}

+ (void)logoutUser
{
	OFRetainedPtr<NSString> userId = [OpenFeint lastLoggedInUserId];
	[OpenFeint setLocalUser:[OFUser invalidUser]];
	[[OpenFeint provider] destroyLocalCredentials];
	[OpenFeint setUserDeniedFeint];
	[OpenFeint switchToOfflineDashboard];
	OpenFeint* instance = [OpenFeint sharedInstance];
	instance->mSuccessfullyBootstrapped = NO;
	[OpenFeint invalidateBootstrap];
	[OpenFeint setDoneWithGetTheMost:NO];
	[OFLinkSocialNetworksController invalidateSessionSeenLinkSocialNetworksScreen];
	OF_OPTIONALLY_INVOKE_DELEGATE_WITH_PARAMETER([OpenFeint getDelegate], userLoggedOut:, (id)userId.get());	
}

+ (NSString*)lastLoggedInUserId
{
	return [[OpenFeint localUser] resourceId];
}

+ (NSString*)lastLoggedInUserProfilePictureUrl
{
	return [[OpenFeint localUser] profilePictureUrl];
}

+ (BOOL)lastLoggedInUserUsesFacebookProfilePicture
{
	return [[OpenFeint localUser] usesFacebookProfilePicture];
}

+ (NSString*)lastLoggedInUserName
{
	return [[OpenFeint localUser] name];
}

+ (void)setLoggedInUserHasSetName:(BOOL)hasSetName
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasSetName] forKey:OpenFeintUserOptionLastLoggedInUserHasSetName];
}

+ (BOOL)lastLoggedInUserHasSetName
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserHasSetName];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserHadFriendsOnBootup:(BOOL)hadFriends
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hadFriends] forKey:OpenFeintUserOptionLastLoggedInUserHadSetNameOnBootup];
}

+ (BOOL)lastLoggedInUserHadFriendsOnBootup
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserHadSetNameOnBootup];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserSharesOnlineStatus:(BOOL)loggedInUserSharesOnlineStatus
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:loggedInUserSharesOnlineStatus] forKey:OpenFeintUserOptionLoggedInUserSharesOnlineStatus];
}

+ (BOOL)loggedInUserSharesOnlineStatus
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLoggedInUserSharesOnlineStatus];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserHasNonDeviceCredential:(BOOL)hasNonDeviceCredential
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasNonDeviceCredential] forKey:OpenFeintUserOptionLastLoggedInUserNonDeviceCredential];
}

+ (BOOL)loggedInUserHasNonDeviceCredential
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserNonDeviceCredential];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserHasHttpBasicCredential:(BOOL)hasHttpBasicCredential
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasHttpBasicCredential] forKey:OpenFeintUserOptionLastLoggedInUserHttpBasicCredential];
}

+ (BOOL)loggedInUserHasHttpBasicCredential
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserHttpBasicCredential];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserHasFbconnectCredential:(BOOL)hasFbconnectCredential
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasFbconnectCredential] forKey:OpenFeintUserOptionLastLoggedInUserFbconnectCredential];
}

+ (BOOL)loggedInUserHasFbconnectCredential
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserFbconnectCredential];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserHasTwitterCredential:(BOOL)hasTwitterCredential
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasTwitterCredential] forKey:OpenFeintUserOptionLastLoggedInUserTwitterCredential];
}

+ (BOOL)loggedInUserHasTwitterCredential
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserTwitterCredential];
	return asNumber && [asNumber boolValue];
}

+ (void)setLoggedInUserIsNewUser:(BOOL)isNewUser
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isNewUser] forKey:OpenFeintUserOptionLastLoggedInUserIsNewUser];
}

+ (BOOL)loggedInUserIsNewUser
{
	NSNumber* asNumber = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLastLoggedInUserIsNewUser];
	return asNumber && [asNumber boolValue];
}

+ (void)setClientApplicationId:(NSString*)clientApplicationId
{
	[[NSUserDefaults standardUserDefaults] setObject:clientApplicationId forKey:OpenFeintUserOptionClientApplicationId];
}

+ (NSString*)clientApplicationId
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:OpenFeintUserOptionClientApplicationId];
}

+ (void)setInitialDashboardScreen:(NSString*)initialDashboardScreen
{
	[[NSUserDefaults standardUserDefaults] setObject:initialDashboardScreen forKey:OpenFeintUserOptionInitialDashboardScreen];
}

+ (NSString*)initialDashboardScreen
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:OpenFeintUserOptionInitialDashboardScreen];
}

+ (void)setClientApplicationIconUrl:(NSString*)clientApplicationIconUrl
{
	[[NSUserDefaults standardUserDefaults] setObject:clientApplicationIconUrl forKey:OpenFeintUserOptionClientApplicationIconUrl];
}

+ (NSString*)clientApplicationIconUrl
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:OpenFeintUserOptionClientApplicationIconUrl];
}

+ (void)setUnviewedChallengesCount:(NSInteger)numChallenges
{
	[[NSUserDefaults standardUserDefaults] setInteger:numChallenges forKey:OpenFeintUserOptionUnviewedChallengesCount];
	[OpenFeint postUnviewedChallengeCountChangedTo:numChallenges];
	[OpenFeint updateApplicationBadge];
}

+ (NSInteger)unviewedChallengesCount
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserOptionUnviewedChallengesCount];
}

+ (void)setPendingFriendsCount:(NSInteger)numFriends
{
	[[NSUserDefaults standardUserDefaults] setInteger:numFriends forKey:OpenFeintUserOptionPendingFriendsCount];
	[OpenFeint postPendingFriendsCountChangedTo:numFriends];
}

+ (NSInteger)pendingFriendsCount
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserOptionPendingFriendsCount];
}

+ (void)setUnreadInboxCount:(NSInteger)unread
{
	[[NSUserDefaults standardUserDefaults] setInteger:unread forKey:OpenFeintUserOptionUnreadInboxCount];
	[OpenFeint postUnreadInboxCountChangedTo:unread];
}

+ (NSInteger)unreadInboxCount
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserOptionUnreadInboxCount];
}

+ (void)setUserHasRememberedChoiceForNotifications:(BOOL)hasRememberedChoice
{
	[[NSUserDefaults standardUserDefaults] setBool:hasRememberedChoice
											forKey:OpenFeintUserOptionUserHasRememberedChoiceForNotifications];
}

+ (BOOL)userHasRememberedChoiceForNotifications
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:OpenFeintUserOptionUserHasRememberedChoiceForNotifications];
}

+ (void)setUserAllowsNotifications:(BOOL)allowed
{
	[[NSUserDefaults standardUserDefaults] setBool:allowed
											forKey:OpenFeintUserOptionUserAllowsNotifications];
}

+ (BOOL)userAllowsNotifications
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:OpenFeintUserOptionUserAllowsNotifications];
}

+ (void)setLoggedInUserHasChatEnabled:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:OpenFeintUserOptionLastLoggedInUserHasChatEnabled];
}

+ (BOOL)loggedInUserHasChatEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:OpenFeintUserOptionLastLoggedInUserHasChatEnabled];
}

+ (BOOL)appHasAchievements {
	return [[OpenFeint localGameProfileInfo] hasAchievements];
}

+ (BOOL)appHasChallenges {
	return [[OpenFeint localGameProfileInfo] hasChallenges];
}

+ (BOOL)appHasLeaderboards {
	return [[OpenFeint localGameProfileInfo] hasLeaderboards];
}

+ (BOOL)appHasFeaturedApplication {
	return [[OpenFeint localGameProfileInfo] hasFeaturedApplication];
}

+ (void)setLocalGameProfileInfo:(OFGameProfilePageInfo*)profileInfo
{
	NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:profileInfo];
	[[NSUserDefaults standardUserDefaults] setObject:encoded forKey:OpenFeintUserOptionLocalGameInfo];
}

+ (OFGameProfilePageInfo*)localGameProfileInfo
{
	NSData* encoded = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLocalGameInfo];
	return (OFGameProfilePageInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:encoded];
}

+ (void)setLocalUser:(OFUser*)user
{
	OFUser* previousUser = [self localUser];

	NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:user];
	[[NSUserDefaults standardUserDefaults] setObject:encoded forKey:OpenFeintUserOptionLocalUser];

	OpenFeint* instance = [OpenFeint sharedInstance];
	instance->mCachedLocalUser = [user retain];

	[OpenFeint postUserChangedNotificationFromUser:previousUser toUser:user];
	[previousUser release];
}

+ (OFUser*)localUser
{
	OpenFeint* instance = [OpenFeint sharedInstance];

	if(instance->mCachedLocalUser == nil)
	{
		NSData* encoded = [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionLocalUser];
		instance->mCachedLocalUser = [(OFUser*)[NSKeyedUnarchiver unarchiveObjectWithData:encoded] retain];
	}
	
	return instance->mCachedLocalUser;
}

+ (void)loggedInUserChangedNameTo:(NSString*)name
{
	[OpenFeint setLoggedInUserHasSetName:YES];
	OFUser* user = [self localUser];
	user.name = name;
	[self setLocalUser:user];
}

+ (void)setUserDistanceUnit:(OFUserDistanceUnitType)distanceUnit
{
	[[NSUserDefaults standardUserDefaults] setInteger:distanceUnit forKey:OpenFeintUserOptionDistanceUnit];
}

+ (OFUserDistanceUnitType)userDistanceUnit
{
	return (OFUserDistanceUnitType)[[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserOptionDistanceUnit];
}

+ (NSDate*)lastAnnouncementDateForLocalUser
{
	NSString* key = [NSString stringWithFormat:@"%@%@", OpenFeintUserOptionLastAnnouncementDate, [OpenFeint lastLoggedInUserId]];
	NSDate* lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (!lastDate)
	{
		lastDate = [NSDate dateWithTimeIntervalSinceNow:0];
		[[NSUserDefaults standardUserDefaults] setObject:lastDate forKey:key];
	}
	
	return lastDate;
}

+ (void)setLastAnnouncementDateForLocalUser:(NSDate*)date
{
	NSString* key = [NSString stringWithFormat:@"%@%@", OpenFeintUserOptionLastAnnouncementDate, [OpenFeint lastLoggedInUserId]];
	
	NSDate* currentDate = [OpenFeint lastAnnouncementDateForLocalUser];
	if ([currentDate laterDate:date] == date)
	{
		[[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
	}
}

+ (NSString*)suggestionsForumId
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:OpenFeintUserOptionSuggestionsForumId];
}

+ (void)setSuggestionsForumId:(NSString*)forumId
{
	[[NSUserDefaults standardUserDefaults] setObject:forumId forKey:OpenFeintUserOptionSuggestionsForumId];
}

+ (void)setDoneWithGetTheMost:(BOOL)enabled
{
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:OpenFeintUserOptionDoneWithGetTheMost];
}

+ (BOOL)doneWithGetTheMost
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:OpenFeintUserOptionDoneWithGetTheMost];
}

@end
