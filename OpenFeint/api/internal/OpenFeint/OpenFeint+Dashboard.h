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

@interface OpenFeint (Dashboard)
+ (void)launchDashboardWithListLeaderboardsPage;
+ (void)launchDashboardWithHighscorePage:(NSString*)leaderboardId;
+ (void)launchDashboardWithAchievementsPage;
+ (void)launchDashboardWithChallengesPage;
+ (void)launchDashboardWithFindFriendsPage;
+ (void)launchDashboardWithWhosPlayingPage;
+ (void)launchDashboardWithListGlobalChatRoomsPage;
+ (void)launchDashboardWithListGameChatRoomsPage;
+ (void)launchDashboardWithiPurchasePage:(NSString*)clientApplicationId;
+ (void)launchDashboardWithSwitchUserPage;
@end

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Used make the intial dashboard tab the Current Game tab
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintDashBoardTabNowPlaying;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Used make the intial dashboard tab the My Feint tab
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintDashBoardTabMyFeint;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Used make the intial dashboard tab the Games tab
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintDashBoardTabGames;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Achievements List controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerAchievementsList;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Leaderboard List controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerLeaderboardsList;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Challenges List controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerChallengesList;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Find Friends controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerFindFriends;

////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	High Scores controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerHighScores;


////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @behavior	Who's Playing controller
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintControllerWhosPlaying;