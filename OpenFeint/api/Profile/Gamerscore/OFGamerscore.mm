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
#import "OFGamerscore.h"
#import "OFProfileService.h"
#import "OFResourceDataMap.h"

@implementation OFGamerscore

@synthesize userId, gamerscore;

- (void)setUserId:(NSString*)value
{
	userId = [value intValue];
}

- (void)setGamerscore:(NSString*)value
{
	gamerscore = [value intValue];
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
		dataMap->addField(@"user_id", @selector(setUserId:));
		dataMap->addField(@"gamerscore", @selector(setGamerscore:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"gamerscore";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_gamerscore_discovered";
}

- (void) dealloc
{
	[super dealloc];
}

@end