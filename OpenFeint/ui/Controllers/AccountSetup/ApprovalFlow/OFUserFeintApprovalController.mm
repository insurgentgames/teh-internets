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

#import "OFUserFeintApprovalController.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+Settings.h"
#import "OFLoadingController.h"
#import "OFReachability.h"
#import "OFViewHelper.h"
#import "OFContentFrameView.h"
#import "OFPatternedGradientView.h"

@implementation OFUserFeintApprovalController

@synthesize appNameLabel;

- (void)viewDidLoad
{
    UIButton *declineButton = (UIButton*)OFViewHelper::findViewByTag(self.view, 1);
    UIImage *declineBackground = [[declineButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    [declineButton setBackgroundImage:declineBackground forState:UIControlStateNormal];
    
    appNameLabel.text = [NSString stringWithFormat:@"%@ is OpenFeint Enabled!", [OpenFeint applicationDisplayName]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[OpenFeint allowErrorScreens:NO];
	[super viewWillAppear:animated];
}

- (void)dismiss
{
	[OpenFeint allowErrorScreens:YES];
	[OpenFeint dismissRootControllerOrItsModal];
}

-(IBAction)clickedUseFeint
{
	[OpenFeint userDidApproveFeint:YES accountSetupCompleteDelegate:mApprovedDelegate];
}

-(IBAction)clickedDontUseFeint 
{
	[OpenFeint userDidApproveFeint:NO];
	[self dismiss];
	mDeniedDelegate.invoke();
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)setApprovedDelegate:(const OFDelegate&)approvedDelegate andDeniedDelegate:(const OFDelegate&)deniedDelegate
{
	mApprovedDelegate = approvedDelegate;
	mDeniedDelegate = deniedDelegate;
}

- (void)dealloc
{
    self.appNameLabel = nil;
	[super dealloc];
}

@end