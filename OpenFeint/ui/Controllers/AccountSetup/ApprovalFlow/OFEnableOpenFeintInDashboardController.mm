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

#import "OFEnableOpenFeintInDashboardController.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Dashboard.h"
#import "OFLoadingController.h"
#import "OFViewHelper.h"
#import "OFContentFrameView.h"
#import "OFPatternedGradientView.h"
#import "OFTabBarController.h"
#import "OFRootController.h"
#import "OFGameProfilePageInfo.h"
#import "OFLeaderboardController.h"
#import "OFControllerLoader.h"

@implementation OFEnableOpenFeintInDashboardController

@synthesize appNameLabel, enableOpenFeintButton, leaderboardsButton;

- (void)viewDidLoad
{
    appNameLabel.text = [NSString stringWithFormat:@"%@ is Feint Enabled!", [OpenFeint applicationDisplayName]];
}

- (void)viewWillAppear:(BOOL)animated
{
	OFGameProfilePageInfo* localGameProfileInfo = [OpenFeint localGameProfileInfo];
	if (!localGameProfileInfo || !localGameProfileInfo.hasLeaderboards)
	{
		self.enableOpenFeintButton.center = CGPointMake((self.enableOpenFeintButton.center.x + self.leaderboardsButton.center.x) * 0.5f, self.leaderboardsButton.center.y);
		self.leaderboardsButton.hidden = YES;
	}
	
	[super viewWillAppear:animated];
}

- (IBAction)clickedEnableOpenFeint
{
	[OpenFeint allowErrorScreens:NO];
	OFDelegate success(self, @selector(_switchToOnlineMode));
	[OpenFeint setUserApprovedFeint];
	[OpenFeint presentConfirmAccountModal:success useModalInDashboard:YES];
}

- (IBAction)clickedLeaderboards
{
	OFLeaderboardController* leaderboardController = (OFLeaderboardController*)OFControllerLoader::load(@"Leaderboard");
	leaderboardController.gameProfileInfo = [OpenFeint localGameProfileInfo];
	[self.navigationController pushViewController:leaderboardController animated:YES];
}

- (void)_switchToOnlineMode
{
	[OpenFeint allowErrorScreens:YES];
	OFRootController* rootController = (OFRootController*)[OpenFeint getRootController];
	if (![rootController isKindOfClass:[OFRootController class]])
	{
		return;
	}
	UIViewController* topController = rootController.contentController;
	if([topController isKindOfClass:[OFTabBarController class]])
	{
		OFTabBarController* tabController = (OFTabBarController*)topController;
		[tabController forceUnloadAllTabs];
		[tabController showTabAtIndex:0];
	}
}

- (void)_stayInOfflineMode
{
	[self hideLoadingScreen];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc
{
    self.appNameLabel = nil;
	self.leaderboardsButton = nil;
	self.enableOpenFeintButton = nil;
	[super dealloc];
}

@end