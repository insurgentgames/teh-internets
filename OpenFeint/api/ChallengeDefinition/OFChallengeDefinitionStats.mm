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
#import "OFChallengeDefinitionStats.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionService.h"
#import "OFResourceDataMap.h"

@implementation OFChallengeDefinitionStats

@synthesize challengeDefinition, localUsersWins, localUsersLosses, localUsersTies, comparedUsersWins, comparedUsersLosses, comparison;

- (void)setChallengeDefinition:(OFChallengeDefinition*)value
{
	if (value != challengeDefinition)
	{
		OFSafeRelease(challengeDefinition);
		challengeDefinition = [value retain];
	}
}

- (void)setLocalUsersWins:(NSString*)value
{
	localUsersWins = [value intValue];
}

- (void)setLocalUsersLosses:(NSString*)value
{
	localUsersLosses = [value intValue];
}

- (void)setLocalUsersTies:(NSString*)value
{
	localUsersTies = [value intValue];
}

- (void)setComparedUsersWins:(NSString*)value
{
	if (value && [value length] > 0)
	{
		comparison = YES;
		comparedUsersWins = [value intValue];
	}
	else
	{
		comparedUsersWins = 0;
	}
}

- (void)setComparedUsersLosses:(NSString*)value
{
	if (value && [value length] > 0)
	{
		comparison = YES;
		comparedUsersLosses = [value intValue];
	}
	else
	{
		comparedUsersLosses = 0;
	}
}

+ (OFService*)getService;
{
	return [OFChallengeDefinitionService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addNestedResourceField(@"challenge_definition", @selector(setChallengeDefinition:), nil, [OFChallengeDefinition class]);
		dataMap->addField(@"local_users_wins", @selector(setLocalUsersWins:), nil);
		dataMap->addField(@"local_users_losses", @selector(setLocalUsersLosses:), nil);
		dataMap->addField(@"local_users_ties", @selector(setLocalUsersTies:), nil);
		dataMap->addField(@"compared_users_wins", @selector(setComparedUsersWins:), nil);
		dataMap->addField(@"compared_users_losses", @selector(setComparedUsersLosses:), nil);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"challenge_definition_stats";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_challenge_definition_stats_discovered";
}

- (void) dealloc
{
	OFSafeRelease(challengeDefinition);
	[super dealloc];
}

@end
