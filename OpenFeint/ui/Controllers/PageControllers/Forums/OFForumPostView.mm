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

#import "OFForumPostView.h"

#import "OFForumPost.h"
#import "OFForumThread.h"
#import "OFForumThreadViewController.h"

#import "OFUser.h"
#import "OFImageView.h"
#import "OFImageLoader.h"
#import "OFViewHelper.h"
#import "OFFriendsService.h"
#import "OFAbuseReporter.h"
#import "OFConversationService+Private.h"
#import "OFConversationController.h"
#import "OFConversation.h"

#import "UIButton+OpenFeint.h"

#import "OpenFeint+NSNotification.h"
#import "OpenFeint+UserOptions.h"

#define DOWN_ARROW_ENABLED	@"OFButtonIconDownArrow.png"
#define UP_ARROW_ENABLED	@"OFButtonIconUpArrow.png"

@implementation OFForumPostView

@synthesize post;

#pragma mark Boilerplate

- (void)dealloc
{
	self.post = nil;
	
	OFSafeRelease(owner);
	
	OFSafeRelease(scrollView);
	OFSafeRelease(authorPicture);
	OFSafeRelease(authorName);
	OFSafeRelease(gameName);
	OFSafeRelease(postBody);
	OFSafeRelease(bodyWrapperView);
	OFSafeRelease(footerView);
	OFSafeRelease(actionWindow);
	
	OFSafeRelease(chatButton);
	OFSafeRelease(reportButton);
	OFSafeRelease(replyButton);
	OFSafeRelease(addFriendButton);
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	NSArray* segments = [NSArray arrayWithObjects:
		[OFImageLoader loadImage:UP_ARROW_ENABLED],
		[OFImageLoader loadImage:DOWN_ARROW_ENABLED], 
		nil];

	UISegmentedControl* segmentedControl = [[[UISegmentedControl alloc] initWithItems:segments] autorelease];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	[segmentedControl addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
		initWithCustomView:segmentedControl] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	replyButton.hidden = owner.thread.isLocked;
	
	OFAssert(post, "Must have a post set by now!");

	[addFriendButton setTitleForAllStates:post.author.followedByLocalUser ? @"Remove Friend" : @"Add Friend"];
	
	self.post = post;
}

- (IBAction)_chat
{
	[self showLoadingScreen];
	
	[OFConversationService
		startConversationWithUser:post.author.resourceId
		onSuccess:OFDelegate(self, @selector(_conversationStarted:))
		onFailure:OFDelegate(self, @selector(_conversationError))];
}

- (void)_conversationStarted:(OFPaginatedSeries*)conversationPage
{
	[self hideLoadingScreen];

	if ([conversationPage count] == 1)
	{
		OFConversation* conversation = [conversationPage objectAtIndex:0];
		OFConversationController* controller = [OFConversationController conversationWithId:conversation.resourceId withUser:conversation.otherUser];
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (void)_conversationError
{
	[self hideLoadingScreen];
	
	[[[[UIAlertView alloc] 
		initWithTitle:@"Error" 
		message:@"An error occurred. Please try again later." 
		delegate:nil 
		cancelButtonTitle:@"Ok" 
		otherButtonTitles:nil] autorelease] show];
}

- (IBAction)_report
{
	[OFAbuseReporter reportAbuseByUser:post.author.resourceId forumPost:post.resourceId fromController:self];
}

- (IBAction)_friend
{
	[self showLoadingScreen];
	OFDelegate success(self, @selector(onFollowChangedState));
	OFDelegate failure(self, @selector(onFollowFailedChangingState));
	if (post.author.followedByLocalUser)
	{
		[OFFriendsService makeLocalUserStopFollowing:post.author.resourceId onSuccess:success onFailure:failure];
	}
	else
	{
		[OFFriendsService makeLocalUserFollow:post.author.resourceId onSuccess:success onFailure:failure];
	}
}

- (void)onFollowChangedState 
{
	[self hideLoadingScreen];
	post.author.followedByLocalUser = !post.author.followedByLocalUser;

	if (post.author.followedByLocalUser)
	{
		[OpenFeint postAddFriend:post.author];
		
		// if he follows me, then he moves from pending to friend
		if (post.author.followsLocalUser)
		{
			[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] - 1];
		}
	}
	else
	{
		[OpenFeint postRemoveFriend:post.author];
		
		// if he follows me, then he moves from friend to pending
		if (post.author.followsLocalUser)
		{
			[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] + 1];
		}
	}

	[addFriendButton setTitleForAllStates:post.author.followedByLocalUser ? @"Remove Friend" : @"Add Friend"];
}

- (void)onFollowFailedChangingState
{
	[self hideLoadingScreen];
}

#pragma mark Property Methods

- (void)setPost:(OFForumPost*)_post
{
	OFSafeRelease(post);
	post = [_post retain];
	
	NSString* authorText = [NSString stringWithFormat:@"%@ | ", post.author.name];
	NSString* gameText = post.author.lastPlayedGameName;
	
	float nameWidth = [authorText sizeWithFont:authorName.font].width;
	float const kRightPad = 75.f;

	CGRect frame = authorName.frame;
	frame.size.width = nameWidth;
	authorName.frame = frame;

	frame = gameName.frame;
	frame.origin.x = CGRectGetMaxX(authorName.frame);
	frame.size.width = self.view.frame.size.width - frame.origin.x - kRightPad;
	gameName.frame = frame;

	authorName.text = authorText;
	gameName.text = gameText;

	[authorPicture useProfilePictureFromUser:post.author];

	float const kMinBodyHeight = 104.f;
	float const kBodyPad = 20.f;
	
	float bodyHeight = [post.body sizeWithFont:postBody.font constrainedToSize:CGSizeMake(postBody.frame.size.width, FLT_MAX)].height + kBodyPad;

	frame = bodyWrapperView.frame;
	frame.size.height = MAX(bodyHeight, kMinBodyHeight);
	bodyWrapperView.frame = frame;
	
	frame = postBody.frame;
	frame.origin.y = kBodyPad * 0.5f;
	frame.size.height = bodyHeight - kBodyPad;
	postBody.frame = frame;
	
	frame = footerView.frame;
	frame.origin.y = bodyWrapperView.frame.size.height - 1.f;
	footerView.frame = frame;
	
	CGSize contentSize = scrollView.contentSize;
	contentSize.height = CGRectGetMaxY(bodyWrapperView.frame);
	scrollView.contentSize = contentSize;
	
	[postBody setText:post.body];

	if ([post.author isLocalUser])
	{
		chatButton.hidden = YES;
		reportButton.hidden = YES;
		addFriendButton.hidden = YES;
		actionWindow.hidden = YES;
		scrollView.contentInset = UIEdgeInsetsMake(-48.f, 0.f, 0.f, 0.f);
	}
	else
	{
		chatButton.hidden = NO;
		reportButton.hidden = NO;
		addFriendButton.hidden = NO;
		actionWindow.hidden = NO;
		scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
	}
}

#pragma mark Public Methods

- (void)segmentTapped:(UISegmentedControl*)control
{
	if (control.selectedSegmentIndex == 0)
	{
		[owner _previous];
	}
	else if (control.selectedSegmentIndex == 1)
	{
		[owner _next];
	}
}

- (void)disableNext:(BOOL)disable
{
	UISegmentedControl* segmentControl = (UISegmentedControl*)self.navigationItem.rightBarButtonItem.customView;
	[segmentControl setEnabled:!disable forSegmentAtIndex:1];
}

- (void)disablePrevious:(BOOL)disable
{
	UISegmentedControl* segmentControl = (UISegmentedControl*)self.navigationItem.rightBarButtonItem.customView;
	[segmentControl setEnabled:!disable forSegmentAtIndex:0];
}

#pragma mark OFCallbackable

- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
