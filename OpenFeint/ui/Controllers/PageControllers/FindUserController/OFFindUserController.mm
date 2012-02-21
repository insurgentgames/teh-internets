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
#import "OFFindUserController.h"
#import "OFResourceControllerMap.h"
#import "OFUserService.h"
#import "OFUser.h"
#import "OFDefaultLeadingCell.h"
#import "OFProfileController.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"

@implementation OFFindUserController

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"User");
}

- (OFService*)getService
{
	return [OFUserService sharedInstance];
}

- (void)doIndexActionWithPage:(NSUInteger)pageIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFUserService findUsersByName:mCurrentName.get() pageIndex:pageIndex onSuccess:success onFailure:failure];	
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	[OFUserService findUsersByName:mCurrentName.get() pageIndex:1 onSuccess:success onFailure:failure];	
}

- (NSString*)getNoDataFoundMessage
{
	return @"No user with that name was found.";
}

- (NSString*)getDataNotLoadedYetMessage
{
	return @"Search for friends by their OpenFeint name.";
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		OFUser* userResource = (OFUser*)cellResource;
		[OFProfileController showProfileForUser:userResource];
	}
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	
}

- (bool)autoLoadData
{
	return false;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self showLoadingScreen];
	OFViewHelper::resignFirstResponder(self.view);			
	mCurrentName = searchBar.text;
	[self reloadDataFromServer];
}

- (NSString*)getTableHeaderControllerName
{
	return @"FindUserHeader";
}

- (void)dealloc
{
	[super dealloc];
}

@end

