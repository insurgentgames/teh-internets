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

#import "OFForumTopic.h"
#import "OFForumService.h"

#import "OFStringUtility.h"
#import "OFResourceDataMap.h"

#import "OpenFeint+UserOptions.h"

@implementation OFForumTopic

@synthesize title, children, threadCount, isShowingChildren, indentLevel;

#pragma mark Boilerplate

+ (id)announcementsTopic
{
	OFForumTopic* topic = [[[OFForumTopic alloc] init] autorelease];
	topic->resourceId = [@"announcements" retain];
	topic.title = @"Announcements";
	return topic;	
}

+ (id)suggestionsTopic:(NSString*)topicId
{
	topicId = topicId ? topicId : [OpenFeint suggestionsForumId];
	OFForumTopic* topic = [[[OFForumTopic alloc] init] autorelease];
	topic->resourceId = [topicId retain];
	topic.title = @"Suggestions";
	return topic;	
}

- (void)dealloc
{
	self.title = nil;
	self.children = nil;
	OFSafeRelease(parentId);
	[super dealloc];
}

#pragma mark Public Interface

- (BOOL)hasParent
{
	return [parentId length] > 0;
}

- (BOOL)hasChildren
{
	return [children count] > 0;
}

- (void)setChildren:(NSArray*)_children
{
	OFSafeRelease(children);
	children = [_children retain];

	self.indentLevel = indentLevel;	// force propagation to children
}

- (void)setIndentLevel:(NSInteger)_level
{
	indentLevel = _level;
	for (OFForumTopic* child in children)
		child.indentLevel = _level+1;
}

#pragma mark XML Data Field Methods

- (void)setTitle:(NSString*)value
{
	OFSafeRelease(title);
	title = [value retain];
}

- (void)setParentId:(NSString*)value
{
	OFSafeRelease(parentId);
	parentId = [value retain];
}

- (NSString*)parentId
{
	return parentId;
}

- (void)setThreadCountFromString:(NSString*)value
{
	threadCount = [value intValue];
}

- (NSString*)threadCountAsString
{
	return [NSString stringWithFormat:@"%d", threadCount];
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
		dataMap->addField(						@"name",				@selector(setTitle:),					@selector(title));
		dataMap->addField(						@"parent_id",			@selector(setParentId:),				@selector(parentId));
		dataMap->addField(						@"discussions_count",	@selector(setThreadCountFromString:),	@selector(threadCountAsString));
		dataMap->addNestedResourceArrayField(	@"children",			@selector(setChildren:),				@selector(children));
		
		// Ignored
		//client_application_id
		//created_at
		//updated_at
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"topic";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

@end
