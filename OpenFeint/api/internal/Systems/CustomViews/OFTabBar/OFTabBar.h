////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// 
///	Copyright 2009 Aurora Feint, Inc.
/// 
///	Licensed under the Apache License, Version 2.0 (the "License");
///	you may not use this file except in compliance with the License.
///	You may obtain a copy of the License at
///	
///		http://www.apache.org/licenses/LICENSE-2.0
///		
///	Unless required by applicable law or agreed to in writing, software
///	distributed under the License is distributed on an "AS IS" BASIS,
///	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///	See the License for the specific language governing permissions and
///	limitations under the License.
/// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma once

#import "OFTabBarItem.h"
#import "OFTabBarDelegate.h"

@class OFTabBarItem;

typedef enum {
	OFTabBarStyleTraditional,
	OFTabBarStyleSegments,
	OFTabBarStyleDashboard,
} OFTabBarStyle;

@interface OFTabBar : UIView
{
	UIImageView* backgroundImageView;
	
	NSMutableArray* items;
	OFTabBarItem* selectedTab;
	IBOutlet id<OFTabBarDelegate> delegate;
	
	OFTabBarStyle style;
	
	UIColor* inactiveTextColor;
	UIColor* inactiveShadowColor;
	UIColor* activeTextColor;
	UIColor* activeShadowColor;
	UIColor* disabledTextColor;
	UIColor* disabledShadowColor;
	
	CGPoint badgeOffset;
	BOOL	placeBadgeTopRight;
	UIImage* dividerImage;
	UIImage* activeItemBackgroundImage;
	UIImage* inactiveItemBackgroundImage;
	UIImage* disabledItemBackgroundImage;
	UIImage* hitOverlayImage;
	UIImage* disabledOverlayIconImage;

	float leftPadding;
	float rightPadding;
	float overlap;
	CGRect labelPadding;
	BOOL pulse;
	UITextAlignment textAlignment;
	
	BOOL changeZOrderOnTap;
}

@property (readonly, nonatomic) NSMutableArray* items;

@property (assign, nonatomic) OFTabBarStyle style;
@property (retain, nonatomic) UIColor* inactiveTextColor;
@property (retain, nonatomic) UIColor* inactiveShadowColor;
@property (retain, nonatomic) UIColor* activeTextColor;
@property (retain, nonatomic) UIColor* activeShadowColor;
@property (retain, nonatomic) UIColor* disabledTextColor;
@property (retain, nonatomic) UIColor* disabledShadowColor;
@property (assign, nonatomic) CGPoint badgeOffset;
@property (assign, nonatomic) BOOL placeBadgeTopRight;
@property (retain, nonatomic) UIImage* dividerImage;
@property (retain, nonatomic) UIImage* activeItemBackgroundImage;
@property (retain, nonatomic) UIImage* inactiveItemBackgroundImage;
@property (retain, nonatomic) UIImage* disabledItemBackgroundImage;
@property (retain, nonatomic) UIImage* hitOverlayImage;
@property (retain, nonatomic) UIImage* disabledOverlayIconImage;

@property (assign, nonatomic) float leftPadding;
@property (assign, nonatomic) float rightPadding;
@property (assign, nonatomic) float overlap;
@property (assign, nonatomic) CGRect labelPadding;
@property (assign, nonatomic) BOOL pulse;
@property (assign, nonatomic) UITextAlignment textAlignment;

@property (assign, nonatomic) BOOL changeZOrderOnTap;

@property (assign, nonatomic) id<OFTabBarDelegate> delegate;

@property (readonly, nonatomic) UIViewController* selectedViewController;
@property (readonly, nonatomic) OFTabBarItem* selectedTab;

- (void)_commonInit;

- (void)addViewController:(NSString*)aViewController
										named:(NSString*)aName
							activeImage:(UIImage*)anActiveImage
						inactiveImage:(UIImage*)anInactiveImage
                        disabledImage:(UIImage*)aDisabledImage;

- (void)addViewController:(NSString*)aViewController
 ofDisabledViewController:(NSString*)ofDisabledViewController
					named:(NSString*)aName
			  activeImage:(UIImage*)anActiveImage
			inactiveImage:(UIImage*)anInactiveImage
			disabledImage:(UIImage*)aDisabledImage;

- (void)addSegmentNamed:(NSString*)aName
						activeImage:(UIImage*)anActiveImage
					inactiveImage:(UIImage*)anInactiveImage
                    disabledImage:(UIImage*)aDisabledImage;

- (void)showTab:(OFTabBarItem*)tabItem;
- (void)showTab:(OFTabBarItem*)tabItem showAtRoot:(BOOL)showAtRoot;
- (void)showTab:(OFTabBarItem*)tabItem notifyDelegate:(BOOL)notifyDelegate;
- (void)showTab:(OFTabBarItem*)tabItem showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate;

- (void)showTabAtIndex:(int)index;
- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot;
- (void)showTabAtIndex:(int)index notifyDelegate:(BOOL)notifyDelegate;
- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate;

- (void)showTabNamed:(NSString*)tabName;
- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot;
- (void)showTabNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate;
- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate;

- (void)showTabViewControllerNamed:(NSString*)tabName;
- (void)showTabViewControllerNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot;
- (void)showTabViewControllerNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate;
- (void)showTabViewControllerNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate;

- (void)setBackgroundImage:(UIImage*)aBackgroundImage;
- (UIImage*)backgroundImage;

- (void)enableAllTabs;

- (void)disableTab:(OFTabBarItem*)tabItem;
- (void)disableTabAtIndex:(int)index;
- (void)disableTabNamed:(NSString*)tabName;
- (void)disableTabViewControllerNamed:(NSString*)tabName;

- (void)disableTab:(OFTabBarItem*)tabItem notifyDelegate:(BOOL)notifyDelegate;
- (void)disableTabAtIndex:(int)index notifyDelegate:(BOOL)notifyDelegate;
- (void)disableTabNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate;
- (void)disableTabViewControllerNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate;

- (IBAction)hideTabBar;
- (IBAction)showTabBar;

- (void)updateZOrder;

- (void)updateBadges;
- (void)setBadgeValue:(NSInteger)value forItemNamed:(NSString*)name;

- (void)unloadAllInactiveTabs;
- (void)forceUnloadAllTabs;
- (void)unloadTabBarItemNamed:(NSString*)tabName;

- (UIViewController*)_loadTabItemViewController:(NSString*)viewControllerName forTab:(OFTabBarItem*)tabBarItem;

@end
