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
#import "OFPlayedGame.h"
#import "OFProfileService.h"
#import "OFResourceDataMap.h"
#import "OFUserGameStat.h"
#import "OpenFeint+UserOptions.h"

@implementation OFPlayedGame

@synthesize name, iconUrl, clientApplicationId, totalGamerscore, friendsWithApp, userGameStats, iTunesAppStoreUrl, favorite, review;

- (void)setName:(NSString*)value
{
	OFSafeRelease(name);
	name = [value retain];
}

- (void)setIconUrl:(NSString*)value
{
	OFSafeRelease(iconUrl);
	iconUrl = [value retain];
}

- (void)setClientApplicationId:(NSString*)value
{
	OFSafeRelease(clientApplicationId);
	clientApplicationId = [value retain];
}

- (void)setUserGameStats:(NSMutableArray*)value
{
	OFSafeRelease(userGameStats);
	userGameStats = [value retain];
}

- (void)setTotalGamerscore:(NSString*)value
{
	totalGamerscore = [value intValue];
}

- (void)setFriendsWithApp:(NSString*)value
{
	friendsWithApp = [value intValue];
}

- (void)setITunesAppStoreUrl:(NSString*)value
{
	OFSafeRelease(iTunesAppStoreUrl);
	iTunesAppStoreUrl = [value retain];
}

- (void)setFavorite:(NSString*)value
{
	favorite = [value boolValue];
}

- (void)setReview:(NSString*)value
{
	if (review != value)
	{
		OFSafeRelease(review);
		review = [value retain];
	}
}

+ (OFService*)getService;
{
	return [OFProfileService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name", @selector(setName:));
		dataMap->addField(@"icon_url", @selector(setIconUrl:));
		dataMap->addField(@"client_application_id", @selector(setClientApplicationId:));
		dataMap->addField(@"total_gamerscore", @selector(setTotalGamerscore:));
		dataMap->addField(@"friends_with_app", @selector(setFriendsWithApp:));
		dataMap->addNestedResourceArrayField(@"user_game_stats", @selector(setUserGameStats:));
		dataMap->addField(@"i_tunes_app_store_url", @selector(setITunesAppStoreUrl:));
		dataMap->addField(@"favorite",				@selector(setFavorite:));
		dataMap->addField(@"review",				@selector(setReview:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"played_game";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_played_game_discovered";
}

- (OFUserGameStat*)getLocalUsersGameStat
{
	for (OFUserGameStat* stat in userGameStats)
	{
		if ([stat.userId isEqualToString:[OpenFeint lastLoggedInUserId]])
		{
			return stat;
		}
	}
	return nil;
}

- (BOOL)isOwnedByLocalUser
{
	OFUserGameStat* localUserGameStat = [self getLocalUsersGameStat];
	return localUserGameStat ? localUserGameStat.userHasGame : NO;
}

- (void) dealloc
{
	OFSafeRelease(iconUrl);
	OFSafeRelease(name);
	OFSafeRelease(userGameStats);
	OFSafeRelease(clientApplicationId);
	OFSafeRelease(iTunesAppStoreUrl);
	OFSafeRelease(review);
	[super dealloc];
}

@end