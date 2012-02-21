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

#import "OFAnnouncementDetailController.h"

#import "OFForumTopic.h"
#import "OFAnnouncement.h"
#import "OFForumPost.h"
#import "OFAnnouncementService.h"

#import "OFResourceControllerMap.h"
#import "OFControllerLoader.h"
#import "OFFramedContentWrapperView.h"
#import "OFForumPostView.h"
#import "OFViewHelper.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFTableSectionDescription.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFApplicationDescriptionController.h"
#import "OFImageLoader.h"

#import "OpenFeint+Private.h"

@implementation OFAnnouncementDetailController

@synthesize showCloseButton;

#pragma mark Boilerplate

+ (id)announcementDetail:(OFAnnouncement*)_announcement
{
	OFAnnouncementDetailController* detail = (OFAnnouncementDetailController*)OFControllerLoader::load(@"AnnouncementDetail");
	detail.thread = _announcement;
	detail.topic = [OFForumTopic announcementsTopic];
	return detail;
}

- (void)dealloc
{
	OFSafeRelease(titleLabel);
	OFSafeRelease(bodyLabel);
	
	OFSafeRelease(bodyWrapperView);
	OFSafeRelease(detailWrapperView);
	OFSafeRelease(headerToolbarView);
	OFSafeRelease(discussionLabel);
	OFSafeRelease(buyButton);
	
	OFSafeRelease(firstPost);
	[super dealloc];
}

#pragma mark Segment Handler

- (void)segmentTapped:(UISegmentedControl*)_control
{
	if (![thread isLocked] && _control.selectedSegmentIndex == 0)
	{
		[self _reply];
	}
	else
	{
		[OpenFeint dismissRootControllerOrItsModal];
	}
}

#pragma mark OFViewController

- (void)viewWillAppear:(BOOL)animated
{
	hideSubscribeAndReplyButtons = YES;
	
	[super viewWillAppear:animated];

	NSMutableArray* segments = [NSMutableArray arrayWithCapacity:2];

	if (![thread isLocked])
	{
		[segments addObject:[OFImageLoader loadImage:@"OFButtonReplyToThread.png"]];
	}
	
	if (showCloseButton)
	{
		[segments addObject:@"Close"];
	}

	if ([segments count] > 0)
	{
		UISegmentedControl* segmentedControl = [[[UISegmentedControl alloc] initWithItems:segments] autorelease];
		segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentedControl.momentary = YES;
		[segmentedControl addTarget:self action:@selector(segmentTapped:) forControlEvents:UIControlEventValueChanged];

		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
	}
}

#pragma mark OFTableSequenceControllerHelper

- (bool)usesHeaderResource
{
	return true;
}

- (NSInteger)getHeaderResourceSectionIndex
{
	return 0;
}

- (void)onHeaderResourceDownloaded:(OFResource*)headerResource
{
	OFSafeRelease(firstPost);
	firstPost = [headerResource retain];
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFForumPost class], @"ForumPost");
}

- (OFService*)getService
{
	return [OFAnnouncementService sharedInstance];
}

- (NSString*)getNoDataFoundMessage
{
	return thread.isLocked ? @"Discussion has been disabled for this announcement." : @"No one is discussing this announcement.";
}

- (UIViewController*)getNoDataFoundViewController
{
	UIViewController* controller = nil;
	
	if (thread.isLocked)
	{
		controller = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		[controller setView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	}

	return controller;
}

- (void)onTableFooterCreated:(UIViewController*)tableFooter
{
	if (thread.isLocked)
	{
		self.tableView.tableFooterView = nil;
	}
}

- (NSString*)getTableHeaderViewName
{
	return @"AnnouncementDetailHeader";
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	float width = self.view.frame.size.width;
	if ([self.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		OFFramedContentWrapperView* wrapperView = (OFFramedContentWrapperView*)self.view;
		width = wrapperView.wrappedView.frame.size.width;
	}

	OFAssert(!tableHeader && mTableHeaderView, "Something went wrong!");

	CGRect frame;

	titleLabel.text = thread.title;

	static float const kBodyPad = 6.f;
	static float const kSidePad = 12.f;
	static float const kMinHeight = 124.f;

	float bodyHeight = [firstPost.body sizeWithFont:bodyLabel.font constrainedToSize:CGSizeMake(width - (kSidePad * 2.f), FLT_MAX)].height;	
	float detailWrapperViewHeight = MAX(kMinHeight, bodyHeight + (kBodyPad * 2.f) + bodyWrapperView.frame.origin.y);
	
	headerToolbarView.hidden = thread.isLocked;

	frame = mTableHeaderView.frame;
	frame.size.width = width;
	frame.size.height = detailWrapperViewHeight;
	if (!thread.isLocked)
		frame.size.height += headerToolbarView.frame.size.height - 1.f;
	mTableHeaderView.frame = frame;

	frame = bodyLabel.frame;
	frame.size.height = bodyHeight;
	bodyLabel.frame = frame;
	bodyLabel.text = firstPost.body;
	
	frame = detailWrapperView.frame;
	frame.size.height = detailWrapperViewHeight;
	detailWrapperView.frame = frame;
		
	buyButton.hidden = !([thread isKindOfClass:[OFAnnouncement class]] && [((OFAnnouncement*)thread).linkedClientApplicationId length] > 0);
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFAnnouncementService
		getPostsForAnnouncement:thread.resourceId
		page:oneBasedPageNumber
		onSuccess:success
		onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (BOOL)shouldEnableNextButtonWithSection:(OFTableSectionDescription*)section indexPath:(NSIndexPath*)indexPath
{
    return [section isRowLastObject:indexPath.row + 1];
}

#pragma mark Internal Interface

- (IBAction)pressedBuy
{
	OFAssert([thread isKindOfClass:[OFAnnouncement class]], "Must be an announcement");
	OFAnnouncement* announcement = (OFAnnouncement*)thread;

	UIViewController* buyPage = [OFApplicationDescriptionController applicationDescriptionForId:announcement.linkedClientApplicationId appBannerPlacement:@"announcementDetailBuy"];
	[self.navigationController pushViewController:buyPage animated:YES];
}

@end
