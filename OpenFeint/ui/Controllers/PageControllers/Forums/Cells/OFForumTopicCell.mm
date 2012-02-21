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

#import "OFForumTopicCell.h"
#import "OFForumTopic.h"

#import "OFImageLoader.h"

@implementation OFForumTopicCell

- (void)dealloc
{
	OFSafeRelease(titleLabel);
	OFSafeRelease(topicIcon);
	[super dealloc];
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFForumTopic* topic = (OFForumTopic*)resource;
	
	titleLabel.text = topic.title;
		
	// Hack! The "Real Time Chat" forum topic is created in the server side action
	// It has a resource id of 0 because it's not a record, it's a topic model created on the fly with Topic.new
	if (topic.resourceId == 0)
	{
		topicIcon.image = [OFImageLoader loadImage:@"OFIconChat.png"];
	}
	else
	{
		topicIcon.image = [OFImageLoader loadImage:@"OFForumTopicSmall.png"];
	}
}

@end
