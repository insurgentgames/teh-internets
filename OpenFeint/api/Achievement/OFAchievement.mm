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
#import "OFAchievement.h"
#import "OFAchievementService.h"
#import "OFResourceDataMap.h"
#import "OFSqlQuery.h" 

@implementation OFAchievement

@synthesize title, description, gamerscore, iconUrl, isSecret, isUnlocked, isUnlockedByComparedToUser, comparedToUserId, unlockDate, endVersion, startVersion, position;

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow
{
	self = [super init];
	if (self != nil)
	{	
		OFSafeRelease(title);
		title = [[NSString stringWithUTF8String:queryRow->getText("title")] retain];
		OFSafeRelease(description);
		description = [[NSString stringWithUTF8String:queryRow->getText("description")] retain];
		gamerscore = queryRow->getInt("gamerscore");
		OFSafeRelease(iconUrl);
		iconUrl = [[NSString stringWithFormat:@"%s", queryRow->getText("icon_file_name")] retain];
		isSecret = queryRow->getBool("is_secret");
		isUnlocked = queryRow->getBool("unlocked_date");
		OFSafeRelease(resourceId);
		resourceId = [[NSString stringWithFormat:@"%s", queryRow->getText("id")] retain];
		position = queryRow->getInt("position");
		//self.isUnlockedByComparedToUser = queryRow.getBool("is_unlocked_by_compared_to_user");
		//self.comparedToUserId = queryRow.getText("compared_to_user_id");
		//self.unlockDate = queryRow.getDate("unlock_date");
	}
	return self;
}

- (void)setTitle:(NSString*)value
{
	OFSafeRelease(title);
	title = [value retain];
}

- (void)setDescription:(NSString*)value
{
	OFSafeRelease(description);
	description = [value retain];
}

- (void)setGamerscore:(NSString*)value
{
	gamerscore = [value intValue];
}

- (void)setPosition:(NSString*)value
{
	position = [value intValue];
}

- (void)setIconUrl:(NSString*)value
{
	OFSafeRelease(iconUrl);
	iconUrl = [value retain];
}

- (void)setIsSecret:(NSString*)value
{
	isSecret = [value boolValue];
}

- (void)setIsUnlocked:(NSString*)value
{
	isUnlocked = [value boolValue];
}

- (void)setIsUnlockedByComparedToUser:(NSString*)value
{
	isUnlockedByComparedToUser = [value boolValue];
}

- (void)setComparedToUserId:(NSString*)value
{
	comparedToUserId = [value retain];
}

- (void)setEndVersion:(NSString*)value
{
	OFSafeRelease(endVersion);
	endVersion = [value retain];
}

- (void)setStartVersion:(NSString*)value
{
	OFSafeRelease(startVersion);
	startVersion = [value retain];
}

- (void)setUnlockDate:(NSString*)value
{
	OFSafeRelease(unlockDate);
	
	if (value != nil)
	{
		NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];

		[dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss zzz"];
		NSMutableString* tmpDate = [[[NSMutableString alloc] initWithString:value] autorelease]; 
		if( [value length] == 19 )
		{
			[tmpDate appendString: @" GMT"];
		}
		unlockDate = [[dateFormatter dateFromString:tmpDate] retain];
	}
}

+ (OFService*)getService;
{
	return [OFAchievementService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"title", @selector(setTitle:));
		dataMap->addField(@"description", @selector(setDescription:));
		dataMap->addField(@"gamerscore", @selector(setGamerscore:));
		dataMap->addField(@"icon_url", @selector(setIconUrl:));
		dataMap->addField(@"is_secret", @selector(setIsSecret:));
		dataMap->addField(@"is_unlocked", @selector(setIsUnlocked:));
		dataMap->addField(@"is_unlocked_by_compared_to_user", @selector(setIsUnlockedByComparedToUser:));
		dataMap->addField(@"compared_to_user_id", @selector(setComparedToUserId:));
		dataMap->addField(@"unlock_date", @selector(setUnlockDate:));
		dataMap->addField(@"position", @selector(setPosition:));
		dataMap->addField(@"end_version", @selector(setEndVersion:));
		dataMap->addField(@"start_version", @selector(setStartVersion:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"achievement";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_achievement_discovered";
}

- (void) dealloc
{
	self.title = nil;
	self.description = nil;
	self.iconUrl = nil;
	self.unlockDate = nil;
	self.comparedToUserId = nil;
	self.startVersion = nil;
	self.endVersion = nil;

	[super dealloc];
}

@end
