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
#import "OFLeaderboard.h"
#import "OFLeaderboardService.h"
#import "OFResourceDataMap.h"
#import "OFStringUtility.h"
#import "OFHighScore.h"
#import "OFUser.h"

@implementation OFLeaderboard

@synthesize name;

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow localUserScore:(OFHighScore*) locUserScore comparedUserScore:(OFHighScore*) compUserScore
{
	self = [super init];
	if (self != nil)
	{	
		name = [[NSString stringWithUTF8String:queryRow->getText("name")] retain];
		resourceId = [[NSString stringWithFormat:@"%s", queryRow->getText("id")] retain];
		descendingScoreOrder = queryRow->getInt("descending_sort_order") != 0;
		OFSafeRelease(localUserScore);
		localUserScore = [locUserScore retain];
		OFSafeRelease(comparedUserScore);
		comparedUserScore = [compUserScore retain];
	}
	return self;
}


- (void)setName:(NSString*)value
{
	OFSafeRelease(name);
	name = [value retain];
}

- (void)setDescendingScoreOrder:(NSString*)value
{
	descendingScoreOrder = [value boolValue];
}

- (void)setLocalUsersScore:(OFHighScore*)value
{
	OFSafeRelease(localUserScore);
	localUserScore = [value retain];
}

- (void)setComparedToUsersScore:(OFHighScore*)value
{
	OFSafeRelease(comparedUserScore);
	comparedUserScore = [value retain];
}

- (bool)isComparison
{
	return comparedUserScore != nil;
}

- (OFLeaderboardWinner)winner
{
	bool localRanked = ([[localUserScore resourceId] length] > 0);
	bool comparedRanked = ([[comparedUserScore resourceId] length] > 0);

	if (localRanked && !comparedRanked)
		return kLocalWinner;
	else if (comparedRanked && !localRanked)
		return kComparedWinner;
	else if (!localRanked && !comparedRanked)
		return kTied;
	
	int64_t localScore = [localUserScore score];
	int64_t comparedScore = [comparedUserScore score];
	
	if (descendingScoreOrder)
	{
		if (localScore > comparedScore)
			return kLocalWinner;
		else if (comparedScore > localScore)
			return kComparedWinner;	
	}
	else
	{
		if (localScore < comparedScore)
			return kLocalWinner;
		else if (comparedScore < localScore)
			return kComparedWinner;	
	}
		
	return kTied;
}

- (NSString*)localScoreText
{
	BOOL isRanked = ([[localUserScore resourceId] length] > 0);
	return !isRanked ? @"Not Ranked" : OFStringUtility::convertFromValidParameter(localUserScore.displayText).get();
}

- (NSString*)comparedScoreText
{
	BOOL isRanked = ([[comparedUserScore resourceId] length] > 0);
	return !isRanked ? @"Not Ranked" : OFStringUtility::convertFromValidParameter(comparedUserScore.displayText).get();
}

- (OFUser*)comparedToUser
{
	return [comparedUserScore user];
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
		dataMap->addField(@"descending_sort_order", @selector(setDescendingScoreOrder:));
		dataMap->addNestedResourceField(@"current_user_high_score", @selector(setLocalUsersScore:), nil, [OFHighScore class]);
		dataMap->addNestedResourceField(@"compared_user_high_score", @selector(setComparedToUsersScore:), nil, [OFHighScore class]);
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
	OFSafeRelease(localUserScore);
	OFSafeRelease(comparedUserScore);
	self.name = nil;
	[super dealloc];
}

@end
