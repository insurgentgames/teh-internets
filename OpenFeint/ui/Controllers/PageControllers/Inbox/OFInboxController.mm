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

#import "OFInboxController.h"

#import "OFConversationService+Private.h"
#import "OFSubscriptionService+Private.h"
#import "OFSubscription.h"
#import "OFConversationController.h"
#import "OFConversation.h"

#import "OFUser.h"
#import "OFForumThread.h"
#import "OFForumTopic.h"
#import "OFForumThreadViewController.h"
#import "OFTableSequenceControllerHelper+Overridables.h"

#import "OFResourceControllerMap.h"

#import "OpenFeint+UserOptions.h"

@interface OFInboxController (Internal)
- (void)pickerFinishedWithSelectedUser:(OFUser*)selectedUser;
- (void)_newMessagePressed;
@end

@implementation OFInboxController

#pragma mark Boilerplate

- (void)dealloc
{
	OFSafeRelease(pendingConversationUser);
	[super dealloc];
}

#pragma mark Internal Methods

- (void)_conversationStarted:(OFPaginatedSeries*)conversationPage
{
	if (!pendingConversationUser)
		return;
		
	[self hideLoadingScreen];

	if ([conversationPage count] == 1)
	{
		OFConversation* conversation = [conversationPage objectAtIndex:0];
		OFConversationController* controller = [OFConversationController conversationWithId:conversation.resourceId withUser:conversation.otherUser];
		[self.navigationController pushViewController:controller animated:YES];
	}
	
	OFSafeRelease(pendingConversationUser);
}

- (void)_conversationError
{
	OFSafeRelease(pendingConversationUser);
	[self hideLoadingScreen];
	
	[[[[UIAlertView alloc] 
		initWithTitle:@"Error" 
		message:@"An error occurred. Please try again later." 
		delegate:nil 
		cancelButtonTitle:@"Ok" 
		otherButtonTitles:nil] autorelease] show];
}

- (void)pickerFinishedWithSelectedUser:(OFUser*)selectedUser
{
	[self showLoadingScreen];
	
	pendingConversationUser = [selectedUser retain];
	
	[OFConversationService
		startConversationWithUser:selectedUser.resourceId
		onSuccess:OFDelegate(self, @selector(_conversationStarted:))
		onFailure:OFDelegate(self, @selector(_conversationError))];
}

-(OFInboxController*)initAndBeginConversationWith:(OFUser *)theUser
{
	self = [super init];
	if (self) {
		pendingConversationUser = [theUser retain];
	}
	return self;
	
}

-(void)beginConversationWith:(OFUser *)theUser
{
	pendingConversationUser = [theUser retain];
}


- (bool)autoLoadData
{
	return pendingConversationUser == nil;
}

- (void)_newMessagePressed
{
	[OFFriendPickerController launchPickerWithDelegate:self promptText:@"Select a friend to message"];
}

#pragma mark OFViewController

- (void)loadView
{
	[super loadView];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
		initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
		target:self
		action:@selector(_newMessagePressed)] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.title = @"My Conversations";
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (pendingConversationUser) {
		[self showLoadingScreen];
		[OFConversationService
		 startConversationWithUser:pendingConversationUser.resourceId
		 onSuccess:OFDelegate(self, @selector(_conversationStarted:))
		 onFailure:OFDelegate(self, @selector(_conversationError))];
	}
}

#pragma mark OFTableSequenceControllerHelper

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFSubscription class], @"Inbox");
}

- (OFService*)getService
{
	return [OFSubscriptionService sharedInstance];
}

- (bool)shouldAlwaysRefreshWhenShown
{
	return true;
}

- (bool)allowPagination
{
	return true;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFSubscription class]])
	{
		UIViewController* pushController = nil;
		
		OFSubscription* subscription = (OFSubscription*)cellResource;
		
		if ([subscription isForumThread])
		{
			OFForumTopic* topic = [[[OFForumTopic alloc] initWithId:subscription.topicId] autorelease];
			OFForumThread* thread = subscription.discussion;
            thread.isSubscribed = YES;
			pushController = [OFForumThreadViewController threadView:thread topic:topic];
		}
		else if ([subscription isConversation])
		{
			pushController = [OFConversationController conversationWithId:subscription.discussionId withUser:subscription.otherUser];
		}

		[self.navigationController pushViewController:pushController animated:YES];
	}
}

- (NSString*)getNoDataFoundMessage
{
	return @"Your inbox is empty. Send a message to a friend by pressing the compose button.";
}

- (void)onResourcesDownloaded:(OFPaginatedSeries*)resources
{
	[super onResourcesDownloaded:resources];
	
	NSInteger numUnread = 0;
	
	for (OFSubscription* sub in resources)
	{
		numUnread += (sub.unreadCount > 0) ? 1 : 0;
	}
	
	[OpenFeint setUnreadInboxCount:numUnread];
}

- (NSString*)getTableHeaderViewName
{
	return nil;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFSubscriptionService
		getSubscriptionsPage:oneBasedPageNumber 
		onSuccess:success 
		onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFSubscriptionService
		getSubscriptionsPage:1 
		onSuccess:success 
		onFailure:failure];
}

@end
