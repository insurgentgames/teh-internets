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

#import "OFSubscription.h"
#import "OFSubscriptionService+Private.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"
#import "OFConversation.h"
#import "OFForumThread.h"

#import "NSDateFormatter+OpenFeint.h"

namespace 
{
	static NSString const* sStringForType[kOFSubscription_Count] = 
	{
		@"Forum",
		@"Conversation"
	};
}

@implementation OFSubscription

@synthesize type, discussionId, title, summary, lastActivity, lastViewed, unreadCount, topicId, otherUser, discussion, conversation;

#pragma mark Boilerplate

- (void)dealloc
{
	self.discussionId = nil;
	self.title = nil;
	self.summary = nil;
	self.lastActivity = nil;
	self.lastViewed = nil;
	self.topicId = nil;
	self.otherUser = nil;
    self.discussion = nil;
    self.conversation = nil;
	[super dealloc];
}

#pragma mark Public Methods

- (BOOL)isForumThread
{
	return type == kOFSubscription_Forum;
}

- (BOOL)isConversation
{
	return type == kOFSubscription_Conversation;
}

#pragma mark XML Data Field Methods

- (void)setLastActivityFromString:(NSString*)value
{
	self.lastActivity = [[NSDateFormatter railsFormatter] dateFromString:value];
}

- (NSString*)lastActivityAsString
{
	return [[NSDateFormatter railsFormatter] stringFromDate:self.lastActivity];
}

- (void)setLastViewedFromString:(NSString*)value
{
	self.lastViewed = [[NSDateFormatter railsFormatter] dateFromString:value];
}

- (NSString*)lastViewedAsString
{
	return [[NSDateFormatter railsFormatter] stringFromDate:self.lastViewed];
}

- (void)setUnreadCountFromString:(NSString*)value
{
	unreadCount = [value intValue];
}

- (NSString*)unreadCountAsString
{
	return [NSString stringWithFormat:@"%d", unreadCount];
}

- (void)setTypeFromString:(NSString*)value
{
	for (int i = 0; i < kOFSubscription_Count; ++i)
	{
		if ([sStringForType[i] isEqualToString:value])
		{
			type = (OFSubscriptionType)i;
			break;
		}
	}
}

- (NSString*)typeFromString
{
	return sStringForType[type];
}


#pragma mark OFResource

+ (OFService*)getService
{
	return [OFSubscriptionService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"discussion_id",		@selector(setDiscussionId:),			@selector(discussionId));
		dataMap->addField(@"summary",			@selector(setSummary:),					@selector(summary));
		dataMap->addField(@"title",				@selector(setTitle:),					@selector(title));
		dataMap->addField(@"updated_at",		@selector(setLastActivityFromString:),	@selector(lastActivityAsString));
		dataMap->addField(@"last_viewed_at",	@selector(setLastViewedFromString:),	@selector(lastViewedAsString));
		dataMap->addField(@"unread_count",		@selector(setUnreadCountFromString:),	@selector(unreadCountAsString));
        dataMap->addField(@"locked",            @selector(setLockedFromString:),        @selector(lockedAsString));
		dataMap->addField(@"topic_id",			@selector(setTopicId:),					@selector(topicId));
		dataMap->addField(@"discussion_type",	@selector(setTypeFromString:),			@selector(typeFromString));
        
		dataMap->addNestedResourceField(@"user",        @selector(setOtherUser:),       @selector(otherUser),       [OFUser class]);
        dataMap->addNestedResourceField(@"discussion",  @selector(setDiscussion:),      @selector(discussion),      [OFForumThread class]);
        dataMap->addNestedResourceField(@"conversation",@selector(setConversation:),    @selector(conversation),    [OFConversation class]);
		
		// Ignored
		//created_at
		//user_id
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"subscription";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

@end
