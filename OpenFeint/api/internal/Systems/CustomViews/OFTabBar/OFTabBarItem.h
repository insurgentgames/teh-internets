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

#import <UIKit/UIKit.h>
#import "OFTabBar.h"

@class OFTabBar;
@class OFBadgeView;

@interface OFTabBarItem : UIView 
{
	OFTabBar *parent;
  
	UIButton* button;
	UIImageView* imageView;
	UILabel* nameLabel;
	OFBadgeView* badgeView;
	UIImageView* borderImageView;
	UIImageView* backgroundView;
	UIImageView* hitImageView;
	UIView* overlayView;
	
	BOOL active;
	BOOL disabled;
  
	NSString* viewControllerName;
	NSString* openFeintDisabledViewControllerName;
	UIViewController* viewController;
	NSString* name;
	UIImage* activeImage;
	UIImage* inactiveImage;
	UIImage* disabledImage;
}

@property (retain, nonatomic) UIButton* button;
@property (retain, nonatomic) UIImageView* imageView;
@property (retain, nonatomic) UILabel* nameLabel;
@property (retain, nonatomic) OFBadgeView* badgeView;
@property (retain, nonatomic) UIImageView* borderImageView;
@property (retain, nonatomic) UIImageView* backgroundView;
@property (retain, nonatomic) UIImageView* hitImageView;

@property (assign, nonatomic) BOOL active;

@property (retain, nonatomic) UIViewController* viewController;
@property (retain, nonatomic) NSString* viewControllerName;
@property (retain, nonatomic) NSString* openFeintDisabledViewControllerName;
@property (copy,   nonatomic) NSString* name;
@property (retain, nonatomic) UIImage* activeImage;
@property (retain, nonatomic) UIImage* inactiveImage;

@property (assign, nonatomic) BOOL disabled;
@property (retain, nonatomic) UIImage* disabledImage;

- (id)initWithParent:(OFTabBar*)aTabBarController
      viewController:(NSString*)aViewController
               named:(NSString*)aName
         activeImage:(UIImage*)anActiveImage
       inactiveImage:(UIImage*)anInactiveImage
       disabledImage:(UIImage*)aDisabledImage;

- (IBAction)didTapTabItem;
- (IBAction)didHit;
- (IBAction)didCancelHit;

- (void)animatePulse;
- (void)setBadgeValue:(NSString*)value;

@end
