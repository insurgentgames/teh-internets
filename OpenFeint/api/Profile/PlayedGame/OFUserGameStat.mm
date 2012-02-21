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
#import "OFUserGameStat.h"
#import "OFProfileService.h"
#import "OFResourceDataMap.h"

@implementation OFUserGameStat

@synthesize userHasGame, userId, userGamerScore, userFavoritedGame;

- (void)setUserHasGame:(NSString*)value
{
	userHasGame = [value boolValue];
}

- (void)setUserId:(NSString*)value
{
	OFSafeRelease(userId);
	userId = [value retain];
}

- (void)setUserGamerscore:(NSString*)value
{
	userGamerScore = [value intValue];
}

- (void)setUserFavoritedGame:(NSString*)value
{
	userFavoritedGame = [value boolValue];
}

+ (OFService*)getService;
{
	return nil;
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"user_has_game", @selector(setUserHasGame:));
		dataMap->addField(@"user_id", @selector(setUserId:));
		dataMap->addField(@"user_gamerscore", @selector(setUserGamerscore:));
		dataMap->addField(@"user_favorited_game", @selector(setUserFavoritedGame:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"user_game_stat";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_user_game_stat_discovered";
}

- (void) dealloc
{
	self.userId = nil;
	[super dealloc];
}

@end