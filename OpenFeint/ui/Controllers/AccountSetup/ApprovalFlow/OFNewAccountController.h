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

#import "OFFormControllerHelper.h"
#import "OFCallbackable.h"
#import "OFDefaultButton.h"
#import "OFImageView.h"

@interface OFNewAccountController : OFFormControllerHelper< OFCallbackable >
{
@private
	BOOL hasBeenDismissed;
	NSString* desiredName;
	UIView* loadingView;
    
    UIView* contentView;
    UILabel* appNameLabel;
    UITextField* nameEntryField;
    OFImageView* profileImageView;
	OFDefaultButton* acceptNameButton;
	UIButton* useDefaultNameButton;
	UIButton* alreadyHaveAccountButton;
	OFDelegate mOnCompletionDelegate;
	OFDelegate mOnCancelDelegate;
	BOOL hideNavigationBar;
	BOOL allowNavigatingBack;
	BOOL closeDashboardOnCompletion;
}

@property (nonatomic, retain) IBOutlet UIView* contentView;
@property (nonatomic, retain) IBOutlet UILabel* appNameLabel;
@property (nonatomic, retain) IBOutlet UITextField* nameEntryField;
@property (nonatomic, retain) IBOutlet OFImageView* profileImageView;
@property (nonatomic, retain) IBOutlet OFDefaultButton* acceptNameButton;
@property (nonatomic, retain) IBOutlet UIButton* useDefaultNameButton;
@property (nonatomic, retain) IBOutlet UIButton* alreadyHaveAccountButton;
@property (nonatomic, assign) BOOL hideNavigationBar;
@property (nonatomic, assign) BOOL allowNavigatingBack;
@property (nonatomic, assign) BOOL closeDashboardOnCompletion;

- (IBAction)_useDefaultName;
- (IBAction)_alreadyCreatedAccount;
- (void)setCompleteDelegate:(OFDelegate&)completeDelegate;
- (void)setCancelDelegate:(OFDelegate&)cancelDelegate;
- (void)hideIntroFlowViews;

- (void)showNameLoadingView:(NSString *)submittingText;
- (void)hideNameLoadingView;

@end