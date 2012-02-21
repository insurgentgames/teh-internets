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
#import "OFHttpCredentialsCreateController.h"
#import "OFFormControllerHelper+Overridables.h"
#import "OFViewDataMap.h"
#import "OFProvider.h"
#import "OFISerializer.h"
#import "OFProvider.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFShowMessageAndReturnController.h"
#import "OFControllerLoader.h"

@implementation OFHttpCredentialsCreateController

- (bool)shouldUseOAuth
{
	return true;
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{	
	dataMap->addFieldReference(@"email",				2);
	dataMap->addFieldReference(@"password",				3);
	dataMap->addFieldReference(@"password_confirmation",	4);		
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
	return @"users_credentials.xml";
}

- (OFShowMessageAndReturnController*)controllerToPushOnCompletion
{
	OFShowMessageAndReturnController* nextController =  (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
	nextController.messageLabel.text = @"Your account is secured! You may now login from any device.";
	nextController.messageTitleLabel.text = @"Secure Account";
	nextController.title = @"Account Secured";
	return nextController;
}

- (void)onFormSubmitted
{
	[OpenFeint setLoggedInUserHasHttpBasicCredential:YES];
	[super onFormSubmitted];
}

@end
