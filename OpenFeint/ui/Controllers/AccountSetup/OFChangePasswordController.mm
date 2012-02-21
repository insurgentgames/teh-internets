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

#import "OFChangePasswordController.h"
#import "OFShowMessageAndReturnController.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFViewDataMap.h"
#import "OFISerializer.h"
#import "OFViewHelper.h"
#import "OFSelectAccountTypeController.h"
#import "OFControllerLoader.h"

namespace 
{
	const int kOldPasswordInputFieldTag = 1;
	const int kPasswordInputFieldTag = 2;
	const int kPasswordConfirmationInputFieldTag = 3;
}
@implementation OFChangePasswordController

@synthesize oldPasswordField;
@synthesize passwordField;
@synthesize passwordConfirmationField;


- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"password", kPasswordInputFieldTag);	
	dataMap->addFieldReference(@"password_confirmation", kPasswordConfirmationInputFieldTag);	
	dataMap->addFieldReference(@"old_password", kOldPasswordInputFieldTag);	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	oldPasswordField.text = @"";
	
	passwordField.text = @"";
	passwordConfirmationField.text = @"";
}

- (void)onBeforeFormSubmitted
{
	[oldPassword release];
	UITextField* pwField = (UITextField*)OFViewHelper::findViewByTag(self.view, kOldPasswordInputFieldTag);
	oldPassword = [pwField.text retain];

	[password release];
	pwField = (UITextField*)OFViewHelper::findViewByTag(self.view, kPasswordInputFieldTag);
	password = [pwField.text retain];

	[passwordConfirmation release];
	pwField = (UITextField*)OFViewHelper::findViewByTag(self.view, kPasswordConfirmationInputFieldTag);
	passwordConfirmation = [pwField.text retain];
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	OFRetainedPtr<NSString> me = @"me";
	parameterStream->io("id", me);
}

- (void)registerActionsNow
{
}

- (void)onFormSubmitted
{
	oldPasswordField.text = oldPassword;
	passwordField.text = password;
	passwordConfirmationField.text = passwordConfirmation;

	OFShowMessageAndReturnController *controller = (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");

	if (password.length > 0 && passwordConfirmation.length > 0)
		controller.messageLabel.text = @"Your password has been successfully changed!";
	else
		controller.messageLabel.text = @"Your password has not been changed.";

	controller.messageTitleLabel.text = @"Change Password";
	[[self navigationController] pushViewController:controller animated:YES];

	OFSafeRelease(oldPassword);
	OFSafeRelease(password);
	OFSafeRelease(passwordConfirmation);
}

- (NSString*)singularResourceName
{
	return @"http_basic_credential";
}

- (NSString*)getFormSubmissionUrl
{
	return @"http_basic_credentials/update_password.xml";
}

- (NSString*)getHTTPMethod
{
	return @"POST";
}

- (void)dealloc
{
	self.oldPasswordField = nil;
	self.passwordField = nil;
	self.passwordConfirmationField = nil;
	OFSafeRelease(oldPassword);
	OFSafeRelease(password);
	OFSafeRelease(passwordConfirmation);
	[super dealloc];
}

@end
