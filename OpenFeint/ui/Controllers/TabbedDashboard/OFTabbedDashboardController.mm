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
#import "OFTabbedDashboardController.h"
#import "OFTabbedDashboardPageController.h"
#import "OFSelectChatRoomDefinitionController.h"
#import "OFControllerLoader.h"
#import "OFNavigationController.h"
#import "OFGameProfileController.h"
#import "OFPlayedGameController.h"
#import "OFFriendsController.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Dashboard.h"
#import "OFRootController.h"
#import "OFTabBarItem.h"
#import "OFColors.h"
#import "OFImageLoader.h"
#import "OFTicker.h"
#import "OFTickerView.h"
#import "OFTickerService.h"
#import "OFTabBarContainer.h"
#import "OFBadgeView.h"
#import "OFAnnouncementService.h"

NSString* globalChatRoomControllerName = @"SelectChatRoomDefinition";
NSString* globalChatRoomTabName = @"Feint Lobby";
static const float kfTickerHeight = 24.f;
static const float kfTabBarHeight = 36.f;
static const float kfShieldWidth = 40.f;
static const float kfShieldYOffset = 19.f;
static const float kfShieldHeight = 2.0f * (kfTickerHeight - kfShieldYOffset);

@implementation OFTabbedDashboardController

- (void)tabBarController:(OFTabBarController*)tabBarController didLoadViewController:(UIViewController*)viewController fromTab:(OFTabBarItem*)tabItem
{
	OFNavigationController* navController = (OFNavigationController*)tabItem.viewController;

	if(navController)
	{
		if(viewController == tabItem.viewController && [tabItem.name isEqualToString:globalChatRoomTabName])
		{
			OFSelectChatRoomDefinitionController* globalChatRoomController = (OFSelectChatRoomDefinitionController*)navController.visibleViewController;
			globalChatRoomController.includeGlobalRooms = YES;
			globalChatRoomController.includeDeveloperRooms = NO;
			globalChatRoomController.includeApplicationRooms = NO;
		}
		else if (viewController == tabItem.viewController && [[(OFTabbedDashboardPageController*)tabItem.viewController topViewController] isKindOfClass:[OFGameProfileController class]])
		{
			OFGameProfileController* nowPlayingController = (OFGameProfileController*)navController.visibleViewController;
			nowPlayingController.title = [OpenFeint applicationShortDisplayName];
			[nowPlayingController registerForBadgeNotifications];
		}
	}
}

- (void)newTickerMessage:(NSString *)_message
{
	mTickerView.text = _message;
}

- (void)textFinishedScrolling
{
	// We don't know if we got called from a timer or from an animation completion -
	// regardless, the timer will be invalid at this point.
	mTickerTimer = nil;
	
	if ([[OpenFeint getRootController] modalViewController] != nil)
	{
		// A modal's up.  I'll take another ticker message in a few seconds, please.
		mTickerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(textFinishedScrolling) userInfo:nil repeats:NO];
	}
	else
	{
		[OFTickerProxy getNextMessage:self];
	}
}

- (UIViewController*)tabBar:(OFTabBar*)tabBarController loadViewController:(NSString*)viewControllerName forTab:(OFTabBarItem*)tabItem
{
	return [OFTabbedDashboardPageController pageWithController:viewControllerName];
}

- (OFTabBar*)createTabBar
{
	OFTabBar* ret = [[[OFTabBar alloc] initWithFrame:CGRectMake(0, mContainerView.frame.size.height - kfTabBarHeight, mContainerView.frame.size.width, kfTabBarHeight)] autorelease];
	ret.leftPadding = [OpenFeint isInLandscapeMode] ? 7.f : 6.f;
	ret.style = OFTabBarStyleDashboard;
	return ret;
}

- (void)_addAllViewControllers
{
	NSString *nowPlayingBadge = [NSString stringWithFormat:@"%u", [OpenFeint unviewedChallengesCount] + [OFAnnouncementService unreadAnnouncements]];
	NSString *myFeintBadge    = [NSString stringWithFormat:@"%u", [OpenFeint pendingFriendsCount] + [OpenFeint unreadInboxCount]];

	if ([OpenFeint isInLandscapeMode])
	{
		[self addViewController:OpenFeintDashBoardTabNowPlaying ofDisabledControllerName:@"EnableOpenFeintInDashboard" named:[OpenFeint applicationShortDisplayName] activeImage:@"OFDashboardTabNowPlayingLandscapeHit.png" inactiveImage:@"OFDashboardTabNowPlayingLandscape.png" disabledImage:nil andBadgeValue:nowPlayingBadge];
		[self addViewController:OpenFeintDashBoardTabMyFeint	named:@"My Feint" activeImage:@"OFDashboardTabMyFeintLandscapeHit.png" inactiveImage:@"OFDashboardTabMyFeintLandscape.png" disabledImage:@"OFDashboardTabMyFeintLandscapeDisabled.png" andBadgeValue:myFeintBadge];
		[self addViewController:OpenFeintDashBoardTabGames		named:@"Games" activeImage:@"OFDashboardTabDiscoveryLandscapeHit.png" inactiveImage:@"OFDashboardTabDiscoveryLandscape.png" disabledImage:@"OFDashboardTabDiscoveryLandscapeDisabled.png"];
	}
	else
	{
		[self addViewController:OpenFeintDashBoardTabNowPlaying ofDisabledControllerName:@"EnableOpenFeintInDashboard" named:[OpenFeint applicationShortDisplayName] activeImage:@"OFDashboardTabNowPlayingPortraitHit.png" inactiveImage:@"OFDashboardTabNowPlayingPortrait.png" disabledImage:nil andBadgeValue:nowPlayingBadge];
		[self addViewController:OpenFeintDashBoardTabMyFeint	named:@"My Feint" activeImage:@"OFDashboardTabMyFeintPortraitHit.png" inactiveImage:@"OFDashboardTabMyFeintPortrait.png" disabledImage:@"OFDashboardTabMyFeintPortraitDisabled.png" andBadgeValue:myFeintBadge];
		[self addViewController:OpenFeintDashBoardTabGames		named:@"Games" activeImage:@"OFDashboardTabDiscoveryPortraitHit.png" inactiveImage:@"OFDashboardTabDiscoveryPortrait.png" disabledImage:@"OFDashboardTabDiscoveryPortraitDisabled.png"];
	}
}

- (id)init
{
	CGRect viewFrame = [OpenFeint getDashboardBounds];
	CGRect tickerFrame = CGRectMake(0, 0, viewFrame.size.width, kfTickerHeight);
	CGRect containerFrame = CGRectMake(0, kfTickerHeight, viewFrame.size.width, viewFrame.size.height - kfTickerHeight);
	CGRect uidsFrame = CGRectMake(viewFrame.size.width - kfShieldWidth, kfShieldYOffset, kfShieldWidth, kfShieldHeight);

	self = [super initWithFrame:containerFrame];
	if (self != nil)
	{
		mHostView = [[UIView alloc] initWithFrame:viewFrame];
		
		// build the ticker
		Class tickerClass = (Class)OFControllerLoader::getViewClass(@"Ticker");
		mTickerView = [(OFTickerView*)[tickerClass alloc] initWithDelegate:self andFrame:tickerFrame];
		[mHostView addSubview:mTickerView];

		// Don't release it yet!  Hold on to it till dealloc so we can safely set its delegate to nil.
		
		// add the container view
		[mHostView addSubview:mContainerView];

		// get a message out of the proxy
		[OFTickerProxy getNextMessage:self];
		
		CGSize badgeSize = [OFBadgeView minimumSize];
		self.tabBar.badgeOffset = CGPointMake(badgeSize.width * 0.2f, badgeSize.height * -0.2f);		
		self.tabBar.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
		self.tabBar.changeZOrderOnTap = false;
		self.tabBar.inactiveTextColor = [UIColor colorWithWhite:118.f/255.f alpha:1.0];
		self.tabBar.activeTextColor = [UIColor colorWithRed:225.f/255.f green:1.f blue:230.f/255.f alpha:1.f];
		self.tabBar.dividerImage = [OFImageLoader loadImage:@"OFTabBarDivider.png"];
		self.tabBar.pulse = NO;
        
		[self _addAllViewControllers];

		[mHostView bringSubviewToFront:mTickerView];

		// Put a 'shield' in front of the ticker and content views so that ambiguous touches won't hit either.

		if ([OpenFeint isInLandscapeMode])
		{
			UIView* userInputDisambiguationShield = [[UIView alloc] initWithFrame:uidsFrame];
			userInputDisambiguationShield.userInteractionEnabled = YES; // block all clicks
			userInputDisambiguationShield.backgroundColor = [UIColor clearColor];
			[mHostView addSubview:userInputDisambiguationShield];
			[userInputDisambiguationShield release];
		}
		
		if (![OpenFeint isOnline])
		{
			[OFTabbedDashboardController setOfflineMode:self];
		}

		self.delegate = self;
	}
	return self;
}

- (void)viewDidLoad
{
	self.view = mHostView;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// If we've closed, the ticker timer may still be retaining us.  clear it out
	// so we can be deallocated in peace.
	if (mTickerTimer)
	{
		[mTickerTimer invalidate];
	}
}

- (void)tabBarController:(OFTabBarController*)tabBarController didSelectViewController:(UIViewController *)viewController
{
	for (OFTabBarItem* tabItem in self.tabBarItems)
	{
		OFNavigationController* navController = (OFNavigationController*)tabItem.viewController;

		if(navController)
		{
			OFAssert([navController isKindOfClass:[OFNavigationController class]], @"all tab bar items need to be navigation controllers");
			navController.isInHiddenTab = (navController != viewController);
		}
	}
}

+ (void)_setOnlineMode:(OFTabBarController*)tabBarController
{
	[tabBarController enableAllTabs];
	
	[tabBarController unloadTabBarItemNamed:OpenFeintDashBoardTabNowPlaying];
}

+ (void)_setOfflineMode:(OFTabBarController*)tabBarController
{
	[tabBarController disableTabViewControllerNamed:OpenFeintDashBoardTabGames];
	[tabBarController disableTabViewControllerNamed:OpenFeintDashBoardTabMyFeint];
}

+ (void)setOnlineMode:(OFTabBarController*)tabBarController
{
	// dispatch to override class
	[OFControllerLoader::getControllerClass(@"TabbedDashboard") _setOnlineMode:tabBarController];

	if ([tabBarController conformsToProtocol:@protocol(OFTickerProxyRecipient)])
	{
		[OFTickerProxy getNextMessage:(OFTabBarController<OFTickerProxyRecipient>*)tabBarController];
	}
}

+ (void)setOfflineMode:(OFTabBarController*)tabBarController
{
	// dispatch to override class
	[OFControllerLoader::getControllerClass(@"TabbedDashboard") _setOfflineMode:tabBarController];
}

- (NSString*)defaultTab
{
	return OpenFeintDashBoardTabNowPlaying;
}

- (NSString*)offlineTab
{
	return OpenFeintDashBoardTabNowPlaying;
}

// OFTickerViewDelegate methods
- (void)onXPressed
{
	[OpenFeint dismissDashboard];
}

- (void)dealloc
{
	// Make sure the ticker knows we're not around to answer its messages anymore!
	if (mTickerView)
	{
		mTickerView.delegate = nil;
		[mTickerView release];
	}
	
	// If we have any reqs in flight, we're being dealloced, so cancel them.
	[OFTickerProxy neverMind:self];
	
	OFSafeRelease(mHostView);

	[super dealloc];
}

@end
