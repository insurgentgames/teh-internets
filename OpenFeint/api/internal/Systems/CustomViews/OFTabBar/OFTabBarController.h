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

#pragma once

#import "OFTabBarControllerDelegate.h"
#import "OFTabBarDelegate.h"

@class OFTabBar;
@class OFTabBarContainer;

@interface OFTabBarController : UIViewController<OFTabBarDelegate>
{
	OFTabBar* mTabBar;
	OFTabBarContainer* mContainerView;
	
	id<OFTabBarControllerDelegate> mDelegate;
}

@property (assign, nonatomic) id<OFTabBarControllerDelegate> delegate;
@property (readonly, nonatomic) NSArray* tabBarItems;
@property (readonly, nonatomic) OFTabBar* tabBar;

+ (float)tabBarHeight;

- (void)addViewController:(NSString*)controllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath;
- (void)addViewController:(NSString*)controllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath andBadgeValue:(NSString*)badgeValue;
- (void)addViewController:(NSString*)controllerName ofDisabledControllerName:(NSString*)ofDisabledControllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath;
- (void)addViewController:(NSString*)controllerName ofDisabledControllerName:(NSString*)ofDisabledControllerName named:(NSString*)title activeImage:(NSString*)activeImagePath inactiveImage:(NSString*)inactiveImagePath disabledImage:(NSString*)disabledImagePath andBadgeValue:(NSString*)badgeValue;

- (void)showTabAtIndex:(int)index;
- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot;

- (void)showTabNamed:(NSString*)tabName;
- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot;

- (void)showTabViewControllerNamed:(NSString*)tabViewControllerName;
- (void)showTabViewControllerNamed:(NSString*)tabViewControllerName showAtRoot:(BOOL)showAtRoot;

- (void)enableAllTabs;

- (void)disableTabAtIndex:(int)index;
- (void)disableTabNamed:(NSString*)tabName;
- (void)disableTabViewControllerNamed:(NSString*)tabViewControllerName;

- (void)unloadAllInactiveTabs;
- (void)forceUnloadAllTabs;
- (void)unloadTabBarItemNamed:(NSString*)tabName;

// For subclasses that have additional content to wrap around us
- (id)initWithFrame:(CGRect)frame;

@end