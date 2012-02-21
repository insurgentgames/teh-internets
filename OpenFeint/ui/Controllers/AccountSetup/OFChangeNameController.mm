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

#import "OFChangeNameController.h"
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
	const int kNameInputFieldTag = 1;
}
@implementation OFChangeNameController

@synthesize currentNameLabel;


- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"name", kNameInputFieldTag);	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	currentNameLabel.text = [OpenFeint lastLoggedInUserName];	
	
	if ([OpenFeint loggedInUserHasNonDeviceCredential])
	{
		UIView* oldUserButton = OFViewHelper::findViewByTag(self.view, 5);
		oldUserButton.hidden = YES;
	}
	
}

- (void)onBeforeFormSubmitted
{
	[nameAttemptingToClaim release];
	UITextField* nameField = (UITextField*)OFViewHelper::findViewByTag(self.view, kNameInputFieldTag);
	nameAttemptingToClaim = [nameField.text retain];
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
	[OpenFeint loggedInUserChangedNameTo:nameAttemptingToClaim];
	currentNameLabel.text = nameAttemptingToClaim;
	[OpenFeint reloadInactiveTabBars];
	
	OFShowMessageAndReturnController* controller = (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
	controller.messageLabel.text = [NSString stringWithFormat:@"You have changed your OpenFeint name to %@.", nameAttemptingToClaim];
	controller.messageTitleLabel.text = @"Change Name";
	[[self navigationController] pushViewController:controller animated:YES];
	OFSafeRelease(nameAttemptingToClaim);
}

- (NSString*)singularResourceName
{
	return @"user";
}

- (NSString*)getFormSubmissionUrl
{
	return @"users/update_name.xml";
}

- (NSString*)getHTTPMethod
{
	return @"POST";
}

- (void)dealloc
{
	self.currentNameLabel = nil;
	OFSafeRelease(nameAttemptingToClaim);
	[super dealloc];
}

@end
