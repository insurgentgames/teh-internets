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

#import "OFDependencies.h"
#import "OFChatRoomController.h"
#import "OFService+Private.h"
#import "OFChatMessageService.h"
#import "OFChatMessage.h"
#import "OFResourceControllerMap.h"
#import "OpenFeint+Private.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFControllerLoader.h"
#import "OFProfileController.h"
#import "OFChatRoomMessageBoxController.h"
#import "OFChatRoomInstance.h"
#import "OFDashboardNotificationView.h"
#import "OFInputResponsePerformSelector.h"
#import "OFChangeNameController.h"
#import "OFViewHelper.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OFChatRoomInstanceService.h"
#import "OFTableCellHelper.h"
#import "OFFramedNavigationController.h"

// citron note: using hidesBottomBarWhenPushed is not working for some reason when pushing *another* view after this one.
//				to make sure that it works properly, instead of actually hiding the tab bar we are just going to overlay
//				the keyboard on top of it.
static const unsigned int gTabBarHeight = 0;

@implementation OFChatRoomController

@synthesize roomInstance;

- (UIView*)getBottomView
{
	CGRect wrapperFrame = CGRectZero;	
	CGRect messageBoxFrame = mChatRoomMessageBoxController.view.frame;
	messageBoxFrame.origin.y = wrapperFrame.size.height;
	mChatRoomMessageBoxController.view.frame = messageBoxFrame;

	wrapperFrame.size.height += messageBoxFrame.size.height;
	wrapperFrame.size.width = messageBoxFrame.size.width;
	
	UIView* wrapperView = [[[UIView alloc] initWithFrame:wrapperFrame] autorelease];

	[wrapperView addSubview:mChatRoomMessageBoxController.view];	
	
	return wrapperView;
}

- (void)setTopBarsVisible:(BOOL)visible
{
	if (!visible == self.navigationController.navigationBarHidden)
	{
		return;
	}
	
	if (visible)
	{
		// jw note: hiding/showing the nav bar sets it to portrait width which messes up the animation etc so we need to animate it manually
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}
	else
	{		
		// jw note: animating out works fine so we let it handle itself so it ends up in the correct "hidden" state
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
	
	CGRect barFrame = self.navigationController.navigationBar.frame;
	barFrame.size.width = self.view.frame.size.width;
	self.navigationController.navigationBar.frame = barFrame;
}

- (void)_KeyboardWillShow:(NSNotification*)notification
{
    if (mIsKeyboardShown)
		return;
		
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;

	if ([OpenFeint isInLandscapeMode])
	{
		[self setTopBarsVisible:NO];
	}
	
	if ([[self navigationController] isKindOfClass:[OFFramedNavigationController class]])
	{
		[(OFFramedNavigationController*)[self navigationController] adjustForKeyboard:YES ofHeight:keyboardSize.height];
	}

	CGPoint contentOffset = [self.tableView contentOffset];

	float offsetAfterResizing = contentOffset.y + keyboardSize.height;
	const float largsetScrollableOffset = (self.tableView.contentSize.height - self.tableView.frame.size.height);
	if(offsetAfterResizing > largsetScrollableOffset)
	{
		offsetAfterResizing = largsetScrollableOffset; 
	}	
	[self.tableView setContentOffset:CGPointMake(contentOffset.x, offsetAfterResizing) animated:NO];

    mIsKeyboardShown = YES;
}

- (void)_KeyboardWillHide:(NSNotification*)notification
{
    if (!mIsKeyboardShown)
        return;
	
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;

	float additionalContentOffset = 0.0f;
	if ([OpenFeint isInLandscapeMode])
	{
		[self setTopBarsVisible:YES];
		additionalContentOffset = self.navigationController.navigationBar.frame.size.height;
	}

	CGPoint contentOffset = [self.tableView contentOffset];

	float offsetAfterResizing = contentOffset.y - keyboardSize.height + additionalContentOffset;
	if(offsetAfterResizing < 0)
	{
		offsetAfterResizing = 0; 
	}			
	[self.tableView setContentOffset:CGPointMake(contentOffset.x, offsetAfterResizing) animated:YES];	 

	if ([[self navigationController] isKindOfClass:[OFFramedNavigationController class]])
	{
		[(OFFramedNavigationController*)[self navigationController] adjustForKeyboard:NO ofHeight:keyboardSize.height];
	}

    mIsKeyboardShown = NO;
}

- (void)dealloc
{
	[mChatRoomMessageBoxController release];
	[roomInstance release];

	[mDashboardNotificationView removeFromSuperview];
	OFSafeRelease(mDashboardNotificationView);

	[super dealloc];
}

- (void)viewDidLoad
{	
	[super viewDidLoad];
	mChatRoomMessageBoxController = [OFControllerLoader::load(@"ChatRoomMessageBox") retain];
}

- (void)rejoinRoom
{
	OFDelegate success(self, @selector(onRejoinedRoom));
	OFDelegate failure(self, @selector(onFailedToRejoinRoom));
	[OFChatRoomInstanceService attemptToJoinRoom:roomInstance rejoining:YES onSuccess:success onFailure:failure];
}

- (void)onRejoinedRoom
{
	[OpenFeint setPollingFrequency:[OpenFeint getPollingFrequencyInChat]];
}

- (void)onFailedToRejoinRoom
{
	if (![OpenFeint isShowingErrorScreenInNavController:self.navigationController])
	{
		mRoomIsFull = true;
		if ([[self.navigationController visibleViewController] isKindOfClass:[OFChatRoomController class]])
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
		[[[[UIAlertView alloc] initWithTitle:@"Room Full!" message:@"Sorry, you've lost your spot due to inactivity." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	if (mIsChangingName)
	{
		if ([self.navigationController isKindOfClass:[OFFramedNavigationController class]])
		{
			[(OFFramedNavigationController*)self.navigationController refreshBottomView];
		}
		return;
	}
	[super viewWillAppear:animated];

	self.title = self.roomInstance.roomName;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];	
	
	[mChatRoomMessageBoxController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (mIsChangingName)
	{
		mIsChangingName = NO;
		return;
	}
	[super viewDidAppear:animated];

	if (mHasAppearedBefore)
	{
		[self rejoinRoom];
	}
	else
	{
		[OpenFeint setPollingFrequency:[OpenFeint getPollingFrequencyInChat]];
	}

	mHasAppearedBefore = true;

	[mChatRoomMessageBoxController viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (mIsChangingName)
	{
		return;
	}
	[super viewWillDisappear:animated];
	if ([OpenFeint isInLandscapeMode])
	{
		[self setTopBarsVisible:YES];
	}
	[mChatRoomMessageBoxController viewWillDisappear:animated];
	[OpenFeint stopPolling];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if (mIsChangingName)
	{
		return;
	}

	[super viewDidDisappear:animated];
	[mChatRoomMessageBoxController viewDidDisappear:animated];
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFChatMessage class], @"ChatRoomChatMessage");
}

- (OFService*)getService
{
	return [OFChatMessageService sharedInstance];
}

- (NSString*)getTableHeaderControllerName
{
	return nil;
}

- (NSString*)getNoDataFoundMessage
{
	return [NSString stringWithFormat:@"We're downloading messages in the background or no one has said anything yet."];
}

- (bool)shouldRefreshAfterNotification
{
	return true;
}

- (NSString*)getNotificationToRefreshAfter
{
	return [OFChatMessage getResourceDiscoveredNotification];
}

- (bool)isNewContentShownAtBottom
{
	return true;
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	success.invoke(nil);
}

@end