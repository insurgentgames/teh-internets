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

#import "OFConversation.h"
#import "OFConversationService+Private.h"
#import "OFResourceDataMap.h"
#import "OFUser.h"

#import "NSDateFormatter+OpenFeint.h"

@implementation OFConversation

@synthesize subject, otherUser, lastMessageAt, messageCount;

#pragma mark Boilerplate

- (void)dealloc
{
	self.subject = nil;
	self.otherUser = nil;
	self.lastMessageAt = nil;
	[super dealloc];
}

#pragma mark XML Data Field Methods

- (void)setLastMessageAtFromString:(NSString*)value
{
	self.lastMessageAt = [[NSDateFormatter railsFormatter] dateFromString:value];
}

- (NSString*)lastMessageAtAsString
{
	return [[NSDateFormatter railsFormatter] stringFromDate:self.lastMessageAt];
}

- (void)setMessageCountFromString:(NSString*)value
{
	messageCount = [value intValue];
}

- (NSString*)messageCountAsString
{
	return [NSString stringWithFormat:@"%d", messageCount];
}

- (void)setUser:(OFUser*)user
{
	if (![user isLocalUser])
	{
		self.otherUser = user;
	}
}

#pragma mark OFResource

+ (OFService*)getService
{
	return [OFConversationService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(				@"subject",			@selector(setSubject:),					@selector(subject));
		dataMap->addField(				@"updated_at",		@selector(setLastMessageAtFromString:),	@selector(lastMessageAtAsString));
		dataMap->addField(				@"posts_count",		@selector(setMessageCountFromString:),	@selector(messageCountAsString));
		dataMap->addNestedResourceField(@"user",			@selector(setUser:),					@selector(otherUser),				[OFUser class]);
		dataMap->addNestedResourceField(@"other_user",		@selector(setUser:),					@selector(otherUser),				[OFUser class]);

		// Ignored
		//created_at
		//important
		//other_user_id
		//user_id
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"conversation";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

@end
