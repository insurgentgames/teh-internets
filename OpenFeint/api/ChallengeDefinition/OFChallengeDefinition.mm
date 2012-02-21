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
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionService.h"
#import "OFResourceDataMap.h"

@implementation OFChallengeDefinition

@synthesize title, iconUrl, multiAttempt, clientApplicationId;

- (void)setTitle:(NSString*)value
{
	OFSafeRelease(title);
	title = [value retain];
}

- (void)setClientApplicationId:(NSString*)value
{
	if (clientApplicationId != value)
	{
		OFSafeRelease(clientApplicationId);
		clientApplicationId = [value retain];
	}
}

- (void)setIconUrl:(NSString*)value
{
	OFSafeRelease(iconUrl);
	iconUrl = [value retain];
}

- (void)setMultiAttempt:(NSString*)value
{
	multiAttempt = [value boolValue];
}

- (NSString*)getMultiAttemptAsString
{
	return [NSString stringWithFormat:@"%u", (uint)multiAttempt];
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
		dataMap->addField(@"name", @selector(setTitle:), @selector(title));
		dataMap->addField(@"client_application_id", @selector(setClientApplicationId:), @selector(clientApplicationId));
		dataMap->addField(@"icon_url", @selector(setIconUrl:), @selector(iconUrl));
		dataMap->addField(@"multi_attempt", @selector(setMultiAttempt:), @selector(getMultiAttemptAsString));
		
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"challenge_definition";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_challenge_definition_discovered";
}

- (void) dealloc
{
	OFSafeRelease(title);
	OFSafeRelease(clientApplicationId);
	OFSafeRelease(iconUrl);
	[super dealloc];
}

@end
