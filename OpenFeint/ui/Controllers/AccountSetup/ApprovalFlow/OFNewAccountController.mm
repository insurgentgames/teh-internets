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

#include "OFNewAccountController.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OFViewDataMap.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+EditingSupport.h"
#import "OFFormControllerHelper+Submit.h"
#import "OFAccountLoginController.h"
#import "OFExistingAccountController.h"
#import "OFLinkSocialNetworksController.h"
#import "OFNavigationController.h"
#import "OpenFeint+Settings.h"

@interface OFNewAccountController ()
- (void)continueFlow;
- (void)dismiss;
- (void)popBackToMe;
- (void)_showNameLoadingView;
@end

@implementation OFNewAccountController

@synthesize contentView,
            appNameLabel,
            nameEntryField,
            profileImageView,
			acceptNameButton,
			useDefaultNameButton,
			alreadyHaveAccountButton,
			hideNavigationBar, 
			allowNavigatingBack,
			closeDashboardOnCompletion;

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Creating New Account";
    
    UIButton *haveAccountButton = (UIButton*)OFViewHelper::findViewByTag(self.view, 1);
    UIImage *haveAccountButtonBackground = [[haveAccountButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    [haveAccountButton setBackgroundImage:haveAccountButtonBackground forState:UIControlStateNormal];
    
    appNameLabel.text = [NSString stringWithFormat:@"Now Playing %@", [OpenFeint applicationDisplayName]];
    [profileImageView useLocalPlayerProfilePictureDefault];
    
	if (hideNavigationBar)
	{
		self.navigationItem.hidesBackButton = YES;
	}

	[self hideNameLoadingView];
	
	[useDefaultNameButton setTitle:[NSString stringWithFormat:@"Use %@", [OpenFeint lastLoggedInUserName]] forState:UIControlStateNormal];
	[nameEntryField setText:[OpenFeint lastLoggedInUserName]];
	[nameEntryField setPlaceholder:[OpenFeint lastLoggedInUserName]];

	self.navigationItem.hidesBackButton = !allowNavigatingBack;
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (hideNavigationBar)
	{
		[OFExistingAccountController customAnimateNavigationController:[self navigationController] animateIn:NO];
	}
	
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if (hideNavigationBar)
	{
		[OFExistingAccountController customAnimateNavigationController:[self navigationController] animateIn:YES];
	}
	
	//[OpenFeint startLocationManagerIfAllowed];
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
//	[OFNavigationController addCloseButtonToViewController:self target:self action:@selector(cancelled)];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc
{
	OFSafeRelease(desiredName);
	OFSafeRelease(loadingView);
    
    self.contentView = nil;
    self.appNameLabel = nil;
    self.profileImageView = nil;
	self.nameEntryField = nil;
	self.acceptNameButton = nil;
	self.useDefaultNameButton = nil;
	self.alreadyHaveAccountButton = nil;
	[super dealloc];
}

- (void)popBackToMe
{
	[[self navigationController] popToViewController:self animated:YES];
}

- (void)continueFlow
{
	if (closeDashboardOnCompletion)
	{
		if ([OpenFeint hasBootstrapCompleted])
        {
			OFLinkSocialNetworksController* controller = (OFLinkSocialNetworksController*)OFControllerLoader::load(@"LinkSocialNetworks");
			[controller setCompleteDelegate:mOnCompletionDelegate];
			[[self navigationController] pushViewController:controller animated:YES];
		}
	}
	else
	{
		[self dismiss];
	}
}

- (void)cancelled
{
	if (mOnCancelDelegate.isValid())
	{
		mOnCancelDelegate.invoke();
	}
}

- (void)dismiss
{
	if (!hasBeenDismissed)
	{
		[OpenFeint allowErrorScreens:YES];
		if (closeDashboardOnCompletion)
		{
			[OpenFeint dismissRootControllerOrItsModal];
		}

		hasBeenDismissed = YES;		
		
		mOnCompletionDelegate.invoke();
	}
}

- (void)_showNameLoadingView
{
	[self showNameLoadingView:@"Submitting name..."];
}

- (void)showNameLoadingView:(NSString *)submittingText
{
	CGSize nameEntrySize = nameEntryField.frame.size;

	loadingView = [[UIView alloc] initWithFrame:nameEntryField.frame];
	loadingView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
	loadingView.opaque = NO;
	
	UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	[indicator startAnimating];

	UILabel* submitting = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, nameEntrySize.width, nameEntrySize.height)] autorelease];

	CGSize textSize = [submittingText sizeWithFont:submitting.font];

	submitting.backgroundColor = [UIColor clearColor];
	submitting.textColor = [UIColor whiteColor];
	submitting.text = submittingText;

	float const kSpaceBetweenIndicatorAndText = 4.f;
	float totalWidth = indicator.frame.size.width + textSize.width + kSpaceBetweenIndicatorAndText;
	float indicatorX = (nameEntrySize.width - totalWidth) * 0.5f;
	float indicatorY = (nameEntrySize.height - indicator.frame.size.height) * 0.5f;	
	float textX = indicatorX + indicator.frame.size.width + kSpaceBetweenIndicatorAndText;

	[indicator setFrame:CGRectMake(indicatorX, indicatorY, indicator.frame.size.width, indicator.frame.size.height)];
	[submitting setFrame:CGRectMake(textX, 0.0f, nameEntrySize.width, nameEntrySize.height)];
	
	[loadingView addSubview:indicator];
	[loadingView addSubview:submitting];
	[nameEntryField.superview addSubview:loadingView];
}

- (void)hideNameLoadingView
{
	[loadingView removeFromSuperview];
	OFSafeRelease(loadingView);
}

- (IBAction)onSubmitForm:(UIView*)sender
{
	OFSafeRelease(desiredName);
    if ([nameEntryField.text isEqualToString:@""]) nameEntryField.text = nameEntryField.placeholder;
	desiredName = [nameEntryField.text retain];
	
	[self hideNameLoadingView];

	if (![desiredName isEqualToString:[OpenFeint lastLoggedInUserName]])
	{
		acceptNameButton.enabled = NO;
		alreadyHaveAccountButton.enabled = NO;
		
		[self _showNameLoadingView];
		[super onSubmitForm:sender];
	}
	else
	{
		[self continueFlow];
	}
}

- (IBAction)_useDefaultName
{
	[self continueFlow];
}

- (IBAction)_alreadyCreatedAccount
{
	OFAccountLoginController* accountFlowController = (OFAccountLoginController*)OFControllerLoader::load(@"OpenFeintAccountLogin");
	[accountFlowController setCancelDelegate:OFDelegate(self, @selector(popBackToMe))];
	[accountFlowController setCompletionDelegate:OFDelegate(self, @selector(dismiss))];
	[[self navigationController] pushViewController:accountFlowController animated:YES];
}

// OFFormControllerHelper overrides
- (void)registerActionsNow
{
}

- (NSString*)getFormSubmissionUrl
{
	return @"users/update_name.xml";
}

- (void)onFormSubmitted
{
	[self hideNameLoadingView];

	[OpenFeint loggedInUserChangedNameTo:desiredName];
	nameEntryField.text = desiredName;
	OFSafeRelease(desiredName);
	
	[self continueFlow];
}

- (NSString*)singularResourceName
{
	return @"user";
}

- (NSString*)getHTTPMethod
{
	return @"POST";
}

// Optional OFFormControllerHelper overrides
- (void)onPresentingErrorDialog
{
	[self hideNameLoadingView];	
	acceptNameButton.enabled = YES;
	alreadyHaveAccountButton.enabled = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[super textFieldDidBeginEditing:textField];
	[acceptNameButton setTitle:@"Submit" forState:UIControlStateNormal];
	useDefaultNameButton.hidden = NO;
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"name", nameEntryField.tag);	
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	parameterStream->io("id", @"me");
}

- (bool)shouldShowLoadingScreenWhileSubmitting
{
	return false;
}

- (bool)shouldDismissKeyboardWhenSubmitting
{
	return true;
}

- (void)setCompleteDelegate:(OFDelegate&)completeDelegate
{
	mOnCompletionDelegate = completeDelegate;
}

- (void)setCancelDelegate:(OFDelegate&)cancelDelegate
{
	mOnCancelDelegate = cancelDelegate;
}

- (void)hideIntroFlowViews
{
    UIView *contentFrame = OFViewHelper::findViewByTag(self.view, 101);
    contentFrame.hidden = YES;
    
    for (UIView *subview in [contentView subviews])
    {
        CGRect viewFrame = subview.frame;
        viewFrame.origin = CGPointMake(viewFrame.origin.x, viewFrame.origin.y - 41);
        subview.frame = viewFrame;
    } 
    
    self.view = contentView;
}

@end