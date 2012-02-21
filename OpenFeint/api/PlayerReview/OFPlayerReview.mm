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
#import "OFPlayerReview.h"
#import "OFClientApplicationService.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"


@implementation OFPlayerReview

@synthesize user;
@synthesize favorite;
@synthesize review;

- (void)setUser:(OFUser*)value
{
	if (value != user)
	{
		OFSafeRelease(user);
		user = [value retain];
	}	
}

- (void)setfavorite:(NSString*)value
{
	favorite = [value boolValue];
}

- (void)setReview:(NSString*)value
{
	if (review != value)
	{
		OFSafeRelease(review);
		review = [value retain];
	}
}

+ (OFService*)getService;
{
	return [OFClientApplicationService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"favorite",				@selector(setfavorite:));
		dataMap->addField(@"review",				@selector(setReview:));
		dataMap->addNestedResourceField(@"user",	@selector(setUser:), nil, [OFUser class]);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"client_application_user";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_player_review_discovered";
}

- (void) dealloc
{
	OFSafeRelease(user);
	OFSafeRelease(review);
	[super dealloc];
}

@end
