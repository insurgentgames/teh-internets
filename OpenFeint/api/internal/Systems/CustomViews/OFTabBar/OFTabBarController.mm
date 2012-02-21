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
#import "OFTabBarController.h"
#import "OFTabBarContainer.h"
#import "OFTabBar.h"
#import "OFImageLoader.h"
#import "UIViewController+TabBar.h"
#import "OpenFeint+Private.h"

@implementation OFTabBarController

@synthesize delegate = mDelegate;
@synthesize tabBar = mTabBar;
@dynamic tabBarItems;

+ (float)tabBarHeight
{
	return 49.f;
}

- (OFTabBar*)createTabBar
{
	return [[[OFTabBar alloc] initWithFrame:CGRectMake(0, mContainerView.frame.size.height - [OFTabBarController tabBarHeight], mContainerView.frame.size.width, [OFTabBarController tabBarHeight])] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self != nil)
	{
		mContainerView = [[OFTabBarContainer containerWithFrame:frame] retain];
		
		mTabBar = [[self createTabBar] retain];
		mTabBar.delegate = self;
		
		[mContainerView addSubview:mTabBar];

		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(unloadAllInactiveTabs)
			name:UIApplicationDidReceiveMemoryWarningNotification
			object:nil];
	}
	return self;
}

- (id)init
{
	return [self initWithFrame:[OpenFeint getDashboardBounds]];
}

- (void)viewDidLoad
{
	self.view = mContainerView;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

	OFSafeRelease(mTabBar);
	OFSafeRelease(mContainerView);
	self.view = nil;
	[super dealloc];
}

- (void)addViewController:(NSString*)controllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath
{
	UIImage* activeImage = activeImagePath ? [OFImageLoader loadImage:activeImagePath] : nil;
	UIImage* inactiveImage = inactiveImagePath ? [OFImageLoader loadImage:inactiveImagePath] : nil;
	UIImage* disabledImage = disabledImagePath ? [OFImageLoader loadImage:disabledImagePath] : nil;
	[mTabBar addViewController:controllerName named:title activeImage:activeImage inactiveImage:inactiveImage disabledImage:disabledImage];
}

- (void)addViewController:(NSString*)controllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath andBadgeValue:(NSString*)badgeValue
{
	[self addViewController:controllerName 
   ofDisabledControllerName:nil 
					  named:title 
				activeImage:activeImagePath 
			  inactiveImage:inactiveImagePath 
			  disabledImage:disabledImagePath 
			  andBadgeValue:badgeValue];
}

- (void)addViewController:(NSString*)controllerName 
 ofDisabledControllerName:(NSString*)ofDisabledControllerName 
					named:(NSString*)title 
			  activeImage:(NSString*)activeImagePath 
			inactiveImage:(NSString*)inactiveImagePath 
			disabledImage:(NSString*)disabledImagePath 
{
	[self addViewController:controllerName
   ofDisabledControllerName:ofDisabledControllerName
					  named:title
				activeImage:activeImagePath
			  inactiveImage:inactiveImagePath
			  disabledImage:disabledImagePath
			  andBadgeValue:nil];
}

- (void)addViewController:(NSString*)controllerName 
 ofDisabledControllerName:(NSString*)ofDisabledControllerName 
					named:(NSString*)title 
			  activeImage:(NSString*)activeImagePath 
			inactiveImage:(NSString*)inactiveImagePath 
			disabledImage:(NSString*)disabledImagePath 
			andBadgeValue:(NSString*)badgeValue
{
	UIImage* activeImage = activeImagePath ? [OFImageLoader loadImage:activeImagePath] : nil;
	UIImage* inactiveImage = inactiveImagePath ? [OFImageLoader loadImage:inactiveImagePath] : nil;
	UIImage* disabledImage = disabledImagePath ? [OFImageLoader loadImage:disabledImagePath] : nil;
	[mTabBar addViewController:controllerName 
	  ofDisabledViewController:ofDisabledControllerName 
						 named:title 
				   activeImage:activeImage 
				 inactiveImage:inactiveImage 
				 disabledImage:disabledImage];
	
	if (badgeValue)
	{
		[[mTabBar.items lastObject] setBadgeValue:badgeValue];
	}
}

- (NSArray*)tabBarItems
{
	return mTabBar.items;
}

- (void)showTabViewControllerNamed:(NSString*)tabViewControllerName
{
	[self showTabViewControllerNamed:tabViewControllerName showAtRoot:NO];
}

- (void)showTabViewControllerNamed:(NSString*)tabViewControllerName showAtRoot:(BOOL)showAtRoot
{
	[mTabBar showTabViewControllerNamed:tabViewControllerName showAtRoot:showAtRoot];
	[self.delegate tabBarController:self didSelectViewController:mTabBar.selectedViewController];
}

- (void)showTabNamed:(NSString*)tabName
{
	[self showTabNamed:tabName showAtRoot:NO];
}

- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot
{
	[mTabBar showTabNamed:tabName showAtRoot:showAtRoot];
	[self.delegate tabBarController:self didSelectViewController:mTabBar.selectedViewController];
}

- (void)showTabAtIndex:(int)index
{
	[self showTabAtIndex:index showAtRoot:NO];
}

- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot
{
	[mTabBar showTabAtIndex:index showAtRoot:showAtRoot];
	[self.delegate tabBarController:self didSelectViewController:mTabBar.selectedViewController];
}

- (void)enableAllTabs
{
	[mTabBar enableAllTabs];
}

- (void)disableTabAtIndex:(int)index
{
	[mTabBar disableTabAtIndex:index];
}

- (void)disableTabNamed:(NSString*)tabName
{
	[mTabBar disableTabNamed:tabName];
}

- (void)disableTabViewControllerNamed:(NSString*)tabViewControllerName
{
	[mTabBar disableTabViewControllerNamed:tabViewControllerName];
}

- (void)unloadAllInactiveTabs
{
	[mTabBar unloadAllInactiveTabs];
}

- (void)forceUnloadAllTabs
{
	[mTabBar forceUnloadAllTabs];
}

- (void)unloadTabBarItemNamed:(NSString*)tabName
{
	[mTabBar unloadTabBarItemNamed:tabName];
}

- (void)tabBar:(OFTabBar*)tabBar willUnloadViewController:(UIViewController*)viewController fromTab:(OFTabBarItem*)tabItem
{
	if ([self.delegate respondsToSelector:@selector(tabBarController:willUnloadViewController:fromTab:)])
	{
		[self.delegate tabBarController:self willUnloadViewController:viewController fromTab:tabItem];
	}
}

- (void)tabBar:(OFTabBar*)tabBar didSelectViewController:(UIViewController *)viewController
{
	[self.delegate tabBarController:self didSelectViewController:viewController];
}

- (void)tabBar:(OFTabBar*)tabBar didLoadViewController:(UIViewController*)viewController fromTab:(OFTabBarItem*)tabItem
{
	if ([viewController respondsToSelector:@selector(setOwningTabBarItem:)]) {
		[viewController setOwningTabBarItem:tabItem];
	}
	
	[self.delegate tabBarController:self didLoadViewController:viewController fromTab:tabItem];
}

@end
