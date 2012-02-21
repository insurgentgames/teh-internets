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
#import "OFChallengeSentCell.h"
#import "OFViewHelper.h"
#import "OFChallenge.h"
#import "OFChallengeDefinition.h"
#import "OFImageView.h"
#import "OFUser.h"
#import "OFImageLoader.h"

namespace 
{
	const int kChallengePictureTag = 1;
	const int kTitleTag = 2;
	const int kDescriptionTag = 3;
}

@implementation OFChallengeSentCell

- (void)onResourceChanged:(OFResource*)resource
{
	OFChallenge* newChallenge = (OFChallenge*)resource;
	
	OFImageView* challengePictureView = (OFImageView*)OFViewHelper::findViewByTag(self, kChallengePictureTag);
	[challengePictureView setDefaultImage:[OFImageLoader loadImage:@"OFMultiPeopleChallengeIcon.png"]];
	challengePictureView.imageUrl = newChallenge.challengeDefinition.iconUrl;
	
	UILabel	*titleLabel = (UILabel*)OFViewHelper::findViewByTag(self, kTitleTag);
	titleLabel.text = newChallenge.challengeDefinition.title;
	
	UILabel *descriptionLabel = (UILabel*)OFViewHelper::findViewByTag(self, kDescriptionTag);
	descriptionLabel.text = newChallenge.challengeDescription;
	
}

@end
