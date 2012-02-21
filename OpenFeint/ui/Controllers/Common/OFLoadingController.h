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

#import <Foundation/Foundation.h>
#import "OFCallbackable.h"

@class OFPatternedGradientView;

@interface OFLoadingView : UIView
{
	UIView* contentContainer;
	UIView* backgroundView;

	UIImageView* centerImage;
	
	OFPatternedGradientView* leftView;
	OFPatternedGradientView* rightView;
	
	BOOL appearingAnimationInProgress;
	BOOL disappearingAnimationInProgress;
	BOOL disappearIsQueued;
	
	OFDelegate disappearDelegate;
}

@property (nonatomic, retain) IBOutlet UIView* contentContainer;
@property (nonatomic, retain) IBOutlet UIView* backgroundView;

@property (nonatomic, retain) IBOutlet UIImageView* centerImage;

@property (nonatomic, retain) OFPatternedGradientView* leftView;
@property (nonatomic, retain) OFPatternedGradientView* rightView;

@end

@interface OFLoadingController : UIViewController< OFCallbackable >
{
	BOOL isHiding;
}

+ (OFLoadingController*)loadingControllerWithText:(NSString*)loadingText;
- (void)setLoadingText:(NSString*)loadingText;
- (void)hide;
- (void)showLoadingScreen:(BOOL)animated;
- (void)showLoadingScreen;

@end
