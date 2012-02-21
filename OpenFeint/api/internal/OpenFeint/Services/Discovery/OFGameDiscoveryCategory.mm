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
#import "OFGameDiscoveryCategory.h"
#import "OFGameDiscoveryService.h"
#import "OFResourceDataMap.h"

@implementation OFGameDiscoveryCategory
		
@synthesize iconUrl, name, subtext, secondaryText, targetDiscoveryActionName, targetDiscoveryPageTitle;

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"icon_url", @selector(setIconUrl:));
		dataMap->addField(@"name", @selector(setName:));
		dataMap->addField(@"subtext", @selector(setSubtext:));
		dataMap->addField(@"secondary_text", @selector(setSecondaryText:));
		dataMap->addField(@"target_discovery_action_name", @selector(setTargetDiscoveryActionName:));
		dataMap->addField(@"target_discovery_page_title", @selector(setTargetDiscoveryPageTitle:));								
	}
	
	return dataMap.get();
}

+ (OFService*)getService
{
	return [OFGameDiscoveryService sharedInstance];
}

+ (NSString*)getResourceName
{
	return @"game_discovery_category";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	self.iconUrl = nil; 
	self.name = nil;
	self.subtext = nil;
	self.secondaryText = nil;
	self.targetDiscoveryActionName = nil;
	self.targetDiscoveryPageTitle = nil;
	
	[super dealloc];
}

@end
