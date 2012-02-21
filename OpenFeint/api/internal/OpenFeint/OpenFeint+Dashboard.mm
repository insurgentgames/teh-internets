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

#import "OpenFeint+Dashboard.h"
#import "OpenFeint+Private.h"
#import "OFSelectChatRoomDefinitionController.h"
#import "OFControllerLoader.h"
#import "OFApplicationDescriptionController.h"

const NSString* OpenFeintDashBoardTabNowPlaying = @"GameProfile";
const NSString* OpenFeintDashBoardTabMyFeint = @"MyFeint";
const NSString* OpenFeintDashBoardTabGames = @"GameDiscovery";

const NSString* OpenFeintControllerAchievementsList = @"AchievementList";
const NSString* OpenFeintControllerLeaderboardsList = @"Leaderboard";
const NSString* OpenFeintControllerChallengesList = @"ChallengeList";
const NSString* OpenFeintControllerFindFriends = @"ImportFriends";
const NSString* OpenFeintControllerWhosPlaying = @"WhosPlaying";
const NSString* OpenFeintControllerHighScores = @"HighScore";

@implementation OpenFeint (Dashboard)

+ (void)launchDashboardWithWhosPlayingPage
{
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andController:OpenFeintControllerWhosPlaying];
}

+ (void)launchDashboardWithAchievementsPage
{
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andController:OpenFeintControllerAchievementsList];
}

+ (void)launchDashboardWithListLeaderboardsPage;
{
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andController:OpenFeintControllerLeaderboardsList];
}

+ (void)launchDashboardWithHighscorePage:(NSString*)leaderboardId;
{
	NSArray* controllers = [[[NSArray alloc] initWithObjects:OpenFeintControllerLeaderboardsList,leaderboardId,nil] autorelease];
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andControllers:controllers];
}

+ (void)launchDashboardWithChallengesPage;
{
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andController:OpenFeintControllerChallengesList];
}

+ (void)launchDashboardWithFindFriendsPage;
{
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabMyFeint andController:OpenFeintControllerFindFriends];
}

+ (void)launchDashboardWithListGlobalChatRoomsPage
{
	OFSelectChatRoomDefinitionController* chatController = (OFSelectChatRoomDefinitionController*)OFControllerLoader::load(@"SelectChatRoomDefinition");
	chatController.includeGlobalRooms = YES;
	chatController.includeDeveloperRooms = NO;
	chatController.includeApplicationRooms = NO;
	NSArray* controllers = [NSArray arrayWithObject:chatController];
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andControllers:controllers];
}

+ (void)launchDashboardWithListGameChatRoomsPage
{
	OFSelectChatRoomDefinitionController* chatController = (OFSelectChatRoomDefinitionController*)OFControllerLoader::load(@"SelectChatRoomDefinition");
	chatController.includeGlobalRooms = NO;
	chatController.includeDeveloperRooms = YES;
	chatController.includeApplicationRooms = YES;
	NSArray* controllers = [NSArray arrayWithObject:chatController];
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andControllers:controllers];
}

+ (void)launchDashboardWithiPurchasePage:(NSString*)clientApplicationId
{
	OFApplicationDescriptionController* iPurchaseController = [OFApplicationDescriptionController applicationDescriptionForId:clientApplicationId appBannerPlacement:@"directDashboardLaunch"];
	NSArray* controllers = [NSArray arrayWithObject:iPurchaseController];
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabGames andControllers:controllers];
}

+ (void)launchDashboardWithSwitchUserPage
{
	NSArray* controllers = [NSArray arrayWithObject:OFControllerLoader::load(@"UseNewOrOldAccount")];
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabMyFeint andControllers:controllers];
}

@end