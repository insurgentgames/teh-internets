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
#import "OFGameDiscoveryService.h"
#import "OFGameDiscoveryCategory.h"
#import "OFGameDiscoveryNewsItem.h"
#import "OFService+Private.h"
#import "OFPlayedGame.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFGameDiscoveryImageHyperlink.h"
#import "OpenFeint+Private.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFGameDiscoveryService);

@implementation OFGameDiscoveryService

OPENFEINT_DEFINE_SERVICE(OFGameDiscoveryService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFGameDiscoveryImageHyperlink getResourceName], [OFGameDiscoveryImageHyperlink class]);
	namedResources->addResource([OFGameDiscoveryNewsItem getResourceName], [OFGameDiscoveryNewsItem class]);
	namedResources->addResource([OFGameDiscoveryCategory getResourceName], [OFGameDiscoveryCategory class]);
	namedResources->addResource([OFPlayedGame getResourceName], [OFPlayedGame class]);
}

+ (void)getGameDiscoveryCategoriesOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[self getDiscoveryPageNamed:nil withPage:1 onSuccess:onSuccess onFailure:onFailure];
}

+ (void)getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[self getGameDiscoveryCategoriesOnSuccess:onSuccess onFailure:onFailure];
}

+ (void)getDiscoveryPageNamed:(NSString*)targetDiscoveryPageName withPage:(NSInteger)oneBasedPageNumber onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", oneBasedPageNumber);
	
	OFRetainedPtr<NSString> orientation = [OpenFeint isInLandscapeMode] ? @"landscape" : @"portrait";
	params->io("orientation", orientation);
	
	NSString* actionName = nil;
	if(targetDiscoveryPageName == nil)
	{
		actionName = @"game_discovery_categories";
	}
	else
	{
		actionName = [NSString stringWithFormat:@"game_discovery_categories/%@.xml", targetDiscoveryPageName];
	}
	
	[[self sharedInstance] 
		 getAction:actionName
		 withParameters:params
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestSilent
		 withNotice:nil];
}

+ (void)getNowPlayingFeaturedPlacement:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[self getDiscoveryPageNamed:@"now_playing_featured_placement" withPage:1 onSuccess:onSuccess onFailure:onFailure];
}

@end
