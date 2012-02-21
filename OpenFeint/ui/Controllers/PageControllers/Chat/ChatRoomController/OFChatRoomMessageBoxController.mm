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
#import "OFChatRoomMessageBoxController.h"
#import "OFViewDataMap.h"
#import "OFChatMessage.h"
#import "OFNavigationController.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"

@implementation OFChatRoomMessageBoxController

@synthesize textEntryField;
@synthesize hideKeyboardButton;
@synthesize backgroundView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.frame = CGRectMake(0.0f, 0.0f, [OpenFeint getDashboardBounds].size.width, 37.0f);
	mIsKeyboardShown = false;
}

- (void)_KeyboardWillShow:(NSNotification*)notification
{
	if(mIsKeyboardShown)
	{
		return;
	}

	[hideKeyboardButton setImage:[OFImageLoader loadImage:@"OFKeyboardDown.png"] forState:UIControlStateNormal];
	CGRect keyboardButtonRect = hideKeyboardButton.frame;
	keyboardButtonRect.origin.y += 3.f;
	[hideKeyboardButton setFrame:keyboardButtonRect];
	mIsKeyboardShown = true;
}

- (void)_KeyboardWillHide:(NSNotification*)notification
{
	if(!mIsKeyboardShown)
	{
		return;
	}
		
	[hideKeyboardButton setImage:[OFImageLoader loadImage:@"OFKeyboardUp.png"] forState:UIControlStateNormal];
	CGRect keyboardButtonRect = hideKeyboardButton.frame;
	keyboardButtonRect.origin.y -= 3.f;
	[hideKeyboardButton setFrame:keyboardButtonRect];
	mIsKeyboardShown = false;	
}

- (IBAction)toggleKeyboardNow
{
	if(mIsKeyboardShown)
	{
		[textEntryField resignFirstResponder];
	}
	else
	{
		[textEntryField becomeFirstResponder];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (bool)shouldShowLoadingScreenWhileSubmitting
{
	return false;
}

- (void)registerActionsNow
{
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"message", 1);
}

- (NSString*)getFormSubmissionUrl
{
	return @"chat_messages.xml";
}

- (NSString*)getLoadingScreenText
{
	return @"Sending Chat Message";
}

- (void)onBeforeFormSubmitted
{
	textEntryField.text = @"";
}

- (void)onFormSubmitted
{
	// Do Nothing
}

- (NSString*)singularResourceName
{
	return [OFChatMessage getResourceName];
}

- (void)dealloc 
{
	self.textEntryField = nil;
	self.hideKeyboardButton = nil;
	self.backgroundView = nil;
    [super dealloc];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (bool)shouldDismissKeyboardWhenSubmitting
{
	return false;
}
@end
