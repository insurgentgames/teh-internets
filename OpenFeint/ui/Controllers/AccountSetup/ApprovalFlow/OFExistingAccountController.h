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

#import "OFCallbackable.h"
#import "OFViewController.h"
#import "OFSelectUserWidget.h"
#import "OFImageView.h"

@interface OFExistingAccountController : OFViewController< OFCallbackable, OFSelectUserWidgetDelegate >
{
@private
	BOOL hasBeenDismissed;
    
    UILabel *appNameLabel;
	UILabel* usernameLabel;
    UILabel* scoreLabel;
    OFImageView* profileImageView;
	OFSelectUserWidget* selectUserWidget;
	UIButton* editButton;
	
	OFDelegate mOnCompletionDelegate;
	//BOOL closeDashboardOnCompletion; // DIAG_GetTheMost
}

@property (nonatomic, retain) IBOutlet UILabel* appNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel* scoreLabel;
@property (nonatomic, retain) IBOutlet OFImageView* profileImageView;
@property (nonatomic, retain) IBOutlet OFSelectUserWidget* selectUserWidget;
@property (nonatomic, retain) IBOutlet UIButton* editButton;
//@property (nonatomic, assign) BOOL closeDashboardOnCompletion; // DIAG_GetTheMost


+ (void)customAnimateNavigationController:(UINavigationController*)navController animateIn:(BOOL)animatingIn;

- (IBAction)_ok;
- (IBAction)_thisIsntMe;
- (IBAction)_edit;
- (void)setCompleteDelegate:(OFDelegate&)completeDelegate;

@end