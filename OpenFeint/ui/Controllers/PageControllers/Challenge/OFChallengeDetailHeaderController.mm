////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
///  This is beta software and is subject to changes without notice.
///
///  Do not distribute.
///
///  Copyright (c) 2009 Aurora Feint Inc. All rights reserved.
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Resizing constants
#define MIN_LABEL_HEIGHT 20.f
#define MAX_LABEL_HEIGHT 9999.f
#define MAX_LABEL_WIDTH_PORTRAIT 220.f
#define MAX_LABEL_WIDTH_LANDSCAPE 380.f
#define VIEW_BUFFER 5.f

#import "OFDependencies.h"
#import "OFChallengeDetailHeaderController.h"
#import "OFChallenge.h"
#import "OFChallengeDetailController.h"
#import	"OFChallengeDefinition.h"
#import "OFChallengeToUser.h"
#import "OFChallengeDetailFrame.h"
#import "OFUser.h"
#import "OpenFeint+UserOptions.h"

@implementation OFChallengeDetailHeaderController

@synthesize challengeDetailController, challengeDescriptionContainer, startChallengeButton;

- (void)dealloc
{
	self.challengeDetailController = nil;
	self.challengeDescriptionContainer = nil;
	self.startChallengeButton = nil;
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if(challengeDetailController.userChallenge != nil)
	{
		[self setChallengeToUser:challengeDetailController.userChallenge];
	}
}

- (void)setChallengeToUser:(OFChallengeToUser*)newChallenge
{
	[self.challengeDescriptionContainer setChallengeToUser:challengeDetailController.userChallenge];
	
	bool belongsToLocalApplication = [[OpenFeint clientApplicationId] isEqualToString:newChallenge.challenge.challengeDefinition.clientApplicationId];
	bool hidePlayChallengeButton = ![newChallenge.recipient isLocalUser] || newChallenge.isCompleted || !belongsToLocalApplication;
	
	self.startChallengeButton.hidden = hidePlayChallengeButton;
	
	CGRect viewRect = self.view.frame;
	const float kPadding = 20.f;
	if (self.startChallengeButton.hidden)
	{
		viewRect.size.height = self.challengeDescriptionContainer.frame.origin.y + self.challengeDescriptionContainer.frame.size.height + kPadding;
	}
	else
	{
		viewRect.size.height = self.startChallengeButton.frame.origin.y + self.startChallengeButton.frame.size.height + kPadding;
	}
	
	self.view.frame = viewRect;
	[self.view setNeedsLayout];
}

- (void)_challengeDefinitionDownloadFailed
{
	OFLog(@"OFChallengeService challenge data download failed!");
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)resizeView:(UIView*)parentView
{	
	CGRect lastRect = self.startChallengeButton.hidden ? self.challengeDescriptionContainer.speechBubble.frame : self.startChallengeButton.frame;
	CGRect myRect = CGRectMake(0.0f, 0.0f, parentView.frame.size.width, lastRect.origin.y + lastRect.size.height + 20.f);
	self.view.frame = myRect;
	[self.view layoutSubviews];
}

@end
