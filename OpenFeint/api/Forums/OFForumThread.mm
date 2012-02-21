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

#import "OFForumThread.h"
#import "OFForumService.h"
#import "OFUser.h"
#import "OFResourceDataMap.h"
#import "OFStringUtility.h"

#import "NSDateFormatter+OpenFeint.h"

@implementation OFForumThread

@synthesize title, lastPostAuthor, date, postCount, isLocked, isSticky, isSubscribed;

#pragma mark Boilerplate

- (void)dealloc
{
	self.title = nil;
	self.lastPostAuthor = nil;
	self.date = nil;
	[super dealloc];
}

#pragma mark XML Data Field Methods

- (void)setTitle:(NSString*)value
{
	OFSafeRelease(title);
	title = [value retain];
}

- (void)setDateFromString:(NSString*)value
{
	self.date = [[NSDateFormatter railsFormatter] dateFromString:value];
}

- (NSString*)dateAsString
{
	return [[NSDateFormatter railsFormatter] stringFromDate:self.date];
}

- (void)setLockedFromString:(NSString*)value
{
	isLocked = [value boolValue];
}

- (NSString*)lockedAsString
{
	return isLocked ? @"true" : @"false";
}

- (void)setPostCountFromString:(NSString*)value
{
	postCount = [value intValue];
}

- (NSString*)postCountAsString
{
	return [NSString stringWithFormat:@"%d", postCount];
}

- (void)setStickyFromString:(NSString*)value
{
	isSticky = [value boolValue];
}

- (NSString*)stickyAsString
{
	return isSticky ? @"true" : @"false";
}

- (void)setSubscribedFromString:(NSString*)value
{
	isSubscribed = [value boolValue];
}

- (NSString*)subscribedAsString
{
	return isSubscribed ? @"true" : @"false";
}

#pragma mark OFResource

+ (OFService*)getService
{
	return [OFForumService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(					@"subject",		@selector(setTitle:),				@selector(title));
		dataMap->addNestedResourceField(	@"user",		@selector(setLastPostAuthor:),		@selector(lastPostAuthor),		[OFUser class]);
		dataMap->addField(					@"updated_at",	@selector(setDateFromString:),		@selector(dateAsString));
		dataMap->addField(					@"locked",		@selector(setLockedFromString:),	@selector(lockedAsString));
		dataMap->addField(					@"posts_count",	@selector(setPostCountFromString:),	@selector(postCountAsString));
		dataMap->addField(					@"sticky",		@selector(setStickyFromString:),	@selector(stickyAsString));
		dataMap->addField(					@"subscribed",	@selector(setSubscribedFromString:),@selector(subscribedAsString));
	
		// Ignored
		//topic_id
		//user_id
		//updated_at
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"discussion";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

@end
