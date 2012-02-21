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

#import "OFChangeEmailController.h"
#import "OFShowMessageAndReturnController.h"
#import "OFHttpBasicCredential.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFViewDataMap.h"
#import "OFISerializer.h"
#import "OFViewHelper.h"
#import "OFSelectAccountTypeController.h"
#import "OFControllerLoader.h"

#import "OFUserService.h"
#import "OFPaginatedSeries.h"

namespace 
{
	const int kEmailInputFieldTag = 1;
}
@implementation OFChangeEmailController

@synthesize currentEmailLabel;
@synthesize newEmailField;


- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"email", kEmailInputFieldTag);	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	currentEmailLabel.text = @"";
	newEmailField.text = @"";

	OFDelegate success(self, @selector(onGetEmailSuccess:));
	OFDelegate failure(self, @selector(onGetEmailFailure:));
	[OFUserService getEmailForUser:@"me" onSuccess:success onFailure:failure];
}

- (void)onGetEmailSuccess:(OFPaginatedSeries *)emails
{
	//OFLog(@"onGetEmailSuccess: %@", [emails.objects objectAtIndex:0]);
	currentEmailLabel.text = [(OFHttpBasicCredential *)[emails.objects objectAtIndex:0] email];
}

- (void)onGetEmailFailure:(OFPaginatedSeries *)emails
{
	//OFLog(@"onGetEmailFailure: %@", [emails.objects objectAtIndex:0]);
	currentEmailLabel.text = @"error getting email for user";
}

- (void)onBeforeFormSubmitted
{
	[emailAttemptingToClaim release];
	UITextField* emailField = (UITextField*)OFViewHelper::findViewByTag(self.view, kEmailInputFieldTag);
	emailAttemptingToClaim = [emailField.text retain];
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
	newEmailField.text = emailAttemptingToClaim;
	[OpenFeint reloadInactiveTabBars];
	OFShowMessageAndReturnController* controller = (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
	controller.messageLabel.text = [NSString stringWithFormat:@"Your email has been changed to\n%@.", emailAttemptingToClaim];
	controller.messageTitleLabel.text = @"Change Email";
	[[self navigationController] pushViewController:controller animated:YES];
	OFSafeRelease(emailAttemptingToClaim);
}

- (NSString*)singularResourceName
{
	return @"http_basic_credential";
}

- (NSString*)getFormSubmissionUrl
{
	return @"http_basic_credentials/update_email.xml";
}

- (NSString*)getHTTPMethod
{
	return @"POST";
}

- (void)dealloc
{
	self.newEmailField = nil;
	self.currentEmailLabel = nil;
	OFSafeRelease(emailAttemptingToClaim);
	[super dealloc];
}

@end
