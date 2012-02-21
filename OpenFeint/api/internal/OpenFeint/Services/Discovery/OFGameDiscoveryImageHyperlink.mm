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
#import "OFGameDiscoveryImageHyperlink.h"
#import "OFGameDiscoveryService.h"
#import "OFResourceDataMap.h"

@implementation OFGameDiscoveryImageHyperlink
	
@synthesize imageUrl, targetDiscoveryActionName, targetApplicationIPurchaseId, secondsToDisplay, targetDiscoveryPageTitle, appBannerPlacement;

- (void)setSecondsToDisplayFromString:(NSString*)value
{
	secondsToDisplay = [value floatValue];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"seconds_to_display", @selector(setSecondsToDisplayFromString:));
		dataMap->addField(@"image_url", @selector(setImageUrl:));
		dataMap->addField(@"target_application_ipurchase_id", @selector(setTargetApplicationIPurchaseId:));
		dataMap->addField(@"target_discovery_page_title", @selector(setTargetDiscoveryPageTitle:));
		dataMap->addField(@"target_discovery_action_name", @selector(setTargetDiscoveryActionName:));
		dataMap->addField(@"app_banner_placement", @selector(setAppBannerPlacement:));
	}
	
	return dataMap.get();
}

+ (OFService*)getService
{
	return [OFGameDiscoveryService sharedInstance];
}

+ (NSString*)getResourceName
{
	return @"game_discovery_image_hyperlink";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (bool)isCategoryLink
{
	return self.targetDiscoveryActionName != nil && ![self.targetDiscoveryActionName isEqualToString:@""];
}

- (bool)isIPurchaseLink
{
	return self.targetApplicationIPurchaseId != nil && ![self.targetApplicationIPurchaseId isEqualToString:@""];
}

- (void) dealloc
{
	OFSafeRelease(appBannerPlacement);
	OFSafeRelease(imageUrl);
	OFSafeRelease(targetDiscoveryPageTitle)
	OFSafeRelease(targetDiscoveryActionName);
	OFSafeRelease(targetApplicationIPurchaseId);
	
	[super dealloc];
}

@end
