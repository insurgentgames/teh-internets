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

#import "OFSelectUserWidget.h"

#import "OFDependencies.h"
#import "OFResourceControllerMap.h"
#import "OFUser.h"
#import "OFUserService.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFPaginatedSeries.h"
#import "OFTableSectionDescription.h"
#import "OFViewHelper.h"
#import "OFControllerLoader.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFProvider.h"
#import "OFActionRequest.h"
#import "OFHttpRequest.h"
#import "OFHttpNestedQueryStringWriter.h"

#pragma mark Internal OFSelectUserController Interface

@interface OFSelectUserController : OFTableSequenceControllerHelper
{
	UIView* loadingView;
	OFSelectUserWidget* owner;
}

@property (assign) OFSelectUserWidget* owner;

- (void)replaceUsers:(OFPaginatedSeries*)users;

@end

#pragma mark OFSelectUserWidget Implementation

@implementation OFSelectUserWidget

@synthesize delegate, hideHeader, disallowEdit;

- (void)awakeFromNib
{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	
	widgetController = [[OFSelectUserController alloc] initWithStyle:UITableViewStylePlain];
	widgetController.owner = self;
	
	[widgetController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[widgetController.view setFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
	
	[self addSubview:widgetController.view];
}

- (void)dealloc
{
	widgetController.owner = nil;
	OFSafeRelease(widgetController);
	self.delegate = nil;
	[super dealloc];
}

- (void)clickedUser:(OFUser*)user
{
	[delegate selectUserWidget:self didSelectUser:user];
}

- (void)reloadUserList
{
	[widgetController reloadDataFromServer];
}

- (void)setUserResources:(OFPaginatedSeries*)userResources
{
	[widgetController replaceUsers:userResources];
}

- (void)setEditing:(BOOL)editing
{
	[[widgetController tableView] setEditing:editing animated:YES];
}

@end

#pragma mark Internal OFSelectUserController Implementation

@implementation OFSelectUserController

@synthesize owner;

- (void)showLoadingScreen
{
	[self hideLoadingScreen];
	
	loadingView = [[UIView alloc] initWithFrame:self.view.frame];
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	loadingView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.75f];
	loadingView.opaque = NO;
	
	UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[indicator startAnimating];
	[indicator setContentMode:UIViewContentModeCenter];
	[indicator setFrame:loadingView.frame];
	
	[loadingView addSubview:indicator];
	[self.view addSubview:loadingView];
}

- (void)hideLoadingScreen
{
	[loadingView removeFromSuperview];
	OFSafeRelease(loadingView);
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"User");
}

- (OFService*)getService
{
	return [OFUserService sharedInstance];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFUserService findUsersForLocalDeviceOnSuccess:success onFailure:failure];
}

- (bool)allowEditing
{
	return !owner.disallowEdit;
}

- (bool)shouldConfirmResourceDeletion
{
	return true;
}

- (NSString*)getResourceDeletePromptText:(OFResource*)resource
{
	OFUser* user = (OFUser*)resource;

//	if ([user isLocalUser])
//	{
//		NSString* logoutWarning = [NSString stringWithFormat:@"%@ is currently logged in. If you remove %@ from this device you will be logged out.", user.name, user.name];
//		if (![OpenFeint loggedInUserHasNonDeviceCredential])
//			logoutWarning = [NSString stringWithFormat:@"%@ %@ is an unsecured account and will be lost if you proceed.", logoutWarning, user.name];
//
//		return logoutWarning;
//	}

	return [NSString stringWithFormat:@"You are about to remove %@ from this device. If %@ is not secured then the account will be lost!", user.name, user.name];
}

- (NSString*)getResourceDeleteCancelText
{
	return @"Cancel";
}

- (NSString*)getResourceDeleteConfirmText
{
	return @"Remove";
}

- (bool)allowPagination
{
	return false;
}

- (bool)usePlainTableSectionHeaders
{
	return !owner.hideHeader;
}

- (void)_onDataLoaded:(OFPaginatedSeries*)resources isIncremental:(BOOL)isIncremental
{
	if (!owner.hideHeader)
	{
		OFTableSectionDescription* section = [OFTableSectionDescription sectionWithTitle:@"Device Users" andPage:resources];
		resources = [OFPaginatedSeries paginatedSeriesWithObject:section];
	}

	[super _onDataLoaded:resources isIncremental:isIncremental];
}

- (void)replaceUsers:(OFPaginatedSeries*)users
{
	[self _onDataLoaded:users isIncremental:NO];
}

- (UIView*)createPlainTableSectionHeader:(NSUInteger)sectionIndex
{
	UIView* headerView = nil;
	
	if (sectionIndex < [mSections count])
	{
		OFTableSectionDescription* tableDescription = (OFTableSectionDescription*)[mSections objectAtIndex:sectionIndex];
		if (tableDescription.title != nil)
		{
			headerView = OFControllerLoader::loadView(@"SelectUserWidgetHeader");
		}
	}

	return headerView;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	[owner clickedUser:(OFUser*)cellResource];
}

- (void)onResourceWasDeleted:(OFResource*)cellResource
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("user_id", cellResource.resourceId);
	params->io("udid", [[UIDevice currentDevice] uniqueIdentifier]);

	OFDelegate success;
	OFDelegate failure;

	[[OpenFeint provider] 
		performAction:@"users/remove_from_device.xml"
		withParameters:params->getQueryParametersAsMPURLRequestParameters()
		withHttpMethod:HttpMethodGet
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil
		requiringAuthentication:NO];
}

- (void)dealloc
{
	self.owner = nil;
	[super dealloc];
}

@end