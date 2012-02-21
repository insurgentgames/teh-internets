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

#import "OFForumThreadListController.h"

#import "OFForumThreadViewController.h"
#import "OFForumTopic.h"
#import "OFForumThread.h"
#import "OFForumService.h"
#import "OFPostNewMessage.h"

#import "OFResourceControllerMap.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OFFramedContentWrapperView.h"

#import "OFPageSelectionView.h"

@interface OFForumThreadListController (Internal)
- (void)_post;
@end

@implementation OFForumThreadListController

@synthesize topic;

#pragma mark Boilerplate

+ (id)threadBrowser:(OFForumTopic*)_topic
{
	OFForumThreadListController* threadBrowser = (OFForumThreadListController*)OFControllerLoader::load(@"ForumThreadList");
	threadBrowser.topic = _topic;
	return threadBrowser;
}

- (void)dealloc
{
	self.topic = nil;
	[super dealloc];
}

#pragma mark OFViewController

- (void)viewWillAppear:(BOOL)animated
{
	self.title = topic.title;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
												target:self action:@selector(_post)] autorelease];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	justPostedNewThread = NO;
}

#pragma mark OFTableSequenceControllerHelper

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFForumThread class], @"ForumThread");
}

- (OFService*)getService
{
	return [OFForumService sharedInstance];
}

- (bool)shouldAlwaysRefreshWhenShown
{
	return justPostedNewThread;
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFForumThread class]])
	{
		OFForumThreadViewController* threadView = [OFForumThreadViewController threadView:(OFForumThread*)cellResource topic:topic];
		[self.navigationController pushViewController:threadView animated:YES];
	}
}

- (NSString*)getNoDataFoundMessage
{
	return @"There are no discussions";
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFForumService
		getThreadsForTopic:topic.resourceId 
		page:oneBasedPageNumber 
		onSuccess:success 
		onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

#pragma mark Internal Interface

- (void)_post
{
	justPostedNewThread = YES;
	OFPostNewMessage* postController = [OFPostNewMessage postNewMessageInTopic:topic];
	[self.navigationController pushViewController:postController animated:YES];
}

@end
