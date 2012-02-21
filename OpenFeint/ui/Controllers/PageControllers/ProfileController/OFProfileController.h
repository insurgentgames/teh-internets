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

#import "OFBannerProvider.h"
#import "OFViewController.h"
#import "OFCallbackable.h"

@class OFUser;
@class OFForumPost;
@class OFForumThreadViewController;
@class OFPaginatedSeriesHeader;
@class OFDefaultButton;

@interface OFProfileController : OFViewController< OFBannerProvider, OFCallbackable >
{
@package
	OFPaginatedSeriesHeader* friendsInfo;
	OFPaginatedSeriesHeader* gamesInfo;
	
	OFForumPost *reportUserForumPost;
	OFForumThreadViewController *forumThreadView;
	
	IBOutlet UILabel* friendsSubtextLabel;
	IBOutlet UILabel* gamesSubtextLabel;
	IBOutlet UIView* actionPanelView;
	IBOutlet OFDefaultButton* toggleFriendButton;
}

@property (retain) OFForumPost *reportUserForumPost;
@property (retain) OFForumThreadViewController *forumThreadView;

+ (void)showProfileForUser:(OFUser*)user;
+ (OFProfileController *)getProfileControllerForUser:(OFUser *)user andNavController:(UINavigationController *)currentNavController;

- (IBAction)onFlag;
- (IBAction)onToggleFollowing;
- (IBAction)onInstantMessage;

- (IBAction)onFriendsClicked;
- (IBAction)onGamesClicked;

@end
