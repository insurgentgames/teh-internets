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
#import "OFChallengeDefinition.h"
#import "OFImageView.h"

@class OFSendChallengeController;
@class OFDefaultTextField;

@interface OFSendChallengeHeaderController : UIViewController<OFTableControllerHeader,OFCallbackable>
{
@private
	BOOL						finishedDownloadingChallenge;
	OFSendChallengeController* sendChallengeController;
	UILabel*					titleLabel;
	UILabel*					descriptionLabel;
	UIButton*					sendChallengeButton;
	UIButton*					tryAgainButton;
	OFImageView*				challengeIconImageView;
	UIView*						descriptionContainer;
	OFDefaultTextField*			userMessageTextField;
	OFRetainedPtr<NSObject>		selfRetainer;
	OFRetainedPtr<NSObject>		parentRetainer;
}

@property (nonatomic, readwrite, assign) IBOutlet OFSendChallengeController* sendChallengeController;
@property (nonatomic, retain) IBOutlet UILabel*		titleLabel;
@property (nonatomic, retain) IBOutlet UILabel*		descriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton*	sendChallengeButton;
@property (nonatomic, retain) IBOutlet UIButton*	tryAgainButton;
@property (nonatomic, retain) IBOutlet OFImageView*	challengeIconImageView;
@property (nonatomic, retain) IBOutlet UIView*		descriptionContainer;
@property (nonatomic, retain) IBOutlet OFDefaultTextField* userMessageTextField;

- (IBAction)createStrongerChallenge;
- (bool)canReceiveCallbacksNow;
- (void)setChallenge:(OFChallengeDefinition*)newChallengeDefinition;

@end