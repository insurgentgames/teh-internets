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

#import "OFGameProfileController.h"

#import "OFGameProfilePageInfo.h"
#import "OFBadgeButton.h"
#import "OFButtonPanel.h"
#import "OFProvider.h"
#import "OFImageLoader.h"

#import "OFFanClubController.h"
#import "OFSelectChatRoomDefinitionController.h"
#import "OFLeaderboardController.h"
#import "OFAchievementListController.h"
#import "OFWhosPlayingController.h"
#import "OFChallengeListController.h"
#import "OFControllerLoader.h"
#import "OFUser.h"
#import "OFFramedNavigationController.h"
#import "OFClientApplicationService.h"
#import "OFAchievementService+Private.h"
#import "OFLeaderboardService+Private.h"
#import "OFAnnouncementService.h"

#import "IPhoneOSIntrospection.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+NSNotification.h"

#pragma mark Private Interface

@interface OFGameProfileController (Internal)
- (void)_switchToOnlineMode;
- (void)_stayInOfflineMode;
- (void)_downloadGameProfileInfo;
- (void)_downloadedGameProfile:(OFPaginatedSeries*)page;
- (void)_failedDownloadingGameProfile;
- (void)_refreshView;
- (void)_unviewedChallengesChanged:(NSNotification*)notice;
@end

@implementation OFGameProfileController

#pragma mark Initialization and Dealloc

+ (void)showGameProfileWithClientApplicationId:(NSString*)clientApplicationId compareToUser:(OFUser*)comparisonUser
{
	OFGameProfileController* controller = (OFGameProfileController*)OFControllerLoader::load(@"GameProfile");
	controller->clientApplicationId = [clientApplicationId retain];

	UINavigationController* currentNavController = [OpenFeint getActiveNavigationController];
	if (comparisonUser && ![comparisonUser isLocalUser] && [currentNavController isKindOfClass:[OFFramedNavigationController class]])
	{
		[(OFFramedNavigationController*)currentNavController pushViewController:controller animated:YES inContextOfLocalUserComparedTo:comparisonUser];
	}
	else
	{
		[currentNavController pushViewController:controller animated:YES];
	}
}

+ (void)showGameProfileWithClientApplicationId:(NSString*)clientApplicationId
{
	[OFGameProfileController showGameProfileWithClientApplicationId:clientApplicationId compareToUser:nil];
}

+ (void)showGameProfileWithLocalApplication
{
	[OFGameProfileController showGameProfileWithClientApplicationId:[OpenFeint clientApplicationId] compareToUser:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUnreadAnnouncementCountChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUnviewedChallengeCountChanged object:nil];

	OFSafeRelease(leaderboardsButton);
	OFSafeRelease(achievementsButton);
	OFSafeRelease(challengesButton);
	OFSafeRelease(discussionsButton);
	OFSafeRelease(discussionsLongButton);
	OFSafeRelease(fanClubButton);
	OFSafeRelease(fanClubLongButton);
	OFSafeRelease(whosPlayingButton);
	OFSafeRelease(whosPlayingLongButton);
	
	OFSafeRelease(backgroundView);
	OFSafeRelease(buttonPanel);

	OFSafeRelease(clientApplicationId);
	OFSafeRelease(gameProfileInfo);
	
	[super dealloc];
}

#pragma mark ButtonBehaviors

+ (void)setPushControllerData:(UIViewController*)controllerToPush withGameProfileInfo:(OFGameProfilePageInfo*)gameProfileInfo
{
	if ([controllerToPush isKindOfClass:[OFSelectChatRoomDefinitionController class]])
	{
		OFSelectChatRoomDefinitionController* chatController = (OFSelectChatRoomDefinitionController*)controllerToPush;
		chatController.includeGlobalRooms = NO;
		chatController.includeDeveloperRooms = YES;
		chatController.includeApplicationRooms = YES;
	}
	else if ([controllerToPush isKindOfClass:[OFLeaderboardController class]])
	{
		OFLeaderboardController* leaderboardController = (OFLeaderboardController*)controllerToPush;
		leaderboardController.gameProfileInfo = gameProfileInfo;
	}
	else if ([controllerToPush isKindOfClass:[OFAchievementListController class]])
	{
		OFAchievementListController* achievementController = (OFAchievementListController*)controllerToPush;
		achievementController.applicationName = gameProfileInfo.name;
		achievementController.applicationId = gameProfileInfo.resourceId;
		achievementController.applicationIconUrl = gameProfileInfo.iconUrl;
		achievementController.doesUserHaveApplication = gameProfileInfo.ownedByLocalPlayer;
	}
	else if ([controllerToPush isKindOfClass:[OFWhosPlayingController class]])
	{
		OFWhosPlayingController* whosPlayingController = (OFWhosPlayingController*)controllerToPush;
		whosPlayingController.applicationName = gameProfileInfo.name;
		whosPlayingController.applicationId = gameProfileInfo.resourceId;
		whosPlayingController.applicationIconUrl = gameProfileInfo.iconUrl;
	}
	else if ([controllerToPush isKindOfClass:[OFChallengeListController class]])
	{
		OFChallengeListController* challengeListController = (OFChallengeListController*)controllerToPush;
		challengeListController.clientApplicationId = gameProfileInfo.resourceId;
		challengeListController.listType = kChallengeListPending;
	}
}

- (void)pushController:(UIViewController*)controller
{
	[OFGameProfileController setPushControllerData:controller withGameProfileInfo:gameProfileInfo];
	OFAssert(controller != nil, "Must have a controller by now!");
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)pushControllerByName:(NSString*)controllerName
{
	UIViewController* controllerToPush = OFControllerLoader::load(controllerName);
	[self pushController:controllerToPush];
}

- (IBAction)pressedLeaderboards
{
	[self pushControllerByName:@"Leaderboard"];
}

- (IBAction)pressedAchievements
{
	[self pushControllerByName:@"AchievementList"];
}

- (IBAction)pressedChallenges
{
	[self pushControllerByName:@"ChallengeList"];
}

- (IBAction)pressedDiscussions
{
	static BOOL hasShownWarning = NO;	
	if (!hasShownWarning)
	{
		[[[[UIAlertView alloc] 
			initWithTitle:nil
			message:@"We will never ask for your password or contact information in forums or chat. Posting of profanity, hateful, or threatening material may result in account suspension or removal." 
			delegate:nil
			cancelButtonTitle:@"Ok" 
			otherButtonTitles:nil] autorelease] show];
		hasShownWarning = YES;
	}

	[self pushControllerByName:@"ForumTopicList"];
}

- (IBAction)pressedFanClub
{
	[self pushControllerByName:@"FanClub"];
}

- (IBAction)pressedWhosPlaying
{
	[self pushControllerByName:@"WhosPlaying"];
}

- (IBAction)pressedEnableOpenFeint
{
	[self showLoadingScreen];
	
	[OpenFeint addBootstrapDelegates:OFDelegate(self, @selector(_switchToOnlineMode)) onFailure:OFDelegate(self, @selector(_stayInOfflineMode))];

	OFDelegate success;
	OFDelegate failure(self, @selector(hideLoadingScreen));
	[OpenFeint presentUserFeintApprovalModal:success deniedDelegate:failure];
}

#pragma mark UIViewController Overrides

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[buttonPanel 
	 configureMaxButtonCount:6
	 buttonSize:([OpenFeint isInLandscapeMode] ? CGSizeMake(156.f, 97.f) : CGSizeMake(154.f, 118.f))
	 buttonSpacing:CGSizeZero
	 emptyImage:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (gameProfileInfo == nil)
	{
		[self _downloadGameProfileInfo];
	}
	
	if ([OpenFeint isOnline] == wasOfflineLastRefresh)
	{
		[self _refreshView];
	}
	
	[super viewDidAppear:animated];
}

#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	[OpenFeint dismissDashboard];
}

#pragma mark OFCallbackable Methods

- (bool)canReceiveCallbacksNow
{
	return true;
}

#pragma mark OFProfileFrame Methods

- (BOOL)supportsComparison
{
	return NO;
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	[self _downloadGameProfileInfo];
}

#pragma mark Internal Methods

- (void)refreshView
{
	[self _refreshView];
}

- (void)_downloadGameProfileInfo
{
	// somewhat-hack to not show loading screen for local page. :(
	if ([clientApplicationId length] > 0 && ![[OpenFeint clientApplicationId] isEqualToString:clientApplicationId])
	{
		[self showLoadingScreen];
	}

	[OFClientApplicationService getGameProfilePageInfo:clientApplicationId 
		onSuccess:OFDelegate(self, @selector(_downloadedGameProfile:)) 
		onFailure:OFDelegate(self, @selector(_failedDownloadingGameProfile))];
}

- (void)_switchToOnlineMode
{
	[OpenFeint switchToOnlineDashboard];
	[self _downloadGameProfileInfo];
}

- (void)_stayInOfflineMode
{
	[self hideLoadingScreen];
	[self _refreshView];
}

- (void)_downloadedGameProfile:(OFPaginatedSeries*)page
{
	OFAssert([page count] > 0, "This shouldn't succeed unless I got at least 1 item.");

	[self hideLoadingScreen];
	OFSafeRelease(gameProfileInfo);
	gameProfileInfo = [(OFGameProfilePageInfo*)[page objectAtIndex:0] retain];

	[(OFFramedNavigationController*)self.navigationController changeGameContext:gameProfileInfo];
		
	if ([gameProfileInfo.shortName length] > 0)
	{
		self.title = gameProfileInfo.shortName;
	}
	[self _refreshView];
}

- (void)_failedDownloadingGameProfile
{
	[self hideLoadingScreen];
	OFSafeRelease(gameProfileInfo);
	[self _refreshView];
}

- (void)_refreshView
{
	wasOfflineLastRefresh = NO;

	leaderboardsButton.hidden = YES;
	achievementsButton.hidden = YES;
	challengesButton.hidden = YES;
	discussionsButton.hidden = YES;
	fanClubButton.hidden = YES;
	whosPlayingButton.hidden = YES;

	discussionsLongButton.hidden = YES;
	fanClubLongButton.hidden = YES;
	whosPlayingLongButton.hidden = YES;	

	enum eVisibleButtonFlags
	{
		kVisibleButtonFlag_Leaderboards	= 1<<0,
		kVisibleButtonFlag_Achievements	= 1<<1,
		kVisibleButtonFlag_Challenges	= 1<<2,
		kVisibleButtonFlag_Discussions	= 1<<3,
		kVisibleButtonFlag_FanClub		= 1<<4,
		kVisibleButtonFlag_WhosPlaying	= 1<<5,
	};
	
	unsigned int visibleButtonFlags = 0;

	int buttonIndex = 0;
	[buttonPanel removeAllButtons];
	[buttonPanel setHeaderView:nil];

	// build up the visible flags from the game profile info.
	if (gameProfileInfo.hasLeaderboards)
	{
		visibleButtonFlags |= kVisibleButtonFlag_Leaderboards;
	}

	if (gameProfileInfo.hasAchievements)
	{
		visibleButtonFlags |= kVisibleButtonFlag_Achievements;
	}

	if (gameProfileInfo.hasChallenges)
	{
		visibleButtonFlags |= kVisibleButtonFlag_Challenges;
	}

	if ([OpenFeint allowUserGeneratedContent] /*&& (!clientApplicationId || [clientApplicationId isEqualToString:[OpenFeint clientApplicationId]])*/)
	{
		visibleButtonFlags |= kVisibleButtonFlag_Discussions;
	}
	
	visibleButtonFlags |= kVisibleButtonFlag_FanClub;
	visibleButtonFlags |= kVisibleButtonFlag_WhosPlaying;

	// If we -only- have the three buttons that we have long buttons for...
	const unsigned int kMask = ~(kVisibleButtonFlag_Discussions | kVisibleButtonFlag_FanClub | kVisibleButtonFlag_WhosPlaying);
	if (discussionsLongButton && fanClubLongButton && whosPlayingLongButton && (visibleButtonFlags & kMask) == 0)
	{
		usingLongButtons = YES;
		
		[buttonPanel
		 configureMaxButtonCount:3
		 buttonSize:([OpenFeint isInLandscapeMode] ? CGSizeMake(468.f, 65.f) : CGSizeMake(308.f, 65.f))
		 buttonSpacing:CGSizeZero
		 emptyImage:nil];
		
		if (visibleButtonFlags & kVisibleButtonFlag_Discussions)
		{
			[buttonPanel setButton:discussionsLongButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_FanClub)
		{
			if ([gameProfileInfo.resourceId isEqualToString:[OpenFeint localGameProfileInfo].resourceId])
			{
				[fanClubLongButton setBadgeNumber:[OFAnnouncementService unreadAnnouncements]];
			}
			[buttonPanel setButton:fanClubLongButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_WhosPlaying)
		{
			[buttonPanel setButton:whosPlayingLongButton atPosition:buttonIndex++];
		}
	}
	else
	{
		usingLongButtons = NO;
		
		// We can't use the long buttons.
		[buttonPanel 
		 configureMaxButtonCount:6
		 buttonSize:([OpenFeint isInLandscapeMode] ? CGSizeMake(156.f, 97.f) : CGSizeMake(154.f, 118.f))
		 buttonSpacing:CGSizeZero
		 emptyImage:nil];
		
		if (visibleButtonFlags & kVisibleButtonFlag_Leaderboards)
		{
			[buttonPanel setButton:leaderboardsButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_Achievements)
		{
			[buttonPanel setButton:achievementsButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_Challenges)
		{
			if ([gameProfileInfo.resourceId isEqualToString:[OpenFeint localGameProfileInfo].resourceId])
			{
				[challengesButton setBadgeNumber:[OpenFeint unviewedChallengesCount]];
			}
			[buttonPanel setButton:challengesButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_Discussions)
		{
			[buttonPanel setButton:discussionsButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_FanClub)
		{
			if ([gameProfileInfo.resourceId isEqualToString:[OpenFeint localGameProfileInfo].resourceId])
			{
				[fanClubButton setBadgeNumber:[OFAnnouncementService unreadAnnouncements]];
			}
			[buttonPanel setButton:fanClubButton atPosition:buttonIndex++];
		}
		
		if (visibleButtonFlags & kVisibleButtonFlag_WhosPlaying)
		{
			[buttonPanel setButton:whosPlayingButton atPosition:buttonIndex++];
		}
	}

	
	if (![OpenFeint isOnline])
	{
		UIImage* offlineImage = nil;
		
		// @TODO: will this catch on fire?
		
		// everything except leaderboards & achievements is disabled
		[buttonPanel disableButton:challengesButton withDecorationImage:offlineImage];
		[buttonPanel disableButton:discussionsButton withDecorationImage:offlineImage];
		[buttonPanel disableButton:whosPlayingButton withDecorationImage:offlineImage];
		[buttonPanel disableButton:fanClubButton withDecorationImage:offlineImage];

		int activeButtons = 2;
		
		// disable achievements also if we haven't downloaded any data for them
		if (![OFAchievementService hasAchievements])
		{
			[buttonPanel disableButton:achievementsButton withDecorationImage:offlineImage];
			--activeButtons;
		}
			
		// and leaderboards too
		if (![OFLeaderboardService hasLeaderboards])
		{
			[buttonPanel disableButton:leaderboardsButton withDecorationImage:offlineImage];
			--activeButtons;
		}

		wasOfflineLastRefresh = YES;
		
		if (!activeButtons)
		{
			[[[[UIAlertView alloc] initWithTitle:@"No offline support" 
										 message:[NSString stringWithFormat:@"No offline functionality has been enabled for %@", gameProfileInfo.shortName]
										delegate:nil
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil] autorelease] show];
		}
	}
}

#pragma mark Notifications

- (void)registerForBadgeNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_unviewedChallengesChanged:) name:OFNSNotificationUnviewedChallengeCountChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_unreadAnnouncementsChanged:) name:OFNSNotificationUnreadAnnouncementCountChanged object:nil];
}

- (void)_unreadAnnouncementsChanged:(NSNotification*)notification
{
	NSUInteger unreadAnnouncements = [(NSNumber*)[[notification userInfo] objectForKey:OFNSNotificationInfoUnreadAnnouncementCount] unsignedIntegerValue];
	if (usingLongButtons)
		[fanClubLongButton setBadgeNumber:unreadAnnouncements];
	else
		[fanClubButton setBadgeNumber:unreadAnnouncements];
	
	[self setBadgeValue:[NSString stringWithFormat:@"%u", unreadAnnouncements + challengesButton.badgeNumber]];
}

- (void)_unviewedChallengesChanged:(NSNotification*)notice
{
	if (gameProfileInfo.hasChallenges)
	{
		NSUInteger unviewedChallenges = [(NSNumber*)[[notice userInfo] objectForKey:OFNSNotificationInfoUnviewedChallengeCount] unsignedIntegerValue];
		[challengesButton setBadgeNumber:unviewedChallenges];
		[self setBadgeValue:[NSString stringWithFormat:@"%u", unviewedChallenges + fanClubButton.badgeNumber]];
	}
}

#pragma mark OFBannerProvider
	
- (bool)isBannerAvailableNow
{
	// only if we're the top one.  note that since this can be
	// -before- the view controller is pushed, there'll be zero instead of 1,
	// so we need to account for that.
	int ct = self.navigationController.viewControllers.count;
	return ct <= 1;
}

- (NSString*)bannerCellControllerName
{
	return @"FeaturedGame";
}

- (OFResource*)getBannerResource
{
	return nil;
}

- (void)onBannerClicked
{
	// do nothing
}

@end
