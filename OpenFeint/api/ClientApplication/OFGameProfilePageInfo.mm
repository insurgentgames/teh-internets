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
#import "OFGameProfilePageInfo.h"
#import "OFResourceDataMap.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"

@implementation OFGameProfilePageInfo

@synthesize name;
@synthesize shortName;
@synthesize iconUrl;
@synthesize hasChatRooms;
@synthesize hasLeaderboards;
@synthesize hasAchievements;
@synthesize hasChallenges;
@synthesize hasiPurchase;
@synthesize ownedByLocalPlayer;
@synthesize suggestionsForumId;
@synthesize hasFeaturedApplication;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self != nil)
	{
		resourceId = [[aDecoder decodeObjectForKey:@"resourceId"] retain];
		name = [[aDecoder decodeObjectForKey:@"name"] retain];
		shortName = [[aDecoder decodeObjectForKey:@"shortName"] retain];
		iconUrl = [[aDecoder decodeObjectForKey:@"iconUrl"] retain];
		hasChatRooms = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasChatRooms"] boolValue];
		hasLeaderboards = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasLeaderboards"] boolValue];
		hasAchievements = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasAchievements"] boolValue];
		hasChallenges = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasChallenges"] boolValue];
		hasiPurchase = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasiPurchase"] boolValue];
		ownedByLocalPlayer = [(NSNumber*)[aDecoder decodeObjectForKey:@"ownedByLocalPlayer"] boolValue];
		suggestionsForumId = [[aDecoder decodeObjectForKey:@"suggestionsForumId"] retain];
		hasFeaturedApplication = [(NSNumber*)[aDecoder decodeObjectForKey:@"hasFeaturedApplication"] boolValue];		
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:resourceId forKey:@"resourceId"];
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:shortName forKey:@"shortName"];
	[aCoder encodeObject:iconUrl forKey:@"iconUrl"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasChatRooms] forKey:@"hasChatRooms"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasLeaderboards] forKey:@"hasLeaderboards"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasAchievements] forKey:@"hasAchievements"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasChallenges] forKey:@"hasChallenges"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasiPurchase] forKey:@"hasiPurchase"];
	[aCoder encodeObject:[NSNumber numberWithBool:ownedByLocalPlayer] forKey:@"ownedByLocalPlayer"];
	[aCoder encodeObject:suggestionsForumId forKey:@"suggestionsForumId"];
	[aCoder encodeObject:[NSNumber numberWithBool:hasFeaturedApplication] forKey:@"hasFeaturedApplication"];
}

+ (id)defaultInfo
{
	OFGameProfilePageInfo* info = [[[OFGameProfilePageInfo alloc] init] autorelease];
	info->name = [[OpenFeint applicationDisplayName] retain];
	info->shortName = [[OpenFeint applicationShortDisplayName] retain];
	info->iconUrl = nil;
	info->hasChatRooms = NO;	
	info->hasLeaderboards = NO;
	info->hasAchievements = NO;
	info->hasChallenges = NO;
	info->hasiPurchase = NO;
	info->ownedByLocalPlayer = YES;
	info->suggestionsForumId = @"0";
	info->hasFeaturedApplication = NO;
	
	return info;
}

- (BOOL)isLocalGameInfo
{
	return [resourceId isEqualToString:[OpenFeint localGameProfileInfo].resourceId];
}

- (void)setName:(NSString*)value
{
	if (name != value)
	{
		OFSafeRelease(name);
		name = [value retain];
	}
}

- (void)setShortName:(NSString*)value
{
	if (shortName != value)
	{
		OFSafeRelease(shortName);
		shortName = [value retain];
	}
}

- (void)setIconUrl:(NSString*)value
{
	if (iconUrl != value)
	{
		OFSafeRelease(iconUrl);
		iconUrl = [value retain];
	}
}

- (void)setHasChatRooms:(NSString*)value
{
	hasChatRooms = [value boolValue];
}

- (void)setHasiPurchase:(NSString*)value
{
	hasiPurchase = [value boolValue];
}

- (void)setHasAchievements:(NSString*)value
{
	hasAchievements = [value boolValue];
}

- (void)setHasChallenges:(NSString*)value
{
	hasChallenges = [value boolValue];
}

- (void)setHasLeaderboards:(NSString*)value
{
	hasLeaderboards = [value boolValue];
}

- (void)setOwnedByLocalPlayer:(NSString*)value
{
	ownedByLocalPlayer = [value boolValue];
}

- (void)setSuggestionsForumId:(NSString*)value
{
	if (suggestionsForumId != value)
	{
		OFSafeRelease(suggestionsForumId);
		suggestionsForumId = [value retain];
	}
}

- (void)setHasFeaturedApplication:(NSString*)value
{
	hasFeaturedApplication = [value boolValue];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name",							@selector(setName:), nil);
		dataMap->addField(@"short_name",					@selector(setShortName:), nil);
		dataMap->addField(@"icon_url",						@selector(setIconUrl:), nil);
		dataMap->addField(@"has_chat_rooms",				@selector(setHasChatRooms:), nil);
		dataMap->addField(@"has_leaderboards",				@selector(setHasLeaderboards:), nil);
		dataMap->addField(@"has_challenges",				@selector(setHasChallenges:), nil);
		dataMap->addField(@"has_achievements",				@selector(setHasAchievements:), nil);
		dataMap->addField(@"has_ipurchase",					@selector(setHasiPurchase:), nil);
		dataMap->addField(@"is_owned_by_local_player",		@selector(setOwnedByLocalPlayer:), nil);
		dataMap->addField(@"suggestions_topic_id",			@selector(setSuggestionsForumId:), nil);
		dataMap->addField(@"has_featured_application",		@selector(setHasFeaturedApplication:), nil);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"game_profile_page_info";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(name);
	OFSafeRelease(shortName);
	OFSafeRelease(iconUrl);
	OFSafeRelease(suggestionsForumId);
	[super dealloc];
}

@end