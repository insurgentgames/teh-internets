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

#import "OFApplicationDescriptionController.h"
#import "OFControllerLoader.h"
#import "MPURLRequestParameter.h"
#import "OpenFeint+Private.h"
#import "OFProvider.h"

@implementation OFApplicationDescriptionController

@synthesize resourceId, appBannerPlacement;

+ (id)applicationDescriptionForId:(NSString*)resourceId appBannerPlacement:(NSString*)usersDisplayContext
{
	OFApplicationDescriptionController* me = (OFApplicationDescriptionController*)OFControllerLoader::load(@"ApplicationDescription");
	me.resourceId = resourceId;
	me.appBannerPlacement = usersDisplayContext;
	return me;
}

- (NSString*)getAction
{
	return [NSString stringWithFormat:@"client_applications/%@/application_descriptions.iphone", self.resourceId];
}

- (NSString*)getTitle
{
	return @"Info";
}

- (NSString*)notificationString
{
	return @"Downloaded Application Description";
}

- (NSArray*)getParameters
{
	if(self.appBannerPlacement)
	{
		MPURLRequestParameter* appBannerPlacementParam = [[[MPURLRequestParameter alloc] initWithName:@"app_banner_placement" andValue:self.appBannerPlacement] autorelease];
		return [NSArray arrayWithObject:appBannerPlacementParam];
	}
	return nil;
}

- (void)dealloc
{	
	self.appBannerPlacement = nil;
	self.resourceId = nil;
	[super dealloc];
}

@end