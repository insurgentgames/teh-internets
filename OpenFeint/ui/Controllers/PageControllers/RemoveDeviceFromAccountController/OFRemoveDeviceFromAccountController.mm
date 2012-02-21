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

#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"

#import "OFRemoveDeviceFromAccountController.h"

#import "OFService.h"
#import "OFISerializer.h"

@implementation OFRemoveDeviceFromAccountController

@synthesize warningText, titleLabel;

#pragma mark Boilerplate

- (void)dealloc
{
	self.warningText = nil;
	self.titleLabel = nil;
	[super dealloc];
}

- (bool)canReceiveCallbacksNow
{
	return YES;
}

- (NSString*)getFormSubmissionUrl
{
	return @"users/remove_from_device.xml";
}

- (void)registerActionsNow
{
}

- (NSString*)singularResourceName
{
	return @"users";
}

- (NSString*)getHTTPMethod
{
	return @"GET";
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	parameterStream->io("user_id", [OpenFeint lastLoggedInUserId]);
	parameterStream->io("udid", [[UIDevice currentDevice] uniqueIdentifier]);
}

- (void)onFormSubmitted
{
	[OpenFeint logoutUser];
	[OpenFeint dismissDashboard];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	self.navigationItem.hidesBackButton = NO;
	
	if ([OpenFeint loggedInUserHasHttpBasicCredential])
	{
		warningText.text = @"You are about to remove your account from this device and log out. You will be able to log in to this account at any time with the email address and password you used to secure this account.";
	} else {
		warningText.text = @"You are about to remove your account from this device and log out. You will not be able to recover your account unless you first secure it in the Settings tab!";
		
		NSString *errorMsg = @"Warning! Your account will be lost and you will not be able to recover it. Tap 'Go Back' to return to the Settings tab and choose 'Secure Account'.";
		UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:errorMsg delegate:self cancelButtonTitle:@"Go Back" destructiveButtonTitle:@"Continue" otherButtonTitles:nil] autorelease];
		[sheet showInView:[OpenFeint getTopLevelView]];
	}
	if (![OpenFeint isInLandscapeMode])
		titleLabel.text = @"Remove Account";
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[self navigationController] popViewControllerAnimated:YES];
	}
	actionSheet.delegate = nil;
}

@end