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

#import "OFFriendPickerController.h"

#import "OFUser.h"
#import "OFFriendsService.h"
#import "OFUsersCredential.h"
#import "OFFullscreenImportFriendsMessage.h"
#import "OFControllerLoader.h"
#import "OFTableCellHelper.h"
#import "OFUserCell.h"
#import "OFDefaultLeadingCell.h"
#import "OFFramedNavigationController.h"
#import "OFTableSequenceControllerHelper+ViewDelegate.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFDefaultButton.h"
#import "OFTabBarController.h"
#import "OFRootController.h"
#import "OFDeadEndErrorController.h"
#import "OFPlainTableHeaderController.h"
#import "OFImportFriendsController.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+Dashboard.h"

@implementation OFFriendPickerController

@synthesize delegate, promptText, scopedByApplicationId;

+ (void)launchPickerWithDelegate:(id<OFFriendPickerDelegate>)_delegate
{
	[OFFriendPickerController launchPickerWithDelegate:_delegate promptText:@"Select Friend"];
}

+ (void)launchPickerWithDelegate:(id<OFFriendPickerDelegate>)_delegate promptText:(NSString*)_promptText
{
	[OFFriendPickerController launchPickerWithDelegate:_delegate promptText:_promptText mustHaveApplicationId:nil];
}

+ (void)launchPickerWithDelegate:(id<OFFriendPickerDelegate>)_delegate promptText:(NSString*)_promptText mustHaveApplicationId:(NSString*)_applicationId
{
	OFFriendPickerController* picker = (OFFriendPickerController*)OFControllerLoader::load(@"FriendPicker");
	picker.delegate = _delegate;
	picker.promptText = _promptText;
	picker.title = @"Select Friend";
	picker.scopedByApplicationId = ([_applicationId length] > 0) ? _applicationId : nil;

	[OFNavigationController addCloseButtonToViewController:picker target:picker action:@selector(cancel)];

	OFFramedNavigationController* navController = [[[OFFramedNavigationController alloc] initWithRootViewController:picker] autorelease];
	[[OpenFeint getRootController] presentModalViewController:navController animated:YES];
}

- (void)dealloc
{
	self.delegate = nil;
	self.promptText = nil;
	self.scopedByApplicationId = nil;
	
	[super dealloc];
}

- (void)closeModal
{
	[self dismissModalViewControllerAnimated:YES];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)viewWillAppear:(BOOL)animated
{
	[OpenFeint allowErrorScreens:NO];
	[super viewWillAppear:animated];
}

- (void)dismiss
{
	[OpenFeint allowErrorScreens:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)_customFailHandler
{
	[self hideLoadingScreen];
	OFDeadEndErrorController* error = [OFDeadEndErrorController deadEndErrorWithMessage:@"Unable to download your friends list."];
	[OFNavigationController addCloseButtonToViewController:error target:self action:@selector(cancel)];
	[self.navigationController pushViewController:error animated:YES];
}

- (OFDelegate)getOnFailureDelegate
{
	return OFDelegate(self, @selector(_customFailHandler));
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"User");
}

- (OFService*)getService
{
	return [OFFriendsService sharedInstance];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	if (scopedByApplicationId)
	{
		[OFFriendsService getAllUsersWithApp:scopedByApplicationId followedByUser:nil alphabeticalOnSuccess:success onFailure:failure];
	}
	else
	{
		[OFFriendsService getAllUsersFollowedByLocalUserAlphabetical:success onFailure:failure];
	}
}

- (UIViewController*)getNoDataFoundViewController
{
	OFImportFriendsController* controller = (OFImportFriendsController*)OFControllerLoader::load(@"ImportFriends");
	[controller setController:self];
	return controller;
}

- (NSString*)getNoDataFoundMessage
{
	return [NSString stringWithFormat:@"There are no friends."];
}

- (void)onLeadingCellWasLoaded:(OFTableCellHelper*)leadingCell forSection:(OFTableSectionDescription*)section
{
	OFDefaultLeadingCell* defaultCell = (OFDefaultLeadingCell*)leadingCell;
	defaultCell.headerLabel.text = promptText;
}

- (NSString*)getLeadingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	return nil;
}

- (NSString*)getTableHeaderControllerName
{
	return @"PlainTableHeader";
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFPlainTableHeaderController* header = (OFPlainTableHeaderController*)tableHeader;
	header.headerLabel.text = promptText;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if ([cell isKindOfClass:[OFUserCell class]])
		{
			[self dismiss];
			[delegate pickerFinishedWithSelectedUser:(OFUser*)cellResource];
		}
	}
}

- (void)cancel
{
	[self dismiss];
	if ([delegate respondsToSelector:@selector(pickerCancelled)])
	{
		[delegate pickerCancelled];
	}
}

//- (bool)isAlphabeticalList
//{
//	return true;
//}

- (bool)allowPagination
{
	return false;
}

#pragma mark OFFramedNavigationControllerBehavior

- (BOOL)shouldShowNavBar
{
	return YES;
}

@end