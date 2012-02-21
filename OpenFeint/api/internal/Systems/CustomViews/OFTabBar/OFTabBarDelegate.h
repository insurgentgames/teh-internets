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

@class OFTabBar;
@class OFTabBarItem;

@protocol OFTabBarDelegate<NSObject>

@optional
- (void)tabBar:(OFTabBar*)tabBar didSelectViewController:(UIViewController *)viewController;
- (UIViewController*)tabBar:(OFTabBar*)tabBarController loadViewController:(NSString*)viewControllerName forTab:(OFTabBarItem*)tabItem;
- (void)tabBar:(OFTabBar*)tabBarController didLoadViewController:(UIViewController*)viewController fromTab:(OFTabBarItem*)tabItem;
- (void)tabBar:(OFTabBar*)tabBar willUnloadViewController:(UIViewController*)viewController fromTab:(OFTabBarItem*)tabItem;

- (void)tabBar:(OFTabBar*)tabBar didSelectTabItem:(OFTabBarItem*)tabItem;
- (void)tabBar:(OFTabBar*)tabBar didSelectTabNamed:(NSString*)tabName;
- (void)tabBar:(OFTabBar*)tabBar didSelectTabAtIndex:(int)index;

- (void)tabBar:(OFTabBar*)tabBar didDisableTabItem:(OFTabBarItem*)tabItem;
- (void)tabBar:(OFTabBar*)tabBar didDisableTabNamed:(NSString*)tabName;
- (void)tabBar:(OFTabBar*)tabBar didDisableTabAtIndex:(int)index;

@end