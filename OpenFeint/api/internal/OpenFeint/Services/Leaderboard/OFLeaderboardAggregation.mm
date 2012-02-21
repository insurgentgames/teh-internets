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
#import "OFLeaderboardAggregation.h"
#import "OFLeaderboardService.h"
#import "OFResourceDataMap.h"

@implementation OFLeaderboardAggregation

@synthesize aggregateLeaderboardId,leaderboardPushingChangesId;

- (void)setAggregateLeaderboardId:(NSString*)value
{
	OFSafeRelease(aggregateLeaderboardId);
	aggregateLeaderboardId = [value retain];
}

- (void)setLeaderboardPushingChangesId:(NSString*)value
{
	OFSafeRelease(leaderboardPushingChangesId);
	leaderboardPushingChangesId = [value retain];
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
		dataMap->addField(@"aggregate_leaderboard_id", @selector(setAggregateLeaderboardId:));
		dataMap->addField(@"leaderboard_pushing_changes_id", @selector(setLeaderboardPushingChangesId:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"leaderboard_aggregation";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_leaderboard_aggregations_discovered";
}

- (void) dealloc
{
	self.aggregateLeaderboardId = nil;
	self.leaderboardPushingChangesId = nil;
	[super dealloc];
}

@end
