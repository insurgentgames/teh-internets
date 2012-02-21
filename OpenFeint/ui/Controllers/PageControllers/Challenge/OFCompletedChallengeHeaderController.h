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

#pragma once

#import "OFTableControllerHeader.h"
#import "OFChallengeToUser.h"
#import "OFImageView.h"
#import "OFViewController.h"

@class OFSendChallengeController;
@class OFChallengeDetailFrame;
@class OFDefaultButton;
@class OFDefaultTextField;

// NB: we deriving from OFViewController because sometimes this controller is NOT used as a header,
// but as the vc that the navController pushes.  In that case, it needs to support the correct
// autorotate behavior.
@interface OFCompletedChallengeHeaderController : OFViewController<OFTableControllerHeader,OFCallbackable> 
{
@private
	OFSendChallengeController*	sendChallengeController;
	OFChallengeDetailFrame*		challengeDescriptionContainer;
	OFDefaultButton*			actionButton;
	OFDefaultTextField*			userMessageTextField;
	UILabel*					personalMessageLabel;
	SEL							action;
	id							target;
}

@property (nonatomic, readwrite, assign) IBOutlet OFSendChallengeController* sendChallengeController;
@property (nonatomic, retain) IBOutlet OFChallengeDetailFrame*		challengeDescriptionContainer;
@property (nonatomic, retain) IBOutlet OFDefaultButton*				actionButton;
@property (nonatomic, retain) IBOutlet OFDefaultTextField*			userMessageTextField;
@property (nonatomic, retain) IBOutlet UILabel*						personalMessageLabel;

- (bool)canReceiveCallbacksNow;
- (void)setChallenge:(OFChallengeToUser*)newUserChallenge;
- (IBAction)onActionButtonPressed;
@end
