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
#import "OFNavigationController.h"
#import "OFReachability.h"
#import "OpenFeint+Private.h"
#import "OFColors.h"
#import "OFViewHelper.h"
#import "IPhoneOSIntrospection.h"
#import "OFTabBar.h"
#import "OFTabBarContainer.h"
#import "OFLoadingController.h"
#import "OFCustomBottomView.h"
#import "OFPatternedGradientView.h"
#import "OFImageLoader.h"
#import "OFBadgeView.h"

const UIBarStyle OpenFeintUIBarStyle = UIBarStyleBlackOpaque;
const UIActionSheetStyle OpenFeintActionSheetStyle = UIActionSheetStyleBlackOpaque;

static const float gTabBarSlideDuration = 0.325f;

@implementation OFNavigationController

@synthesize isInHiddenTab = mInHiddenTab;

- (float)_getStatusBarOffset
{
	if(is3PointOhSystemVersion())
	{
		CGRect frame = [UIApplication sharedApplication].statusBarFrame;
		if ([OpenFeint isInLandscapeMode])
		{
			return frame.size.width;
		}
		else
		{
			return frame.size.height;
		}
	}

	return 0.f;
}

- (float)_getNavigationBarOffset
{
	if (self.navigationBarHidden)
		return 0.f;
	else
		return self.navigationBar.frame.size.height;
}

- (void)slideTabBarInController:(UIViewController*)viewController down:(BOOL)down animated:(BOOL)animated
{
	OFTabBarContainer* tabBarContainer = (OFTabBarContainer*)OFViewHelper::findSuperviewByClass(self.view, [OFTabBarContainer class]);
	OFTabBar* tabBar = nil;
	for (UIView* view in tabBarContainer.subviews)
	{
		if ([view isKindOfClass:[OFTabBar class]])
			tabBar = (OFTabBar*)view;
	}
	
	if (tabBar)
	{
		CGRect tabBarFrame = tabBar.frame;
		float internalViewHeight = 0.0f;

		if (animated)
		{
			[UIView beginAnimations:@"tabBarSlide" context:nil];
			[UIView setAnimationDuration:gTabBarSlideDuration];
		}

		for (UIView* view in tabBarContainer.subviews)
		{
			CGRect viewFrame = view.frame;

			if ([view isKindOfClass:[OFTabBar class]])
			{
				CGFloat dist = tabBarFrame.size.height + [OFBadgeView minimumSize].height;
				viewFrame.origin.y += down ? dist : -dist;
			}
			else
			{
				viewFrame.size.height += down ? tabBarFrame.size.height : -tabBarFrame.size.height;
				internalViewHeight = viewFrame.size.height;
			}

			[view setFrame:viewFrame];
		}

		CGRect frame = viewController.view.frame;
		frame.size.height = internalViewHeight - [self _getNavigationBarOffset] - [self _getStatusBarOffset];
		[viewController.view setFrame:frame];
		
		if (animated)
		{
			[UIView commitAnimations];
		}
	}
}

- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated
{
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	return [super popViewControllerAnimated:animated];
}

- (void)addBackgroundAndOverlay
{
	CGRect bgFrame = CGRectMake(0.f, 0.f, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
	UIImage* bgImage = [[OFImageLoader loadImage:@"OFNavBar.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
	
	mNavBarBackgroundView = [[UIImageView alloc] initWithImage:bgImage];
	mNavBarBackgroundView.frame = bgFrame;
	mNavBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mNavBarBackgroundView.userInteractionEnabled = NO;
	
	[self.navigationBar addSubview:mNavBarBackgroundView];
	[self.navigationBar sendSubviewToBack:mNavBarBackgroundView];
	
	mBackgroundView = [[OFPatternedGradientView defaultView:self.view.frame] retain];
	[self.view addSubview:mBackgroundView];
	[self.view sendSubviewToBack:mBackgroundView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.delegate = self;
	self.navigationBar.barStyle = OpenFeintUIBarStyle;
	self.navigationBar.tintColor = OFColors::navBarColor;
	
	[self addBackgroundAndOverlay];
}

- (void)addTitleLabelToViewController:(UIViewController*)viewController
{
	UILabel* titleLabel = [[[UILabel alloc] init] autorelease];
	titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
	titleLabel.text = viewController.title;
	titleLabel.textColor = OFColors::darkGreen;
	titleLabel.shadowColor = OFColors::brightGreen;
	titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
	const float shadowOffset = 2.f;
	titleLabel.shadowOffset = CGSizeMake(-shadowOffset, shadowOffset);
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.frame = [titleLabel textRectForBounds:CGRectMake(0.f, 0.f, 250.f, 30.f) limitedToNumberOfLines:1];
	viewController.navigationItem.titleView = titleLabel;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	// OF2.0UI
	//[self addTitleLabelToViewController:viewController];
	[self performSelector:@selector(_orderViewDepths) withObject:nil afterDelay:0.05]; 
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	mIsTabBarHidden = [viewController conformsToProtocol:@protocol(OFCustomBottomView)];

	if (mIsTabBarHidden != mWasTabBarHidden)
	{
		[self slideTabBarInController:viewController down:mIsTabBarHidden animated:animated];
	}

	mWasTabBarHidden = mIsTabBarHidden;
}

- (void)_orderViewDepths
{
	[self.navigationBar sendSubviewToBack:mNavBarBackgroundView];
	UIView* titleView = self.visibleViewController.navigationItem.titleView;
	[titleView.superview bringSubviewToFront:titleView];
}

- (void)dealloc
{
	OFSafeRelease(mNavBarBackgroundView);
	OFSafeRelease(mBackgroundView);
	[super dealloc];
}

- (void)showLoadingIndicator
{
	if(mLoadingController && mLoadingController.view.superview == self.view)
	{
		return;
	}
	else
	{
		mLoadingController = [[OFLoadingController loadingControllerWithText:@""] retain];
		
		[self.view insertSubview:mLoadingController.view belowSubview:self.navigationBar];
		[mLoadingController showLoadingScreen];
	}
}

- (void)hideLoadingIndicator
{
	[mLoadingController hide];
	OFSafeRelease(mLoadingController);	
}

+ (void)addCloseButtonToViewController:(UIViewController*)viewController target:(id)target action:(SEL)action
{
	[OFNavigationController addCloseButtonToViewController:viewController target:target action:action leftSide:NO systemItem:UIBarButtonSystemItemCancel];
}

+ (void)addCloseButtonToViewController:(UIViewController*)viewController target:(id)target action:(SEL)action leftSide:(BOOL)leftSide systemItem:(UIBarButtonSystemItem)_style
{
	UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:_style target:target action:action];

	if (leftSide)
	{
		viewController.navigationItem.leftBarButtonItem = item;
	}
	else
	{
		viewController.navigationItem.rightBarButtonItem = item;
	}
	
	[item release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == [OpenFeint getDashboardOrientation];
}

@end