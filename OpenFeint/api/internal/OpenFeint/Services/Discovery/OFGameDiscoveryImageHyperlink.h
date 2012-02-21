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

#pragma once

#import "OFResource.h"

@class OFService;

@interface OFGameDiscoveryImageHyperlink : OFResource
{
	float secondsToDisplay;
	NSString* imageUrl;
	NSString* targetDiscoveryActionName;
	NSString* targetDiscoveryPageTitle;
	NSString* targetApplicationIPurchaseId;
	NSString* appBannerPlacement;
}

@property (nonatomic, assign) float secondsToDisplay;
@property (nonatomic, retain) NSString* imageUrl;
@property (nonatomic, retain) NSString* targetDiscoveryActionName;
@property (nonatomic, retain) NSString* targetDiscoveryPageTitle;
@property (nonatomic, retain) NSString* targetApplicationIPurchaseId;
@property (nonatomic, retain) NSString* appBannerPlacement;

- (bool)isCategoryLink;
- (bool)isIPurchaseLink;

+ (OFResourceDataMap*)getDataMap;
+ (OFService*)getService;
+ (NSString*)getResourceName;

@end
