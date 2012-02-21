////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///  This is beta software and is subject to changes without notice.
///
///  Do not distribute.
///
///  Copyright (c) 2009 Aurora Feint Inc. All rights reserved.
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma once

#import "OFTableControllerHeader.h"
#import "OFChallengeToUser.h"
#import "OFImageView.h"

@class OFChallengeDetailController;
@class OFChallengeDetailFrame;

@interface OFChallengeDetailHeaderController : UIViewController<OFTableControllerHeader,OFCallbackable>
{
@private
	OFChallengeDetailController* challengeDetailController;
	UIButton*					startChallengeButton;
	OFChallengeDetailFrame*		challengeDescriptionContainer;
	
}

@property (nonatomic, readwrite, assign) IBOutlet OFChallengeDetailController* challengeDetailController;
@property (nonatomic, retain) IBOutlet UIButton*				startChallengeButton;
@property (nonatomic, retain) IBOutlet OFChallengeDetailFrame*	challengeDescriptionContainer;

- (bool)canReceiveCallbacksNow;
- (void)setChallengeToUser:(OFChallengeToUser*)newChallenge;

@end
