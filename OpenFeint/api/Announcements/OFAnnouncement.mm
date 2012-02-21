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

#import "OFAnnouncement.h"
#import "OFAnnouncementService+Private.h"
#import "OFForumPost.h"
#import "OFResourceDataMap.h"

@implementation OFAnnouncement

@synthesize body, isImportant, isUnread, linkedClientApplicationId;

#pragma mark Boilerplate

- (void)dealloc
{
	self.body = nil;
	self.linkedClientApplicationId = nil;
	[super dealloc];
}

#pragma mark Public Methods

- (NSComparisonResult)compareByDate:(OFAnnouncement*)announcement
{
	return [announcement.date compare:date];
}

#pragma mark XML Data Field Methods

- (void)setPost:(OFForumPost*)firstPost
{
	self.body = firstPost.body;
}

- (void)setImportantFromString:(NSString*)value
{
	isImportant = [value boolValue];
}

- (NSString*)importantAsString
{
	return isImportant ? @"true" : @"false";
}

- (void)setUnreadFromString:(NSString*)value
{
	isUnread = [value boolValue];
}

- (NSString*)unreadAsString
{
	return isUnread ? @"true" : @"false";
}

#pragma mark OFResource

+ (OFService*)getService
{
	return [OFAnnouncementService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		(*dataMap) = (*[super getDataMap]);	// yea. that just happened.
		dataMap->addField(					@"important",						@selector(setImportantFromString:),			@selector(importantAsString));
		dataMap->addField(					@"unread",							@selector(setUnreadFromString:),			@selector(unreadAsString));
		dataMap->addNestedResourceField(	@"post",							@selector(setPost:),						nil, [OFForumPost class]);
		dataMap->addField(					@"linked_client_application_id",	@selector(setLinkedClientApplicationId:),	@selector(linkedClientApplicationId));
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
