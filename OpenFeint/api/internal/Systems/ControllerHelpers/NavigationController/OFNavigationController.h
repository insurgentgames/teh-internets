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

@class OFLoadingController;

@interface OFNavigationController : UINavigationController<UINavigationControllerDelegate>
{
@package
	BOOL mInHiddenTab;
	BOOL mIsTabBarHidden;
	BOOL mWasTabBarHidden;
	UIView* mNavBarBackgroundView;
	OFLoadingController* mLoadingController;
	UIView* mBackgroundView;
}

@property (nonatomic, assign) BOOL isInHiddenTab;

- (void)_orderViewDepths;
- (void)showLoadingIndicator;
- (void)hideLoadingIndicator;

+ (void)addCloseButtonToViewController:(UIViewController*)viewController target:(id)target action:(SEL)action;
+ (void)addCloseButtonToViewController:(UIViewController*)viewController target:(id)target action:(SEL)action leftSide:(BOOL)leftSide systemItem:(UIBarButtonSystemItem)_style;

@end

extern const UIBarStyle OpenFeintUIBarStyle;
extern const UIActionSheetStyle OpenFeintActionSheetStyle;