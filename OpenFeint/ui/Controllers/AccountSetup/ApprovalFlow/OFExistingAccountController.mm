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

#include "OFExistingAccountController.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"
#import "OFControllerLoader.h"
#import "OFAccountLoginController.h"
#import "OFDeadEndErrorController.h"
#import "OFLinkSocialNetworksController.h"
#import "OFUser.h"
#import "OFViewHelper.h"

@interface OFExistingAccountController ()
- (void)popBackToMe;
- (void)dismiss;
- (void)onBootstrapFailure;
- (void)continueFlow;
@end

@implementation OFExistingAccountController

@synthesize appNameLabel,
            usernameLabel,
			scoreLabel,
            profileImageView,
			selectUserWidget,
			editButton;
			// closeDashboardOnCompletion; // DIAG_GetTheMost


- (void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.hidesBackButton = YES;
    
    UIButton *button = (UIButton*)OFViewHelper::findViewByTag(self.view, 1);
    UIImage *buttonBg = [[button backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    [button setBackgroundImage:buttonBg forState:UIControlStateNormal];
    
    appNameLabel.text = [NSString stringWithFormat:@"Now Playing %@", [OpenFeint applicationDisplayName]];
    
	if (self.selectUserWidget == nil)
	{
		usernameLabel.text = [OpenFeint lastLoggedInUserName];
		scoreLabel.text = [NSString stringWithFormat:@"%d", [OpenFeint localUser].gamerScore];
        [profileImageView useLocalPlayerProfilePictureDefault];
        profileImageView.imageUrl = [OpenFeint lastLoggedInUserProfilePictureUrl];
	}

	[super viewWillAppear:animated];
}

+ (void)customAnimateNavigationController:(UINavigationController*)navController animateIn:(BOOL)animatingIn
{
	if (animatingIn)
	{
		[navController setNavigationBarHidden:NO animated:NO];
	}
	else
	{
		[navController setNavigationBarHidden:YES animated:NO];
	}
	
	CGRect navBarFrame = navController.navigationBar.frame;
	navBarFrame.origin.y = animatingIn ? -navBarFrame.size.height : 0.f;
	navController.navigationBar.frame = navBarFrame;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	navBarFrame.origin.y = animatingIn ? 0.f : -navBarFrame.size.height;
	navController.navigationBar.frame = navBarFrame;
	[UIView commitAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
	[OFExistingAccountController customAnimateNavigationController:[self navigationController] animateIn:NO];
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[OFExistingAccountController customAnimateNavigationController:[self navigationController] animateIn:YES];
	//[OpenFeint startLocationManagerIfAllowed];
	[super viewDidDisappear:animated];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc
{
    self.appNameLabel = nil;
	self.usernameLabel = nil;
	self.scoreLabel = nil;
	self.selectUserWidget = nil;
	self.editButton = nil;
	[super dealloc];
}

- (void)popBackToMe
{
	[[self navigationController] popToViewController:self animated:YES];
}

- (void)dismiss
{
	if (!hasBeenDismissed)
	{
		[OpenFeint allowErrorScreens:YES];
		[OpenFeint dismissRootControllerOrItsModal];

		hasBeenDismissed = YES;		
		
		mOnCompletionDelegate.invoke();
	}
}


- (void)onBootstrapFailure
{
	OFDeadEndErrorController* errorScreen = (OFDeadEndErrorController*)OFControllerLoader::load(@"DeadEndError");

	[self hideLoadingScreen];
	errorScreen.message = @"OpenFeint was unable to log you in at this time.  Some features will be unavailable until the next time you are online.";
	[[self navigationController] pushViewController:errorScreen animated:YES];
}


- (void)continueFlow
{
	[self hideLoadingScreen];

	if( [OpenFeint hasBootstrapCompleted] ){
		OFLinkSocialNetworksController* controller = (OFLinkSocialNetworksController*)OFControllerLoader::load(@"LinkSocialNetworks");
		[controller setCompleteDelegate:mOnCompletionDelegate];
		[[self navigationController] pushViewController:controller animated:YES];
	}else{
		// Would like to be sure this case cannot happen any more and replace with assert hasBootstrapCompleted.		
		[self dismiss];
	}
}


- (IBAction)_ok
{
	[self continueFlow];
}


- (IBAction)_thisIsntMe
{
	OFAccountLoginController* accountFlowController = (OFAccountLoginController*)OFControllerLoader::load(@"OpenFeintAccountLogin");
	[accountFlowController setCancelDelegate:OFDelegate(self, @selector(popBackToMe))];
	[accountFlowController setCompletionDelegate:OFDelegate(self, @selector(continueFlow))];	
	[[self navigationController] pushViewController:accountFlowController animated:YES];
}

- (IBAction)_edit
{
	if ([[editButton currentTitle] isEqualToString:@"Edit"])
	{
		[editButton setTitle:@"Done" forState:UIControlStateNormal];
		[editButton setTitle:@"Done" forState:UIControlStateHighlighted];		
		[selectUserWidget setEditing:YES];
	}
	else
	{
		[editButton setTitle:@"Edit" forState:UIControlStateNormal];
		[editButton setTitle:@"Edit" forState:UIControlStateHighlighted];		
		[selectUserWidget setEditing:NO];
	}		
}

- (void)setCompleteDelegate:(OFDelegate&)completeDelegate
{
	mOnCompletionDelegate = completeDelegate;
}

- (void)selectUserWidget:(OFSelectUserWidget*)widget didSelectUser:(OFUser*)user
{
	[OpenFeint setLocalUser:user];
	[OpenFeint doBootstrap:NO userId:user.resourceId
		onSuccess:OFDelegate(self, @selector(continueFlow))
		onFailure:OFDelegate(self, @selector(onBootstrapFailure)) ];
	[self showLoadingScreen];
	
	
#if 1 // DIAG_GetTheMost
//	[self continueFlow];
#else
	[self dismiss];
#endif
}

@end