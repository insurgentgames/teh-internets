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
#import "OFCompletedChallengeHeaderController.h"
#import "OFChallengeDetailFrame.h"
#import "OFChallenge.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionService.h"
#import "OFSendChallengeController.h"
#import "OFDefaultButton.h"
#import "OFDefaultTextField.h"
#import "OpenFeint+Private.h"

@implementation OFCompletedChallengeHeaderController

@synthesize sendChallengeController, 
			challengeDescriptionContainer, 
			actionButton, 
			userMessageTextField, 
			personalMessageLabel;

- (void)dealloc
{
	self.sendChallengeController = nil;
	self.actionButton = nil;
	self.challengeDescriptionContainer = nil;
	self.userMessageTextField = nil;
	self.personalMessageLabel = nil;
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)cancel
{
	[OpenFeint dismissDashboard];
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], completedChallengeScreenClosed);
}

- (void)tryAgainPressed
{
	id<OFChallengeDelegate>delegate = [OpenFeint getChallengeDelegate];
	[delegate userRestartedChallenge];
	[self cancel];
}

- (void)setChallenge:(OFChallengeToUser*)newUserChallenge
{	
	[self.challengeDescriptionContainer setChallengeToUser:newUserChallenge];
	
	bool showUserMessageTextField = false;
	if (newUserChallenge.challenge.challengeDefinition.multiAttempt)
	{
		if (newUserChallenge.result != kChallengeResultRecipientWon)
		{
			[self.actionButton setTitleForAllStates:@"Try Again"];
			action = @selector(tryAgainPressed);
			target = self;
		}
		else
		{
			[self.actionButton setTitleForAllStates:@"Send Result As Challenge"];
			action = @selector(submitChallengeBack);
			showUserMessageTextField = true;
			target = self.sendChallengeController;
			[self.sendChallengeController toggleSelectionOfUser:newUserChallenge.challenge.challenger];
		}
	}
	else
	{
		[self.actionButton setTitleForAllStates:@"OK"];
		action = @selector(cancel);
		target = self;
	}
	
	if (!showUserMessageTextField)
	{
		self.personalMessageLabel.hidden = YES;
		self.userMessageTextField.hidden = YES;
		CGRect buttonRect = self.actionButton.frame;
		buttonRect.origin.y = self.challengeDescriptionContainer.speechBubble.frame.origin.y + self.challengeDescriptionContainer.speechBubble.frame.size.height + 20.f;
		self.actionButton.frame = buttonRect;
	}
	else
	{
		self.userMessageTextField.closeKeyboardOnReturn = YES;
		self.userMessageTextField.manageScrollViewOnFocus = YES;
	}
}

- (IBAction)onActionButtonPressed
{
	[target performSelector:action];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)resizeView:(UIView*)parentView
{
	CGRect lastElementRect = self.actionButton.frame;
	CGRect myRect = CGRectMake(0.0f, 0.0f, parentView.frame.size.width, lastElementRect.origin.y + lastElementRect.size.height + 10.f);
	self.view.frame = myRect;
	[self.view layoutSubviews];
}


@end
