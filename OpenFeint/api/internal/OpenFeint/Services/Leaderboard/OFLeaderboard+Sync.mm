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

#import "OFLeaderboard+Sync.h"
#import "OFDependencies.h"
#import "OFResourceDataMap.h"
#import "OFLeaderboardService.h"

@implementation OFLeaderboard_Sync

@synthesize name, active, allowPostingLowerScores, descendingSortOrder, isAggregate, reachedAt, score, endVersion, startVersion, visible, displayText, customData;

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow
{
	self = [super init];
	if (self != nil)
	{	
		resourceId = [[NSString stringWithFormat:@"%s", queryRow->getText("id")] retain];
		name = [[NSString stringWithFormat:@"%s", queryRow->getText("name")] retain];
		active = queryRow->getBool("active");
		allowPostingLowerScores = queryRow->getBool("allow_posting_lower_scores");
		descendingSortOrder = queryRow->getBool("descending_sort_order");
		isAggregate = queryRow->getBool("is_aggregate");
		endVersion = [[NSString stringWithFormat:@"%s", queryRow->getText("end_version")] retain];
		startVersion = [[NSString stringWithFormat:@"%s", queryRow->getText("start_version")] retain];
		visible = queryRow->getBool("visible");
	}
	return self;
}


- (void)setName:(NSString*)value
{
	OFSafeRelease(name);
	name = [value retain];
}

- (void)setActive:(NSString*)value
{
	active = [value boolValue];
}

- (void)setAllowPostingLowerScores:(NSString*)value
{
	allowPostingLowerScores = [value boolValue];
}

- (void)setDescendingSortOrder:(NSString*)value
{
	descendingSortOrder = [value boolValue];
}

- (void)setIsAggregate:(NSString*)value
{
	isAggregate = [value boolValue];
}

- (void)setReachedAt:(NSString*)value
{
	OFSafeRelease(reachedAt);
	
	if (value != nil)
	{
		NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
		
		[dateFormatter setDateFormat:@"yyy-MM-dd HH:mm:ss zzz"];
		NSMutableString* tmpDate = [[[NSMutableString alloc] initWithString:value] autorelease]; 
		if( [value length] == 19 )
		{
			[tmpDate appendString: @" GMT"];
		}
		reachedAt = [[dateFormatter dateFromString:tmpDate] retain];
	}
}

- (void)setScore:(NSString*)value
{
	score = [value longLongValue];
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

- (void)setDisplayText:(NSString*)value
{
	OFSafeRelease(displayText);
	displayText = [value retain];
}

- (void)setCustomData:(NSString*)value
{
	OFSafeRelease(customData);
	customData = [value retain];
}

- (void)setVisible:(NSString*)value
{
	visible = [value boolValue];
}

+ (OFService*)getService;
{
	return [OFLeaderboardService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name", @selector(setName:));
		dataMap->addField(@"active", @selector(setActive:));
		dataMap->addField(@"allow_posting_lower_scores", @selector(setAllowPostingLowerScores:));
		dataMap->addField(@"descending_sort_order", @selector(setDescendingSortOrder:));
		dataMap->addField(@"is_aggregate", @selector(setIsAggregate:));
		dataMap->addField(@"reached_at", @selector(setReachedAt:));
		dataMap->addField(@"score", @selector(setScore:));
		dataMap->addField(@"end_version", @selector(setEndVersion:));
		dataMap->addField(@"start_version", @selector(setStartVersion:));
		dataMap->addField(@"visible", @selector(setVisible:));
		dataMap->addField(@"display_text", @selector(setDisplayText:));
		dataMap->addField(@"custom_data", @selector(setCustomData:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"leaderboard";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_leaderboard_discovered";
}

- (void) dealloc
{
	self.name = nil;
	self.startVersion = nil;
	self.endVersion = nil;
	self.reachedAt = nil;
	self.displayText = nil;
	self.customData = nil;
	[super dealloc];
}

@end
