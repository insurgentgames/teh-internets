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
#import "OFFriendsController.h"
#import "OFResourceControllerMap.h"
#import "OFFriendsService.h"
#import "OFUser.h"
#import "OFDefaultLeadingCell.h"
#import "OpenFeint+UserOptions.h"
#import "OFProfileController.h"
#import "OFControllerLoader.h"
#import "OFUsersCredential.h"
#import "OFFriendsHeaderController.h"
#import "OFTableSectionDescription.h"
#import "OpenFeint+NSNotification.h"
#import "OFViewHelper.h"
#import "OFTableControllerHelper+Overridables.h"
#import "OFPresenceService.h"
#import "OFImportFriendsController.h"
#import "OFPaginatedSeriesHeader.h"

namespace 
{
	const NSString* kFollowingTabName = @"Friends";
	const NSString* kFollowersTabName = @"Pending";
}

@interface OFFriendsController (Internal)
- (void)_addObservers;
- (void)_removeObservers;
- (void)_toggleEditing;
- (void)_notificationCallback:(NSNotification*)notification;
- (void)_updateEditButtonState;
@end

@implementation OFFriendsController

- (bool)localUsersFriends
{
	return [[self getPageContextUser] isLocalUser];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendPresenceDidChange:) name:OFNSNotificationFriendPresenceChanged object:nil];	
}


- (void)friendPresenceDidChange:(id)userInfo {
	[self reloadDataFromServer];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationFriendPresenceChanged object:nil];
}

- (void)_sharedInit
{
	[self _addObservers];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[self _sharedInit];
	}

	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil)
	{
		[self _sharedInit];
	}
	
	return self;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self _sharedInit];
	}
	
	return self;
}

- (void)dealloc
{
	[self _removeObservers];
	OFSafeRelease(editButton);
	[super dealloc];
}

- (void)_notificationCallback:(NSNotification*)notification
{
	if ([[notification name] isEqualToString:OFNSNotificationPendingFriendCountChanged])
	{
		NSUInteger pendingFriends = [OpenFeint pendingFriendsCount];		
		[(OFFriendsHeaderController*)mTableHeaderController setBadgeValue:pendingFriends forTabNamed:kFollowersTabName];
	}
	else if ([[notification name] isEqualToString:OFNSNotificationAddFriend])
	{
		friendCount++;
		refreshOnNextDidAppear = YES;
	}
	else if ([[notification name] isEqualToString:OFNSNotificationRemoveFriend])
	{
		friendCount--;
		refreshOnNextDidAppear = YES;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (refreshOnNextDidAppear)
	{
		alwaysRefresh = YES;
	}

	[super viewDidAppear:animated];

	if (refreshOnNextDidAppear)
	{
		alwaysRefresh = NO;
	}
	
	refreshOnNextDidAppear = NO;
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"User");
}

- (bool)allowPagination
{
	return mCurTabType == kFollowersTab;
}

- (OFService*)getService
{
	return [OFFriendsService sharedInstance];
}


- (void)doIndexActionWithPage:(NSUInteger)pageIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	if (mCurTabType == kFollowingTab)
	{
		[OFFriendsService getAllUsersFollowedByUserAlphabetical:[self getPageContextUser].resourceId onSuccess:success onFailure:failure];	
	}
	else if (mCurTabType == kFollowersTab)
	{
		[OFFriendsService getUsersFollowingUser:[self getPageContextUser].resourceId 
				   excludeUsersFollowedByTarget:YES
									  pageIndex:pageIndex 
									  onSuccess:success 
									  onFailure:failure];	
	}
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (UIViewController*)getNoDataFoundViewController
{
	if ([self localUsersFriends] && friendCount == 0 && mCurTabType == kFollowingTab)
	{
		[self setEditing:NO];
		alwaysRefresh = YES;
		OFImportFriendsController* controller = (OFImportFriendsController*)OFControllerLoader::load(@"ImportFriends");
		[controller setController:self];
		return controller;
	}
	
	return nil;
}

- (NSString*)getNoDataFoundMessage
{
	NSString* message = nil;
	
	if (mCurTabType == kFollowersTab)
	{
		message = [self localUsersFriends]
			? @"Here's where you'll find any pending friend requests.  You can choose to either add them to your Friends list or delete the request."
			: @"This user has no pending friends.";
	}
	else
	{
		message = [self localUsersFriends]
			? @"You have not added any OpenFeint friends yet. Check the Pending tab to see who wants to friend you!"
			: @"This user has not added any OpenFeint friends yet.";
	}
	
	return message;
}

- (bool)shouldAlwaysRefreshWhenShown
{
	return alwaysRefresh;
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	[self reloadDataFromServer];
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		OFUser* userResource = (OFUser*)cellResource;
		[OFProfileController showProfileForUser:userResource];

		// forcing refresh when returning from profile controller fixes tabs disappearing sometimes on 2.x devices
		refreshOnNextDidAppear = YES;
	}
}

- (NSString*)getTableHeaderControllerName
{
	return [self localUsersFriends] ? @"FriendsHeader" : nil;
}

- (void)_updateEditButtonState
{
	if ([self isEditing])
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self
												   action:@selector(_toggleEditing)]
												  autorelease];
	}
	else
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
												   target:self
												   action:@selector(_toggleEditing)]
												  autorelease];
	}
}

- (void)onFollowingSelected
{
	mCurTabType = kFollowingTab;
	[self setEditing:NO];
	[self reloadDataFromServer];
}

- (void)onFollowersSelected
{
	mCurTabType = kFollowersTab;
	[self reloadDataFromServer];
}

- (void)onResourcesDownloaded:(OFPaginatedSeries*)resources
{
	OFSafeRelease(mTableHeaderController);
	
	if (mCurTabType == kFollowersTab)
	{
		if (resources)
		{
			[OpenFeint setPendingFriendsCount:resources.header.totalObjects];
		}
		
		if ([OpenFeint pendingFriendsCount] == 0)
		{
			self.navigationItem.rightBarButtonItem = nil;
		}
		else
		{
			[self _updateEditButtonState];
		}
	}
	else if (mCurTabType == kFollowingTab)
	{
		friendCount = [resources count];

		if ([self localUsersFriends])
		{
			self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
													   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
													   target:self
													   action:@selector(findFriendsPressed)]
													  autorelease];
		}
		else
		{
			self.navigationItem.rightBarButtonItem = nil;
		}
	}
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFFriendsHeaderController* header = (OFFriendsHeaderController*)tableHeader;
	header.callbackTarget = self;
	[header addTab:kFollowingTabName andSelectedCallback:@selector(onFollowingSelected)];
	[header addTab:kFollowersTabName andSelectedCallback:@selector(onFollowersSelected)];

	[header setIsDisplayingForLocalUser:[self localUsersFriends]];

	[header setBadgeValue:[OpenFeint pendingFriendsCount] forTabNamed:kFollowersTabName];
	[header showTab:(mCurTabType == kFollowingTab) ? kFollowingTabName : kFollowersTabName];
}

- (IBAction)findFriendsPressed
{
	refreshOnNextDidAppear = YES;
	[self.navigationController pushViewController:OFControllerLoader::load(@"ImportFriends") animated:YES];	
	
	mCurTabType = kFollowingTab;
	[self setEditing:NO];
}

- (void)_addObservers
{
	[[NSNotificationCenter defaultCenter] 
		addObserver:self
		selector:@selector(_notificationCallback:)
		name:OFNSNotificationPendingFriendCountChanged
		object:nil];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self
		selector:@selector(_notificationCallback:)
		name:OFNSNotificationAddFriend
		object:nil];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self
		selector:@selector(_notificationCallback:)
		name:OFNSNotificationRemoveFriend
		object:nil];
}

- (void)_removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationPendingFriendCountChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationAddFriend object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationRemoveFriend object:nil];
}

- (void)_toggleEditing
{
	if (![self isEditing])
	{
		[self setEditing:YES];
	}
	else
	{
		[self setEditing:NO];
	}
	
	[self _updateEditButtonState];
}

- (UIView*)createPlainTableSectionHeader:(NSUInteger)sectionIndex
{
	UIView* headerView = nil;
	
	if (sectionIndex < [mSections count])
	{
		OFTableSectionDescription* tableDescription = (OFTableSectionDescription*)[mSections objectAtIndex:sectionIndex];

		headerView = OFControllerLoader::loadView(@"PlainTableSectionHeader");
		UILabel* label = (UILabel*)OFViewHelper::findViewByTag(headerView, 1);
		label.text = tableDescription.title;
	}

	return headerView;
}

- (bool)allowEditing
{
	return [self localUsersFriends];
}

- (bool)shouldConfirmResourceDeletion
{
	return false;
}

- (void)_removedFriend:(id)ignored user:(OFUser*)user
{
	if (user.followsLocalUser)
	{
		[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] + 1];
	}
	
	[OpenFeint postRemoveFriend:user];
	[self reloadDataFromServer];
}

- (void)_removedPendingFriend
{
	if (friendCount == 0 && [OpenFeint pendingFriendsCount] == 1)
	{
		mCurTabType = kFollowingTab;
		[self setEditing:NO];
	}

	[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] - 1];
	[self reloadDataFromServer];
}

- (void)_failedRemoving
{
	[self reloadDataFromServer];
}

- (void)onResourceWasDeleted:(OFResource*)cellResource
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		OFUser* user = (OFUser*)cellResource;
		
		[self showLoadingScreen];

		OFDelegate failure(self, @selector(_failedRemoving));
		
		if (mCurTabType == kFollowersTab)
		{
			OFDelegate success(self, @selector(_removedPendingFriend));
			[OFFriendsService removeLocalUsersFollower:user.resourceId onSuccess:success onFailure:failure];
		}
		else if (mCurTabType == kFollowingTab)
		{
			OFDelegate success(self, @selector(_removedFriend:user:), user);
			[OFFriendsService makeLocalUserStopFollowing:user.resourceId onSuccess:success onFailure:failure];
		}
	}
}

@end
