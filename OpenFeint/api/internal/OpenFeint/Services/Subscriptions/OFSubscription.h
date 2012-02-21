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

#import "OFResource+Overridables.h"

@class OFUser;
@class OFConversation;
@class OFForumThread;

enum OFSubscriptionType
{
	kOFSubscription_Forum,
	kOFSubscription_Conversation,
	
	kOFSubscription_Count
};

@interface OFSubscription : OFResource
{
	OFSubscriptionType type;
	NSString* discussionId;
	
	NSString* title;
	NSString* summary;

	NSDate* lastActivity;
	NSDate* lastViewed;

	int unreadCount;
    BOOL locked;
	
	NSString* topicId;
	OFUser* otherUser;
    
    OFConversation *conversation;
    OFForumThread *discussion;
}

- (BOOL)isForumThread;
- (BOOL)isConversation;

@property (assign) OFSubscriptionType type;
@property (retain) NSString* discussionId;

@property (retain) NSString* title;
@property (retain) NSString* summary;

@property (retain) NSDate* lastActivity;
@property (retain) NSDate* lastViewed;

@property (assign) int unreadCount;


@property (retain) NSString* topicId;
@property (retain) OFUser* otherUser;

@property (retain) OFConversation *conversation;
@property (retain) OFForumThread *discussion;

@end
