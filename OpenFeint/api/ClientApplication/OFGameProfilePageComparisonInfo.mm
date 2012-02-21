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
#import "OFGameProfilePageComparisonInfo.h"
#import "OFGameProfilePageInfo.h"
#import "OFResourceDataMap.h"

@implementation OFGameProfilePageComparisonInfo

@synthesize gameProfilePageInfo, 
			localUsersAchievementsScore,
			comparedUsersAchievementsScore, 
			localUsersChallengesScore, 
			comparedUsersChallengesScore, 
			localUsersLeaderboardsScore, 
			comparedUsersLeaderboardsScore;

- (void)setGameProfilePageInfo:(OFGameProfilePageInfo*)value
{
	if (gameProfilePageInfo != value)
	{
		OFSafeRelease(gameProfilePageInfo);
		gameProfilePageInfo = [value retain];
	}
}

- (void)setLocalUsersAchievementsScore:(NSString*)value
{
	localUsersAchievementsScore = [value intValue];
}

- (void)setComparedUsersAchievementsScore:(NSString*)value
{
	comparedUsersAchievementsScore = [value intValue];
}

- (void)setLocalUsersChallengesScore:(NSString*)value
{
	localUsersChallengesScore = [value intValue];
}

- (void)setComparedUsersChallengesScore:(NSString*)value
{
	comparedUsersChallengesScore = [value intValue];
}

- (void)setLocalUsersLeaderboardsScore:(NSString*)value
{
	localUsersLeaderboardsScore = [value intValue];
}

- (void)setComparedUsersLeaderboardsScore:(NSString*)value
{
	comparedUsersLeaderboardsScore = [value intValue];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addNestedResourceField(@"game_profile_page_info",	@selector(setGameProfilePageInfo:), nil, [OFGameProfilePageInfo class]);
		dataMap->addField(@"local_user_achievements_score", @selector(setLocalUsersAchievementsScore:), nil);
		dataMap->addField(@"compared_users_achievements_score", @selector(setComparedUsersAchievementsScore:), nil);
		dataMap->addField(@"local_users_challenges_score", @selector(setLocalUsersChallengesScore:), nil);
		dataMap->addField(@"compared_users_challenges_score", @selector(setComparedUsersChallengesScore:), nil);
		dataMap->addField(@"local_users_leaderboards_score", @selector(setLocalUsersLeaderboardsScore:), nil);
		dataMap->addField(@"compared_users_leaderboards_score", @selector(setComparedUsersLeaderboardsScore:), nil);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"game_profile_page_comparison_info";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(gameProfilePageInfo);
	[super dealloc];
}

@end