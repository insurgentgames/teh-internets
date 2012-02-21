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
#import "OFTabBar.h"
#import "OFTabBarItem.h"
#import "OFControllerLoader.h"
#import "OpenFeint.h"
#import "OFBadgeView.h"

@implementation OFTabBar

@synthesize items;
@synthesize style, activeTextColor, activeShadowColor, inactiveTextColor, inactiveShadowColor, badgeOffset, placeBadgeTopRight, dividerImage, activeItemBackgroundImage, inactiveItemBackgroundImage, hitOverlayImage, disabledTextColor, disabledShadowColor, disabledItemBackgroundImage;
@synthesize disabledOverlayIconImage;
@synthesize leftPadding, rightPadding, overlap, labelPadding, pulse, textAlignment;
@synthesize delegate, selectedTab, changeZOrderOnTap;
@dynamic selectedViewController;

- (void)_commonInit
{
	items = [[NSMutableArray alloc] init];
	
	self.style = OFTabBarStyleTraditional;
	
	self.changeZOrderOnTap = true;
	
	self.leftPadding = 0;
	self.rightPadding = 0;
	self.overlap = 0;
	self.labelPadding = CGRectZero;
	self.pulse = NO;
	self.textAlignment = UITextAlignmentCenter;
	self.backgroundColor = [UIColor clearColor];
	
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	
	backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	backgroundImageView.contentMode = UIViewContentModeScaleToFill;
	backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	backgroundImageView.backgroundColor = [UIColor clearColor];
	backgroundImageView.opaque = NO;
	[self addSubview:backgroundImageView];
	
	self.inactiveTextColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	self.activeTextColor   = [UIColor whiteColor];
	self.disabledTextColor = [UIColor colorWithWhite:0.25 alpha:1.0];
	self.badgeOffset       = CGPointMake(20, -15);
	placeBadgeTopRight = YES;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self _commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder*)aCoder
{
	self = [super initWithCoder:aCoder];
	if (self != nil)
	{
		[self _commonInit];
	}
	
	return self;
}

- (void)layoutSubviews
{
	[items makeObjectsPerformSelector:@selector(setNeedsLayout)];
	[[[items objectAtIndex:0] borderImageView] setHidden:YES];
}


- (void)setBackgroundImage:(UIImage*)aBackgroundImage
{
	backgroundImageView.image = aBackgroundImage;
}

- (UIImage*)backgroundImage
{
	return backgroundImageView.image;
}


- (void)addViewController:(NSString*)aViewController
                    named:(NSString*)aName
              activeImage:(UIImage*)anActiveImage
            inactiveImage:(UIImage*)anInactiveImage
            disabledImage:(UIImage*)aDisabledImage
{
	[self addViewController:aViewController 
   ofDisabledViewController:nil 
					  named:aName 
				activeImage:anActiveImage 
			  inactiveImage:anInactiveImage 
			  disabledImage:aDisabledImage];
}

- (void)addViewController:(NSString*)aViewController
 ofDisabledViewController:(NSString*)ofDisabledViewController
					named:(NSString*)aName
			  activeImage:(UIImage*)anActiveImage
			inactiveImage:(UIImage*)anInactiveImage
			disabledImage:(UIImage*)aDisabledImage
{
	OFTabBarItem* item = [[OFTabBarItem alloc] initWithParent:self
											   viewController:aViewController
														named:aName
												  activeImage:anActiveImage
												inactiveImage:anInactiveImage
												disabledImage:(UIImage*)aDisabledImage];
	item.openFeintDisabledViewControllerName = ofDisabledViewController;
	[items addObject:item];
	[self insertSubview:item aboveSubview:backgroundImageView];
	[item release];
	
	[self setNeedsLayout];
}

- (void)addSegmentNamed:(NSString*)aName
						activeImage:(UIImage*)anActiveImage
					inactiveImage:(UIImage*)anInactiveImage
                    disabledImage:(UIImage*)aDisabledImage
{
	OFTabBarItem* item = [[OFTabBarItem alloc] initWithParent:self
											   viewController:nil
												        named:aName
												  activeImage:anActiveImage
												inactiveImage:anInactiveImage
	                                            disabledImage:(UIImage*)aDisabledImage];
	[items addObject:item];
	[self insertSubview:item aboveSubview:backgroundImageView];
	[item release];
}

- (void)showTab:(OFTabBarItem*)tabItem
{
	[self showTab:tabItem notifyDelegate:YES];
}

- (void)showTab:(OFTabBarItem*)tabItem showAtRoot:(BOOL)showAtRoot
{
	[self showTab:tabItem showAtRoot:showAtRoot notifyDelegate:YES];
}

- (void)showTab:(OFTabBarItem*)tabItem notifyDelegate:(BOOL)notifyDelegate
{
	[self showTab:tabItem showAtRoot:NO notifyDelegate:notifyDelegate];
}

- (void)showTab:(OFTabBarItem*)tabItem showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if (item == tabItem)
		{
			BOOL isLoadingTab = (item.viewController == nil);
			BOOL tappedActiveTab = (item == selectedTab);
			selectedTab = item;
			selectedTab.active = YES;
			
			if (selectedTab.viewControllerName)
			{				
				if ([self.delegate respondsToSelector:@selector(tabBar:didLoadViewController:fromTab:)])
				{
					if (selectedTab.viewController != nil && isLoadingTab)
					{
						[self.delegate tabBar:self didLoadViewController:selectedTab.viewController fromTab:selectedTab];
					}
				}
				
				if ([self.delegate respondsToSelector:@selector(tabBar:didSelectViewController:)])
				{
					[self.delegate tabBar:self didSelectViewController:self.selectedViewController];
				}
				
				if ((!isLoadingTab && selectedTab.viewController && tappedActiveTab) || showAtRoot )
				{
					if ([selectedTab.viewController isKindOfClass:[UINavigationController class]])
					{
						[(UINavigationController*)selectedTab.viewController popToRootViewControllerAnimated:YES];
					}
				}
			}
			
			if (notifyDelegate)
			{
				if ([self.delegate respondsToSelector:@selector(tabBar:didSelectTabItem:)])
					[self.delegate tabBar:self didSelectTabItem:selectedTab];
				
				if ([self.delegate respondsToSelector:@selector(tabBar:didSelectTabNamed:)])
					[self.delegate tabBar:self didSelectTabNamed:selectedTab.name];
				
				if ([self.delegate respondsToSelector:@selector(tabBar:didSelectTabAtIndex:)])
					[self.delegate tabBar:self didSelectTabAtIndex:[items indexOfObject:selectedTab]];
			}
		}
		else
		{
			item.active = NO;
		}
	}
	
	[self updateZOrder];
}

- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot
{
	[self showTabAtIndex:index showAtRoot:showAtRoot notifyDelegate:YES];
}

- (void)showTabAtIndex:(int)index
{
	[self showTabAtIndex:index notifyDelegate:YES];
}

- (void)showTabAtIndex:(int)index notifyDelegate:(BOOL)notifyDelegate
{
	[self showTabAtIndex:index showAtRoot:NO notifyDelegate:notifyDelegate];
}

- (void)showTabAtIndex:(int)index showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate
{
	[self showTab:[items objectAtIndex:index] showAtRoot:showAtRoot notifyDelegate:notifyDelegate];
}

- (void)showTabNamed:(NSString*)tabName
{
	[self showTabNamed:tabName notifyDelegate:YES];
}

- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot
{
	[self showTabNamed:tabName showAtRoot:showAtRoot notifyDelegate:YES];
}

- (void)showTabNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate
{
	[self showTabNamed:tabName showAtRoot:NO notifyDelegate:notifyDelegate];
}

- (void)showTabNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if ([item.name isEqualToString:tabName])
			[self showTab:item showAtRoot:showAtRoot notifyDelegate:notifyDelegate];
	}
}

- (void)showTabViewControllerNamed:(NSString*)tabName
{
	[self showTabViewControllerNamed:tabName notifyDelegate:YES];
}

- (void)showTabViewControllerNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot
{
	[self showTabViewControllerNamed:tabName showAtRoot:showAtRoot notifyDelegate:YES];
}

- (void)showTabViewControllerNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate
{
	[self showTabViewControllerNamed:tabName showAtRoot:NO notifyDelegate:notifyDelegate];
}

- (void)showTabViewControllerNamed:(NSString*)tabName showAtRoot:(BOOL)showAtRoot notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if ([item.viewControllerName isEqualToString:tabName])
			[self showTab:item showAtRoot:showAtRoot notifyDelegate:notifyDelegate];
	}
}

- (void)enableAllTabs
{
	for (OFTabBarItem* item in items)
	{
		item.disabled = NO;
	}
	
	[self updateZOrder];
}

- (void)disableTab:(OFTabBarItem*)tabItem notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if (item == tabItem)
		{
			selectedTab = item;
			selectedTab.disabled = YES;
			
			if (notifyDelegate)
			{
				if ([self.delegate respondsToSelector:@selector(tabBar:didDisableTabItem:)])
					[self.delegate tabBar:self didDisableTabItem:selectedTab];
				
				if ([self.delegate respondsToSelector:@selector(tabBar:didDisableTabNamed:)])
					[self.delegate tabBar:self didDisableTabNamed:selectedTab.name];
				
				if ([self.delegate respondsToSelector:@selector(tabBar:didDisableTabAtIndex:)])
					[self.delegate tabBar:self didDisableTabAtIndex:[items indexOfObject:selectedTab]];
			}
		}
	}
	
	[self updateZOrder];
}

- (void) disableTabAtIndex:(int)index notifyDelegate:(BOOL)notifyDelegate
{
	[self disableTab:[items objectAtIndex:index] notifyDelegate:notifyDelegate];
}

- (void) disableTabViewControllerNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if ([item.viewControllerName isEqualToString:tabName])
			[self disableTab:item notifyDelegate:notifyDelegate];
	}
}

- (void) disableTabViewControllerNamed:(NSString*)tabName
{
	[self disableTabViewControllerNamed:tabName notifyDelegate:YES];
}

- (void) disableTabNamed:(NSString*)tabName notifyDelegate:(BOOL)notifyDelegate
{
	for (OFTabBarItem* item in items)
	{
		if ([item.name isEqualToString:tabName])
			[self disableTab:item notifyDelegate:notifyDelegate];
	}
}

- (void) disableTab:(OFTabBarItem*)tabItem
{
	[self disableTab:tabItem notifyDelegate:YES];
}

- (void) disableTabAtIndex:(int)index
{
	[self disableTabAtIndex:index notifyDelegate:YES];
}

- (void) disableTabNamed:(NSString*)tabName
{
	[self disableTabNamed:tabName notifyDelegate:YES];
}

- (void)updateZOrder
{
	if(!changeZOrderOnTap)
	{
		return;
	}
	
	for (OFTabBarItem* item in items)
	{
		if ([items indexOfObject:item] < [items indexOfObject:selectedTab])
			[self bringSubviewToFront:item];
		else
			[self sendSubviewToBack:item];
	}
	
	if (selectedTab)
		[self bringSubviewToFront:selectedTab];
	
	[self sendSubviewToBack:backgroundImageView];
}

- (IBAction)hideTabBar
{
	if (!self.hidden)
	{
		[UIView beginAnimations:@"hideOFTabBar" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDelegate:self];
		self.transform = CGAffineTransformTranslate(self.transform, 0, self.frame.size.height);
		selectedTab.viewController.view.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
		[UIView commitAnimations];
	}
}

- (IBAction)showTabBar
{
	if (self.hidden)
	{
		self.hidden = NO;
		[UIView beginAnimations:@"showOFTabBar" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		self.transform = CGAffineTransformTranslate(self.transform, 0, -self.frame.size.height);
		selectedTab.viewController.view.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height - self.frame.size.height);
		[UIView commitAnimations];
	}
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	self.hidden = [animationID isEqualToString:@"hideOFTabBar"];
}

- (void)updateBadges
{
	[items makeObjectsPerformSelector:@selector(updateBadge)];
}

- (void)setBadgeValue:(NSInteger)value forItemNamed:(NSString*)name;
{
	for (OFTabBarItem* item in items)
	{
		if ([item.name isEqualToString:name])
		{
			[item.badgeView setValue:value];
			break;
		}
	}
}

- (void)unloadTabBarItem:(OFTabBarItem*)item
{
	if ([item.viewController isKindOfClass:[UINavigationController class]])
	{
		[(UINavigationController*)item.viewController popToRootViewControllerAnimated:NO];
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:willUnloadViewController:fromTab:)])
	{
		[self.delegate tabBar:self willUnloadViewController:item.viewController fromTab:item];
	}
	
	item.viewController = nil;
}

- (void)unloadTabBarItemNamed:(NSString*)tabName
{
	for (OFTabBarItem* item in items)
	{
		if (item.viewController && [item.viewControllerName isEqualToString:tabName])
		{
			if (item == selectedTab)
			{
				// @HACK: show a different item =)
				BOOL success = NO;
				for (OFTabBarItem* anotherItem in items)
				{
					if (anotherItem != item)
					{
						[self showTab:anotherItem];
						success = YES;
						break;
					}
				}
				if (success)
				{
					[self unloadTabBarItem:item];
					[self showTab:item];
				}
				else
				{
					NSLog(@"Couldn't unload OFTabBarItem %@ because it's the only one!", item.viewControllerName);
				}
			}
			else
			{
				[self unloadTabBarItem:item];
			}
		}
	}	
}

- (void)unloadAllInactiveTabs
{
	for (OFTabBarItem* item in items)
	{
		if (item != selectedTab && item.viewControllerName != nil && item.viewController)
		{
			[self unloadTabBarItem:item];
		}			
	}
}

- (void)forceUnloadAllTabs
{
	for (OFTabBarItem* item in items)
	{
		if (item.viewControllerName != nil && item.viewController)
		{
			[self unloadTabBarItem:item];
		}			
	}
}

- (UIViewController*)_loadTabItemViewController:(NSString*)viewControllerName forTab:(OFTabBarItem*)tabBarItem
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(tabBar:loadViewController:forTab:)])
	{
		return [self.delegate tabBar:self loadViewController:viewControllerName forTab:tabBarItem];
	}
	else
	{
		return OFControllerLoader::load(viewControllerName);
	}
}

- (void)dealloc
{
	for (OFTabBarItem* item in items)
		[item setActive:NO];
		
	[backgroundImageView release];
	[items release];
	
	self.activeTextColor = nil;
	self.inactiveTextColor = nil;
	self.disabledTextColor = nil;
	self.dividerImage = nil;
	self.activeItemBackgroundImage = nil;
	self.inactiveItemBackgroundImage = nil;
	self.disabledItemBackgroundImage = nil;
	self.hitOverlayImage = nil;
	self.disabledOverlayIconImage = nil;
	
	[super dealloc];
}

- (UIViewController*)selectedViewController
{
	return selectedTab.viewController;
}

@end
