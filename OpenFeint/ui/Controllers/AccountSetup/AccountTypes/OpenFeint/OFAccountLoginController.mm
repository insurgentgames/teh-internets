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
#import "OFAccountLoginController.h"
#import "OFViewDataMap.h"
#import "OFProvider.h"
#import "OFISerializer.h"
#import "OFProvider.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFShowMessageAndReturnController.h"
#import "OFFormControllerHelper+Submit.h"
#import "OFSelectAccountTypeController.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "FBConnect.h"

@implementation OFAccountLoginController

@synthesize contentView;
@synthesize scrollView;

- (IBAction)usedOtherAccountType
{
	OFSelectAccountTypeController* accountController = (OFSelectAccountTypeController*)OFControllerLoader::load(@"SelectAccountType");
	[accountController setCancelDelegate:mCancelDelegate];
	[accountController setCompletionDelegate:mCompletionDelegate];
	[[self navigationController] pushViewController:accountController animated:YES];
}

- (IBAction)createNewAccount
{
	[self showLoadingScreen];
	[OpenFeint doBootstrap:true onSuccess:OFDelegate(self, @selector(_bootstrapSucceeded)) onFailure:OFDelegate(self, @selector(_bootstrapFailed))];
	
	self.navigationItem.hidesBackButton = YES;
}

- (void)_bootstrapSucceeded
{
	[self hideLoadingScreen];

	[[FBSession session] logout];
	[FBSession deleteFacebookCookies];
	
	OFNewAccountController* newAccountController = (OFNewAccountController*)OFControllerLoader::load(@"NewAccount");
    if ([OpenFeint isShowingFullScreen])
    {
        [newAccountController hideIntroFlowViews];
    }
        
	OFDelegate completeDelegate = mCompletionDelegate;
	if (!mCompletionDelegate.isValid())
	{
		completeDelegate = OFDelegate(self, @selector(popOutOfAccountFlow));
	}

	[newAccountController setCompleteDelegate:completeDelegate];
	[newAccountController setCancelDelegate:mCancelDelegate];

	[[self navigationController] pushViewController:newAccountController animated:YES];
}

- (void)_bootstrapFailed
{
	[self hideLoadingScreen];
	[[[[UIAlertView alloc] 
		initWithTitle:@"Error" 
		message:@"There was an error creating a new account. Please verify you are online and try again." 
		delegate:nil
		cancelButtonTitle:@"Ok" 
		otherButtonTitles:nil] autorelease] show];
		
	self.navigationItem.hidesBackButton = NO;
}

- (void)cancelSetup
{
	[self hideLoadingScreen];
	[super cancelSetup];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	CGSize totalContentSize = self.contentView.frame.size;
	totalContentSize.height += self.contentView.frame.origin.y;
	self.scrollView.contentSize = totalContentSize;
}

- (bool)shouldUseOAuth
{
	return false;
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"email",	1);
	dataMap->addFieldReference(@"password", 2);
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	
	OFRetainedPtr <NSString> credentialsType = @"http_basic"; 
	parameterStream->io("credential_type", credentialsType);
}

- (void)registerActionsNow
{
}

- (NSString*)singularResourceName
{
	return @"credential";
}

- (NSString*)getFormSubmissionUrl
{
	return @"session.xml";
}

- (OFShowMessageAndReturnController*)controllerToPushOnCompletion
{
	return [self getStandardLoggedInController];
}

- (void)dealloc
{
	self.contentView = nil;
	self.scrollView = nil;
	[super dealloc]; 
}

@end
