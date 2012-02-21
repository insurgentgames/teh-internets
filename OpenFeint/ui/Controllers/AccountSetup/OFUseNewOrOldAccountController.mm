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

#import "OFUseNewOrOldAccountController.h"

#import "OFControllerLoader.h"
#import "OFAccountLoginController.h"
#import "OFUserService.h"
#import "OFUser.h"
#import "OFProvider.h"
#import "OFImageLoader.h"
#import "OFFramedContentWrapperView.h"
#import "OFShowMessageAndReturnController.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"

@interface OFUseNewOrOldAccountController (Internal)
- (void)_bootstrapSuccess;
- (void)_bootstrapFailure;
- (void)_popBackToRoot;
@end

@implementation OFUseNewOrOldAccountController

#pragma mark Boilerplate

- (id)init
{
	self = [super init];
	if (self)
	{
		self.title = @"Choose Account";
	}
	return self;
}

- (void)dealloc
{
	OFSafeRelease(footerButton);
	[super dealloc];
}

#pragma mark OFCallbackable

- (bool)canReceiveCallbacksNow
{
	return true;
}

#pragma mark OFTableSequenceControllerHelper

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"User");
}

- (OFService*)getService
{
	return [OFUserService sharedInstance];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFUserService findUsersForLocalDeviceOnSuccess:success onFailure:failure];
}

- (bool)usePlainTableSectionHeaders
{
	return false;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		OFUser* user = (OFUser*)cellResource;

		[self showLoadingScreen];
		[[OpenFeint provider] destroyLocalCredentials];
		[OpenFeint 
			doBootstrap:NO 
			userId:user.resourceId 
			onSuccess:OFDelegate(self, @selector(_bootstrapSuccess)) 
			onFailure:OFDelegate(self, @selector(_bootstrapSuccess))];
	}
}

#pragma mark UseNewOrOldAccountController Logic

- (void)_createAndDisplayTableHeader
{
	float width = self.view.frame.size.width;
	if ([self.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		OFFramedContentWrapperView* wrapperView = (OFFramedContentWrapperView*)self.view;
		width = wrapperView.wrappedView.frame.size.width;
	}

	CGRect frame;
	
	UIView* header = OFControllerLoader::loadView(@"UseNewOrOldAccountHeader", self);
	frame = header.frame;
	frame.size.width = width;
	header.frame = frame;
	
	self.tableView.tableHeaderView = header;

	UIView* footer = OFControllerLoader::loadView(@"UseNewOrOldAccountFooter", self);	
	frame = footer.frame;
	frame.size.width = width;
	footer.frame = frame;

	[footerButton setBackgroundImage:[footerButton.currentBackgroundImage stretchableImageWithLeftCapWidth:7 topCapHeight:7] forState:UIControlStateNormal];
	self.tableView.tableFooterView = footer;
}

- (void)_bootstrapSuccess
{
	[self hideLoadingScreen];
	[OpenFeint reloadInactiveTabBars];

	OFShowMessageAndReturnController* controllerToPush = [OFAccountSetupBaseController getStandardLoggedInController];
	controllerToPush.controllerToPopTo = [self.navigationController.viewControllers objectAtIndex:0];
	[self.navigationController pushViewController:controllerToPush animated:YES];
}

- (void)_popBackToRoot
{
	[OpenFeint reloadInactiveTabBars];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)clickedUseOld
{
	OFAccountSetupBaseController* login = (OFAccountSetupBaseController*)OFControllerLoader::load(@"OpenFeintAccountLogin");

	// Fogbugz 1086
	OFDelegate popToStandardLoggedIn(self, @selector(_bootstrapSuccess));
	[login setCompletionDelegate:popToStandardLoggedIn];

	OFDelegate popToRootDelegate(self, @selector(_popBackToRoot));
	[login setCancelDelegate:popToRootDelegate];

	[self.navigationController pushViewController:login animated:YES];
}

@end
