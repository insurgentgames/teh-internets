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

#include "OFDoBootstrapController.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFReachability.h"
#import "OFControllerLoader.h"
#import "OFUserService.h"
#import "OFUser.h"
#import "OFPaginatedSeries.h"
#import "OFPatternedGradientView.h"
#import "OFContentFrameView.h"

#import "OFNewAccountController.h"
#import "OFExistingAccountController.h"

@interface OFDoBootstrapController ()
- (void)dismiss;
- (void)_findUsersSucceeded:(OFPaginatedSeries*)resources;
- (void)_findUsersFailed;
- (void)_bootstrapSucceded;
- (void)_bootstrapFailed;
- (void)_showMessageAndHideLoading:(NSString*)message;
@end

@implementation OFDoBootstrapController

@synthesize titleLabel, messageLabel, activityIndicator;

- (void)_showMessageAndHideLoading:(NSString*)message
{
	activityIndicator.hidden = YES;    
    titleLabel.text = @"Error";
    messageLabel.hidden = NO;
	[messageLabel setText:message];
}

- (void)viewWillAppear:(BOOL)animated
{
	[OpenFeint allowErrorScreens:NO];

	self.navigationItem.hidesBackButton = YES;

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[[self navigationController] setNavigationBarHidden:YES animated:YES];

	if (!OFReachability::Instance()->isGameServerReachable())
	{
		[self _showMessageAndHideLoading:@"You're offline! OpenFeint needs to connect to the internet one time to look up or create your account. Please connect to the internet and restart this application to enable OpenFeint."];
	}
	else
	{
		[OFUserService findUsersForLocalDeviceOnSuccess:OFDelegate(self, @selector(_findUsersSucceeded:)) onFailure:OFDelegate(self, @selector(_findUsersFailed))];
	}
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc
{
	self.messageLabel = nil;
	self.activityIndicator = nil;
	
	[super dealloc];
}

- (void)dismiss
{
	[OpenFeint allowErrorScreens:YES];
	[OpenFeint dismissRootControllerOrItsModal];
}

- (void)_findUsersSucceeded:(OFPaginatedSeries*)resources
{
	int numUsers = [resources count];
	
	if (numUsers == 0)
	{
		[OpenFeint doBootstrap:YES onSuccess:OFDelegate(self, @selector(_bootstrapSucceded)) onFailure:OFDelegate(self, @selector(_bootstrapFailed))];
	}
	else if (numUsers == 1)
	{
		[OpenFeint doBootstrap:NO userId:[(OFUser*)[resources objectAtIndex:0] resourceId] onSuccess:OFDelegate(self, @selector(_bootstrapSucceded)) onFailure:OFDelegate(self, @selector(_bootstrapFailed))];
	}
	else
	{
		OFExistingAccountController* accountController = (OFExistingAccountController*)OFControllerLoader::load(@"ExistingAccountMultiple");
		[[accountController selectUserWidget] setHideHeader:YES];
		[[accountController selectUserWidget] setUserResources:resources];
		[accountController setCompleteDelegate:mCompleteDelegate];
		UINavigationController* navController = [self navigationController];
		[navController pushViewController:accountController animated:YES];
	}
}

- (void)_findUsersFailed
{
	[self _bootstrapFailed];
}

- (void)_bootstrapSucceded
{
	bool newAccount = [OpenFeint loggedInUserIsNewUser];
	if (newAccount)
	{
		OFNewAccountController* accountController = (OFNewAccountController*)OFControllerLoader::load(@"NewAccount");
		accountController.hideNavigationBar = YES;
		accountController.closeDashboardOnCompletion = YES;
		[accountController setCompleteDelegate:mCompleteDelegate];
		[[self navigationController] pushViewController:accountController animated:NO];
	}
	else
	{
		OFExistingAccountController* accountController = (OFExistingAccountController*)OFControllerLoader::load(@"ExistingAccount");
		[accountController setCompleteDelegate:mCompleteDelegate];
		UINavigationController* navController = [self navigationController];
		[navController pushViewController:accountController animated:NO];
	}
}

- (void)_bootstrapFailed
{
	[self _showMessageAndHideLoading:@"OpenFeint failed to initialize. Restarting this application while connected to the internet, or reinstalling it, may fix this error. E-mail help@openfeint.com if you're having trouble."];
}

- (IBAction)_skip
{
	[self dismiss];
	mCompleteDelegate.invoke();
}

- (void)setCompleteDelegate:(OFDelegate&)completeDelegate
{
	mCompleteDelegate = completeDelegate;
}

@end