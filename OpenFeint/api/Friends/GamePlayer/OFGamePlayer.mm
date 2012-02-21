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
#import "OFGamePlayer.h"
#import "OFProfileService.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"

@implementation OFGamePlayer

@synthesize user, applicationId, applicationGamerscore, isFavorite;

- (void)setIsFavorite:(NSString*)value
{
	isFavorite = [value boolValue];
}

- (void)setApplicationId:(NSString*)value
{
	applicationId = [value retain];
}

- (void)setApplicationGamerscore:(NSString*)value
{
	applicationGamerscore = [value intValue];
}

- (void)setUser:(OFResource*)value
{
	user = (OFUser*)[value retain];
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
		dataMap->addField(@"app_id", @selector(setApplicationId:));
		dataMap->addField(@"app_gamerscore", @selector(setApplicationGamerscore:));
		dataMap->addField(@"favorite", @selector(setIsFavorite:));
		dataMap->addNestedResourceField(@"user", @selector(setUser:), nil, [OFUser class]);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"game_player";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(user);
	OFSafeRelease(applicationId);
	[super dealloc];
}

@end