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
#import "OFNewsletterSubscription.h"
#import "OFUserSettingService.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"

@implementation OFNewsletterSubscription

@synthesize user, developer;

- (void)setUser:(OFUser*)value
{ 
	if (value != user)
	{
		OFSafeRelease(user);
		user = [value retain];
	}
}

- (void)setDeveloper:(OFUser*)value
{ 
	if (value != developer)
	{
		OFSafeRelease(developer);
		developer = [value retain];
	}
}

+ (OFService*)getService;
{
	return [OFUserSettingService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addNestedResourceField(@"user", @selector(setUser:), nil, [OFUser class]);
		dataMap->addNestedResourceField(@"developer", @selector(setDeveloper:), nil, [OFUser class]);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"news_letter_subscription";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"news_letter_subscription_discovered";
}

- (void) dealloc
{
	OFSafeRelease(user);
	OFSafeRelease(developer);
	[super dealloc];
}

@end
