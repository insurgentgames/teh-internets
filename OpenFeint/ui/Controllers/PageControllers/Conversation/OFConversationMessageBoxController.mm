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

#import "OFConversationMessageBoxController.h"
#import "OFForumPost.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+Submit.h"

@implementation OFConversationMessageBoxController

@synthesize messageField, conversationId;

#pragma mark Boilerplate

- (void)dealloc
{
	self.messageField = nil;
	self.conversationId = nil;
	OFSafeRelease(sendButton);
	OFSafeRelease(backgroundView);
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	CGRect frame = messageField.frame;
	frame.size.height = 22.f;
	messageField.frame = frame;
	
	messageField.maxLines = 5;
	messageField.minLines = 1;
}

#pragma mark OFFormControllerHelper

- (bool)shouldShowLoadingScreenWhileSubmitting
{
	return false;
}

- (NSString*)getLoadingScreenText
{
	return nil;
}

- (void)registerActionsNow
{
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	parameterStream->io("post[body]", messageField.text);
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
}

- (NSString*)getFormSubmissionUrl
{
	return [NSString stringWithFormat:@"discussions/%@/posts.xml", conversationId];
}

- (IBAction)onSubmitForm:(UIView*)sender
{
	if ([messageField.text length] > 0)
	{
		[super onSubmitForm:sender];
	}
	else
	{
		[messageField resignFirstResponder];
	}
}

- (void)onBeforeFormSubmitted
{
	messageField.text = @"";
	[messageField resignFirstResponder];
}

- (void)onFormSubmitted
{
}

- (NSString*)singularResourceName
{
	return [OFForumPost getResourceName];
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