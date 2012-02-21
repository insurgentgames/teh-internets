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
#import "OFAccountSetupBaseController.h"
#import "OFShowMessageAndReturnController.h"
#import "OFFormControllerHelper+Submit.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFProvider.h"
#import "OFISerializer.h"
#import "OFControllerLoader.h"
#import "OFNavigationController.h"

@implementation OFAccountSetupBaseController

@synthesize privacyDisclosure;
@synthesize addingAdditionalCredential = mAddingAdditionalCredential;

+ (OFShowMessageAndReturnController*)getStandardLoggedInController
{
	OFShowMessageAndReturnController* nextController =  (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
	nextController.messageLabel.text = [NSString stringWithFormat:@"You are now logged into OpenFeint as:\n %@", [OpenFeint lastLoggedInUserName]];;
	nextController.messageTitleLabel.text = @"Switch Accounts";
    nextController.navigationItem.hidesBackButton = YES;
	return nextController;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
//	[OFNavigationController addCloseButtonToViewController:self target:self action:@selector(cancelSetup)];
}

- (BOOL)isInModalController
{
	return self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController != nil;
}

- (void)cancelSetup
{
	if (mCancelDelegate.isValid())
	{
		mCancelDelegate.invoke();
	}
	else if ([self isInModalController])
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	OFRetainedPtr<NSString> udid = [UIDevice currentDevice].uniqueIdentifier;
	parameterStream->io("udid", udid);
}

- (OFShowMessageAndReturnController*)getStandardLoggedInController
{
	return [OFAccountSetupBaseController getStandardLoggedInController];
}

- (OFShowMessageAndReturnController*)controllerToPushOnCompletion
{
	return nil;
}

- (UIViewController*)getControllerToPopTo
{
	// When logging in we always pop all the way back to the root. This is to make sure you don't pop back into a chat room you're no longer part of
	if (self.addingAdditionalCredential)
	{
		for (int i = [self.navigationController.viewControllers count] - 1; i >= 1; i--)
		{
			UIViewController* curController = [self.navigationController.viewControllers objectAtIndex:i];
			if (![curController isKindOfClass:[OFAccountSetupBaseController class]])
			{
				return curController;
			}
		}
	}
	return nil;
}

- (void)popOutOfAccountFlow
{
	if ([self isInModalController])
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		UIViewController* controllerToPopTo = [self getControllerToPopTo];
		if (controllerToPopTo)
		{
			[self.navigationController popToViewController:controllerToPopTo animated:YES];
		}
		else
		{
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
}

- (void)pushCompletionControllerOrPopOut
{
	if (mCompletionDelegate.isValid())
	{
		mCompletionDelegate.invoke();
	}
	else
	{
		OFShowMessageAndReturnController* controllerToPush = [self controllerToPushOnCompletion];
		if (controllerToPush)
		{
			controllerToPush.navigationItem.hidesBackButton = YES;
			controllerToPush.controllerToPopTo = [self getControllerToPopTo];
			[self.navigationController pushViewController:controllerToPush animated:YES];
		}
		else
		{
			[self popOutOfAccountFlow];
		
		}
	}
}

- (void)onFormSubmitted
{
	if (self.addingAdditionalCredential)
	{
		[OpenFeint setLoggedInUserHasNonDeviceCredential:YES];
		[self pushCompletionControllerOrPopOut];
	}
	else
	{
		[self showLoadingScreen];
		[[OpenFeint provider] destroyLocalCredentials];
		[OpenFeint doBootstrap:OFDelegate(self, @selector(onBootstrapDone)) onFailure:OFDelegate(self, @selector(onBootstrapDone))];
	}	
}

- (void)onBootstrapDone
{
	[self hideLoadingScreen];
	[OpenFeint reloadInactiveTabBars];
	[self pushCompletionControllerOrPopOut];
}

- (void)dealloc
{
	self.privacyDisclosure = nil;
	[super dealloc];
}

- (void)setCancelDelegate:(OFDelegate const&)delegate
{
	mCancelDelegate = delegate;
}

- (void)setCompletionDelegate:(OFDelegate const&)delegate
{
	mCompletionDelegate = delegate;
}

@end