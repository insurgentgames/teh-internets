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
#import "OFGameDiscoveryNewsItem.h"
#import "OFGameDiscoveryService.h"
#import "OFResourceDataMap.h"

@implementation OFGameDiscoveryNewsItem
		
@synthesize iconUrl, title, subtitle;
		
- (void)setIconUrl:(NSString*)value
{
	OFSafeRelease(iconUrl);
	iconUrl = [value retain];
}

- (void)setTitle:(NSString*)value
{
	OFSafeRelease(title);
	title = [value retain];
}

- (void)setSubtitle:(NSString*)value
{
	OFSafeRelease(subtitle);
	subtitle = [value retain];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"icon_url", @selector(setIconUrl:));
		dataMap->addField(@"title", @selector(setTitle:));
		dataMap->addField(@"subtitle", @selector(setSubtitle:));
	}
	
	return dataMap.get();
}

+ (OFService*)getService
{
	return [OFGameDiscoveryService sharedInstance];
}

+ (NSString*)getResourceName
{
	return @"game_discovery_news_item";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(iconUrl);
	OFSafeRelease(title);
	OFSafeRelease(subtitle);
	
	[super dealloc];
}

@end
