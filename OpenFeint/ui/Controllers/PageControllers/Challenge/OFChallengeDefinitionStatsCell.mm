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
#import "OFChallengeDefinitionStatsCell.h"
#import "OFViewHelper.h"
#import "OFChallenge.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionStats.h"
#import "OFImageView.h"
#import "OFUser.h"
#import "OFImageLoader.h"

@implementation OFChallengeDefinitionStatsCell

- (void)onResourceChanged:(OFResource*)resource
{
	OFChallengeDefinitionStats* stats = (OFChallengeDefinitionStats*)resource;
	OFChallengeDefinition* definition = stats.challengeDefinition; 
	[challengeIcon setDefaultImage:[OFImageLoader loadImage:@"OFDefaultChallengeIcon.png"]];
	[challengeIcon setImageUrl:definition.iconUrl];
	titleLabel.text = definition.title;
	
	tiesLabel.text = [NSString stringWithFormat:@"%d", stats.localUsersTies];

	float const halfIconWidth = roundf(winnerIcon.image.size.width * 0.5f) + 3.f;
	UIColor* winnerColor = [UIColor colorWithRed:6.f/255.f green:37.f/255.f blue:11.f/255.f alpha:1.f];
	UIColor* loserColor = tiesLabel.textColor;

	winnerIcon.hidden = YES;
	winsHeader.center = CGPointMake(winsLabel.center.x, winsHeader.center.y);
	lossesOrComparisonHeader.center = CGPointMake(lossesOrComparisonLabel.center.x, lossesOrComparisonHeader.center.y);
	winsLabel.textColor = loserColor;
	lossesOrComparisonLabel.textColor = loserColor;

	if (stats.comparison)
	{
		winsLabel.text = [NSString stringWithFormat:@"%d", stats.comparedUsersWins];
		lossesOrComparisonHeader.text = @"Wins";
		lossesOrComparisonLabel.text = [NSString stringWithFormat:@"%d", stats.localUsersWins];
		if (stats.localUsersWins < stats.comparedUsersWins)
		{
			winnerIcon.hidden = NO;
			CGPoint newCenter = CGPointMake(winsLabel.center.x - 2.f, winsHeader.center.y);
			newCenter.x += halfIconWidth;
			winsHeader.center = newCenter;
			newCenter.x -= halfIconWidth * 2.f;
			winnerIcon.center = newCenter;

			lossesOrComparisonHeader.center = CGPointMake(lossesOrComparisonLabel.center.x, lossesOrComparisonHeader.center.y);
			winsLabel.textColor = winnerColor;
		}
		else if (stats.localUsersWins > stats.comparedUsersWins)
		{
			winnerIcon.hidden = NO;
			CGPoint newCenter = CGPointMake(lossesOrComparisonLabel.center.x - 2.f, lossesOrComparisonHeader.center.y);
			newCenter.x += halfIconWidth;
			lossesOrComparisonHeader.center = newCenter;
			newCenter.x -= halfIconWidth * 2.f;
			winnerIcon.center = newCenter;

			winsHeader.center = CGPointMake(winsLabel.center.x, winsHeader.center.y);
			lossesOrComparisonLabel.textColor = winnerColor;
		}
	}
	else
	{
		winsLabel.text = [NSString stringWithFormat:@"%d", stats.localUsersWins];
		lossesOrComparisonHeader.text = @"Losses";
		lossesOrComparisonLabel.text = [NSString stringWithFormat:@"%d", stats.localUsersLosses];
	}
}

- (void)dealloc
{
	OFSafeRelease(titleLabel);
	OFSafeRelease(challengeIcon);
	OFSafeRelease(winsLabel);
	OFSafeRelease(winsHeader);
	OFSafeRelease(lossesOrComparisonLabel);
	OFSafeRelease(tiesLabel);
	OFSafeRelease(lossesOrComparisonHeader);
	OFSafeRelease(tiesHeader);
	OFSafeRelease(winnerIcon);
	[super dealloc];
}

@end
