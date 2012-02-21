////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///  This is beta software and is subject to changes without notice.
///
///  Do not distribute.
///
///  Copyright (c) 2009 Aurora Feint Inc. All rights reserved.
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "OFDependencies.h"
#import "OFChallengeDetailFrame.h"
#import "OFChallenge.h"
#import	"OFChallengeDefinition.h"
#import "OFUser.h"
#import "OFChallengeToUser.h"
#import "OFImageLoader.h"

@implementation OFChallengeDetailFrame

@synthesize descriptionLabel, resultLabel, titleLabel, resultIcon, speechBubble, speechBubbleArrow;
@synthesize challengeIconPictureView, challengerProfilePictureView, challengerNameLabel, challengerUserMessageLabel;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.speechBubble.image = [speechBubble.image stretchableImageWithLeftCapWidth:8 topCapHeight:16];
	CGRect arrowFrame = self.speechBubbleArrow.frame;
	self.speechBubbleArrow.frame = arrowFrame;
	self.speechBubbleArrow.transform = CGAffineTransformMake(-1.f, 0.f, 0.f, -1.f, 0.f, 0.f);
	
	if (!hasChallengeToUserBeenSet)
	{
		self.descriptionLabel.text = @"";
		self.resultLabel.text = @"";
		self.titleLabel.text = @"";
		self.challengerNameLabel.text = @"From ";
		self.challengerUserMessageLabel.text = @"";
	}
}

- (void)dealloc
{
	self.descriptionLabel = nil;
	self.resultLabel = nil;
	self.titleLabel = nil;
	self.resultIcon = nil;
	self.challengeIconPictureView = nil;
	self.challengerProfilePictureView = nil;
	self.challengerNameLabel = nil;
	self.challengerUserMessageLabel = nil;
	self.speechBubble = nil;
	self.speechBubbleArrow = nil;
	[super dealloc];
}

- (void)setChallengeToUser:(OFChallengeToUser*)newChallenge
{
	hasChallengeToUserBeenSet = YES;
	
	[self.challengeIconPictureView setDefaultImage:[OFImageLoader loadImage:@"OFDefaultChallengeIcon.png"]];
	self.challengeIconPictureView.imageUrl = newChallenge.challenge.challengeDefinition.iconUrl;
	
	self.titleLabel.text = newChallenge.challenge.challengeDefinition.title;
	
	self.descriptionLabel.text = newChallenge.challenge.challengeDescription;
	
	self.resultLabel.text = newChallenge.formattedResultDescription;
	self.resultLabel.hidden = NO;
	self.resultIcon.hidden = NO;

	NSString* challengeResultIconName = [OFChallengeToUser getChallengeResultIconName:newChallenge.result];
	self.resultIcon.image = challengeResultIconName ? [OFImageLoader loadImage:challengeResultIconName] : nil;
	
	self.challengerNameLabel.text = newChallenge.challenge.challenger.name;
	
	self.challengerUserMessageLabel.text = newChallenge.challenge.userMessage;
	
	[self.challengerProfilePictureView useProfilePictureFromUser:newChallenge.challenge.challenger];
}

@end
