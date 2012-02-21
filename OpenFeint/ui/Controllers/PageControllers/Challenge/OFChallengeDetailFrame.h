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

#import "OFChallengeToUser.h"
#import "OFImageView.h"


@interface OFChallengeDetailFrame : UIView
{
@private
	BOOL						hasChallengeToUserBeenSet;
	UILabel*					descriptionLabel;
	UILabel*					resultLabel;
	UILabel*					titleLabel;
	UIImageView*				resultIcon;
	UIImageView*				speechBubble;
	UIImageView*				speechBubbleArrow;
	UIImageView*				frameArrow;
	OFImageView*				challengeIconPictureView;
	OFImageView*				challengerProfilePictureView;
	UILabel*					challengerNameLabel;
	UILabel*					challengerUserMessageLabel;
}

@property (nonatomic, retain) IBOutlet UILabel*					descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel*					resultLabel;
@property (nonatomic, retain) IBOutlet UILabel*					titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView*				resultIcon;
@property (nonatomic, retain) IBOutlet UIImageView*				speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView*				speechBubbleArrow;
@property (nonatomic, retain) IBOutlet OFImageView*				challengeIconPictureView;
@property (nonatomic, retain) IBOutlet OFImageView*				challengerProfilePictureView;
@property (nonatomic, retain) IBOutlet UILabel*					challengerNameLabel;
@property (nonatomic, retain) IBOutlet UILabel*					challengerUserMessageLabel;

- (void)setChallengeToUser:(OFChallengeToUser*)newChallenge;

@end
