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

#import "OFNavigationController.h"
#import "OFTabBarItem.h"
#import "OFFriendPickerController.h"
#import "OFBannerFrame.h"
#import "OFFramedContentWrapperView.h"

@class OFContentFrameView;
@class OFProfileComparisonButton;
@class OFDashboardNotificationView;
@class OFGameProfilePageInfo;

struct OFFramedNavigationControllerVisibilityFlags {
	unsigned int showBanner:1;
	unsigned int showBottomView:1;
	unsigned int showNavBar:1;
};
typedef struct OFFramedNavigationControllerVisibilityFlags OFFramedNavigationControllerVisibilityFlags;

@interface OFFramedNavigationController : OFNavigationController< OFFriendPickerDelegate, OFFramedContentWrapperViewDelegate>
{
	OFContentFrameView* frameView;
	OFBannerFrame* bannerView;
	
	OFTabBarItem* owningTabBarItem;
	
	UIView* customBottomView;
	
	// whether this controller SHOULD show its subviews (not whether they're currently being shown):
	OFFramedNavigationControllerVisibilityFlags visibilityShould;
	
	// whether this controller currently IS showing its subvies.
	OFFramedNavigationControllerVisibilityFlags visibilityDoes;

	BOOL viewControllerSpecificallyWantsTheNavBarHidden;

	BOOL isKeyboardShown;
	float keyboardHeight;
	
	NSMutableArray* controllerInfos;
}

@property (assign, nonatomic) OFTabBarItem* owningTabBarItem;
@property (readonly, nonatomic) UIView* bannerView;

- (OFGameProfilePageInfo*)currentGameContext;

- (void)changeGameContext:(OFGameProfilePageInfo*)_gameContext;

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated;
- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfUser:(OFUser*)user;
- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfLocalUserComparedTo:(OFUser*)user;

- (OFUser*)currentUser;
- (OFUser*)comparisonUser;

- (void)refreshProfile;
- (void)refreshBottomView;
- (void)refreshBanner;

- (void)adjustForKeyboard:(BOOL)_isKeyboardShown ofHeight:(float)_keyboardHeight;

- (IBAction)compareButtonPressed;

@end
