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
#import "OFHighScore.h"
#import "OFHighScoreService.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"

@implementation OFHighScore

@synthesize user;
@synthesize score;
@synthesize rank;
@synthesize leaderboardId;
@synthesize latitude;
@synthesize longitude;
@synthesize distance;
@synthesize customData;

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow forUser:(OFUser*)hsUser rank:(NSUInteger)scoreRank
{
	self = [super init];
	if (self != nil)
	{	
		OFSafeRelease(user);
		user = [hsUser retain];
		leaderboardId = queryRow->getInt("leaderboard_id");
		score = queryRow->getInt64("score");
		const char* cDisplayText = queryRow->getText("display_text");
		if( cDisplayText != nil )
		{
			OFSafeRelease(displayText);
			displayText = [[NSString stringWithUTF8String:cDisplayText] retain];
		}

		const char* cCustomData = queryRow->getText("custom_data");
		if( cCustomData != nil )
		{
			OFSafeRelease(customData);
			customData = [[NSString stringWithUTF8String:cCustomData] retain];
		}
		
		rank = scoreRank;

		OFSafeRelease(resourceId);
		resourceId = @"1";	// arbitrary non-zero id
	}
	return self;
}

- (void)setUser:(OFUser*)value
{
	OFSafeRelease(user);
	user = [value retain];
}

- (void)setScore:(NSString*)value
{
	score = [value longLongValue];
}

- (void)setRank:(NSString*)value
{
	rank = [value integerValue];
}

- (void)setLeaderboardId:(NSString*)value
{
	leaderboardId = [value integerValue];
}

- (void)setDisplayText:(NSString*)value
{
	OFSafeRelease(displayText);
	if (value && ![value isEqualToString:@""])
	{
		displayText = [value retain];
	}
}

- (NSString*)displayText
{
	if (displayText)
	{
		return displayText;
	}
	else
	{
		return [NSString stringWithFormat:@"%qi", score];
	}
}

- (void)setCustomData:(NSString*)value
{
	OFSafeRelease(customData);
	if (value && ![value isEqualToString:@""])
	{
		customData = [value retain];
	}
}

- (NSString*)customData
{
	return customData;
}

- (void) setLatitude:(NSString*)value
{
	latitude = [value doubleValue];
}

- (void) setLongitude:(NSString*)value
{
	longitude = [value doubleValue];
}

- (void) setDistance:(NSString*)value
{
	distance = [value doubleValue];
}

+ (OFService*)getService;
{
	return [OFHighScoreService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"score",				@selector(setScore:));
		dataMap->addField(@"rank",				@selector(setRank:));
		dataMap->addField(@"leaderboard_id",	@selector(setLeaderboardId:));
		dataMap->addField(@"display_text",		@selector(setDisplayText:));
		dataMap->addField(@"custom_data",		@selector(setCustomData:));
		dataMap->addField(@"lat",				@selector(setLatitude:));
		dataMap->addField(@"lng",				@selector(setLongitude:));
		dataMap->addField(@"distance",			@selector(setDistance:));
		dataMap->addNestedResourceField(@"user", @selector(setUser:), nil, [OFUser class]);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"high_score";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_high_score_discovered";
}

- (void) dealloc
{
	OFSafeRelease(user);
	OFSafeRelease(displayText);
	OFSafeRelease(customData);
	[super dealloc];
}

@end
