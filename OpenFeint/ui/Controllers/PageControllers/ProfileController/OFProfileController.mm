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

#import "OFProfileController.h"

#import "OFProfileService.h"

#import "OFPlayedGameController.h"
#import "OFFriendsController.h"
#import "OFConversationController.h"

#import "OFControllerLoader.h"
#import "OFUser.h"
#import "OFDefaultButton.h"
#import "OFPaginatedSeries.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFConversationService+Private.h"
#import "OFConversation.h"
#import "OFAbuseReporter.h"
#import "OFPatternedGradientView.h"
#import "OFForumPost.h"
#import "OFForumThreadViewController.h"
#import "OFFramedNavigationController.h"
#import "OFTableSectionDescription.h"
#import "OFFriendsService.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+NSNotification.h"

@interface OFProfileController (Internal)
- (void)_updateFriendButtonState:(BOOL)isFriend;
- (void)_profileDownloadSucceeded:(OFPaginatedSeries*)resources;
@end

@implementation OFProfileController

@synthesize reportUserForumPost, forumThreadView;

#pragma mark Boilerplate

- (void)dealloc
{
	OFSafeRelease(gamesInfo);
	OFSafeRelease(friendsInfo);
	
	OFSafeRelease(reportUserForumPost);
	OFSafeRelease(forumThreadView);
	
	OFSafeRelease(friendsSubtextLabel);
	OFSafeRelease(gamesSubtextLabel);
	OFSafeRelease(actionPanelView);
	OFSafeRelease(toggleFriendButton);

	[super dealloc];
}

#pragma mark Creators

+ (OFProfileController *)getProfileControllerForUser:(OFUser *)user andNavController:(UINavigationController *)currentNavController
{
	OFProfileController* newProfile = nil;

	BOOL shouldOpenProfile = YES;
		
	if ([currentNavController.visibleViewController isKindOfClass:[OFProfileController class]])
	{
		OFProfileController* currentProfile = (OFProfileController*)currentNavController.visibleViewController;
		OFUser* profileUser = [currentProfile getPageContextUser];
		if ([user.resourceId isEqualToString:profileUser.resourceId])
			shouldOpenProfile = NO;
	}
	
	if (shouldOpenProfile)
	{
		OFAssert([currentNavController isKindOfClass:[OFFramedNavigationController class]], "Must have a framed navigation controller for a profile!");
		newProfile = (OFProfileController*)OFControllerLoader::load(@"Profile");
	}
	
	newProfile.title = user.name;
	
	return newProfile;
}

+ (void)showProfileForUser:(OFUser*)user
{
	UINavigationController* currentNavController = [OpenFeint getActiveNavigationController];
	if (currentNavController)
	{
		OFProfileController* newProfile = [OFProfileController getProfileControllerForUser:user andNavController:currentNavController];
		if (newProfile)
			[(OFFramedNavigationController*)currentNavController pushViewController:newProfile animated:YES inContextOfUser:user];
	}
}

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated
{
	OFUser* user = [self getPageContextUser];
	if (user)
	{
		self.title = [NSString stringWithFormat:@"%@'s Profile", user.name];
	}
	else
	{
		self.title = @"Profile";
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!friendsInfo && !gamesInfo)
	{
		[self showLoadingScreen];
		[OFProfileService 
			getProfileForUser:[self getPageContextUser].resourceId
			onSuccess:OFDelegate(self, @selector(_profileDownloadSucceeded:))
			onFailure:OFDelegate(self, @selector(hideLoadingScreen))];
	}
}

#pragma mark Internal Methods

- (void)_updateFriendButtonState:(BOOL)isFriend
{
	if (isFriend)
	{
		[OFRedBorderedButton setupButton:toggleFriendButton];
		[toggleFriendButton setTitleForAllStates:@"Remove Friend"];
	}
	else
	{
		[OFGreenBorderedButton setupButton:toggleFriendButton];
		[toggleFriendButton setTitleForAllStates:@"Add Friend"];
	}
}

- (void)_profileDownloadSucceeded:(OFPaginatedSeries*)resources
{
	[self hideLoadingScreen];

	OFSafeRelease(friendsInfo);
	OFSafeRelease(gamesInfo);
	
	for (OFTableSectionDescription* section in resources)
	{
		if ([section.identifier isEqualToString:@"friends"])
		{
			friendsInfo = [section.page.header retain];
		}
		else if ([section.identifier isEqualToString:@"games"])
		{
			gamesInfo = [section.page.header retain];
		}
	}
	
	OFUser* user = [self getPageContextUser];
	actionPanelView.hidden = [user isLocalUser];
	[self _updateFriendButtonState:user.followedByLocalUser];
	
	if (friendsInfo.totalObjects > 0)
	{
		friendsSubtextLabel.text = [NSString stringWithFormat:@"%@ %@ %d %@", [user isLocalUser] ? @"You" : user.name, [user isLocalUser] ? @"have" : @"has", friendsInfo.totalObjects, friendsInfo.totalObjects > 1 ? @"friends" : @"friend"];
	}
	else
	{
		friendsSubtextLabel.text = [NSString stringWithFormat:@"%@ %@ not added any friends", [user isLocalUser] ? @"You" : user.name, [user isLocalUser] ? @"have" : @"has" ];
	}

	if (gamesInfo.totalObjects > 0)
	{
		gamesSubtextLabel.text = [NSString stringWithFormat:@"%@ %@ played %d %@", [user isLocalUser] ? @"You" : user.name, [user isLocalUser] ? @"have" : @"has", gamesInfo.totalObjects, gamesInfo.totalObjects > 1 ? @"games" : @"game"];
	}
	else
	{
		gamesSubtextLabel.text = [NSString stringWithFormat:@"%@ %@ not played any games", [user isLocalUser] ? @"You" : user.name, [user isLocalUser] ? @"have" : @"has"];
	}
}

#pragma mark OFCallbackable

- (bool)canReceiveCallbacksNow
{
	return true;
}

#pragma mark OFBannerFrame

- (bool)isBannerAvailableNow
{
	return true;
}

- (NSString*)bannerCellControllerName
{
	return @"PlayerBanner";
}

- (OFResource*)getBannerResource
{
	return [self getPageContextUser];
}

- (void)onBannerClicked
{
	// generally, ignore clicks
}

- (void)bannerProfilePictureTouched
{
	// except for this!
	if ([[self getPageContextUser] isLocalUser])
	{
		[self.navigationController pushViewController:OFControllerLoader::load(@"SelectProfilePicture") animated:YES];
	}
}

#pragma mark Other Actions

- (IBAction)onFriendsClicked
{
	if (friendsInfo.totalObjects > 0)
	{
		OFFriendsController* friendsController = (OFFriendsController*)OFControllerLoader::load(@"Friends");
		[self.navigationController pushViewController:friendsController animated:YES];
	}
}

- (IBAction)onGamesClicked
{
	if (gamesInfo.totalObjects > 0)
	{
		OFPlayedGameController* playedGameController = (OFPlayedGameController*)OFControllerLoader::load(@"PlayedGame");
		[self.navigationController pushViewController:playedGameController animated:YES];
	}
}

- (IBAction)onFlag
{
	OFUser* user = [self getPageContextUser];
	if (user && ![user isLocalUser])
	{
		if (reportUserForumPost && forumThreadView) 
		{
			[OFAbuseReporter reportAbuseByUser:user.resourceId forumPost:reportUserForumPost.resourceId fromController:forumThreadView];
		}
		else 
		{
			[OFAbuseReporter reportAbuseByUser:user.resourceId fromController:[OpenFeint getRootController]];
		}
	}
}

#pragma mark Friend Handling

- (IBAction)onToggleFollowing
{
	OFUser* user = [self getPageContextUser];
	if (!user || (user && [user isLocalUser]))
	{
		return;
	}
	
	[self showLoadingScreen];
	OFDelegate success(self, @selector(onFollowChangedState));
	OFDelegate failure(self, @selector(onFollowFailedChangingState));
	if (user.followedByLocalUser)
	{
		[OFFriendsService makeLocalUserStopFollowing:user.resourceId onSuccess:success onFailure:failure];
	}
	else
	{
		[OFFriendsService makeLocalUserFollow:user.resourceId onSuccess:success onFailure:failure];
	}
}

- (void)onFollowChangedState 
{
	[self hideLoadingScreen];
	OFUser* user = [self getPageContextUser];
	user.followedByLocalUser = !user.followedByLocalUser;

	[self _updateFriendButtonState:user.followedByLocalUser];
	
	if (user.followedByLocalUser)
	{
		[OpenFeint postAddFriend:user];

		// if he follows me, then he moves from pending to friend
		if (user.followsLocalUser)
		{
			[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] - 1];
		}
	}
	else
	{
		[OpenFeint postRemoveFriend:user];

		// if he follows me, then he moves from friend to pending
		if (user.followsLocalUser)
		{
			[OpenFeint setPendingFriendsCount:[OpenFeint pendingFriendsCount] + 1];
		}
	}	
}

- (void)onFollowFailedChangingState
{
	[self hideLoadingScreen];
}

#pragma mark Conversation / IM Handlers

- (IBAction)onInstantMessage
{
	[self showLoadingScreen];
	OFLog(@"get page context: %@", [self getPageContextUser]);
	
	[OFConversationService
		startConversationWithUser:[self getPageContextUser].resourceId
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

@end