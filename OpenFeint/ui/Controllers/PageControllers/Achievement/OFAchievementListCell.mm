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
#import "OFAchievementListCell.h"
#import "OFViewHelper.h"
#import "OFAchievement.h"
#import "OFImageView.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserOptions.h"

@implementation OFAchievementListCell

@synthesize	titleLabel,
			descriptionLabel,
			firstIconContainer,
			secondIconContainer,
			firstUnlockedIcon,
			secondUnlockedIcon,
			gamerScoreContainer,
			gamerScoreLabel;

- (void)onResourceChanged:(OFResource*)resource
{	
	OFAchievement* achievement = (OFAchievement*)resource;


	OFImageView* localPlayersIconView = firstUnlockedIcon;
	
	if (achievement.comparedToUserId && 
		![achievement.comparedToUserId isEqualToString:@""] && 
		![achievement.comparedToUserId isEqualToString:[OpenFeint lastLoggedInUserId]])
	{
		localPlayersIconView = secondUnlockedIcon;
		secondIconContainer.hidden = NO;
		if (achievement.isUnlockedByComparedToUser)
		{
			if (achievement.isUnlocked)
			{
				[firstUnlockedIcon setDefaultImage:[OFImageLoader loadImage:@"OFUnlockedAchievementIcon.png"]];
				firstUnlockedIcon.imageUrl = achievement.iconUrl;
			}
			else
			{
				[firstUnlockedIcon setImage:[OFImageLoader loadImage:@"OFUnlockedAchievementIcon.png"]];
			}
		}
		else
		{
			[firstUnlockedIcon setImage:[OFImageLoader loadImage:@"OFLockedAchievementIcon.png"]];
		}
	}
	else
	{
		secondIconContainer.hidden = YES;
	}
	
	if (achievement.isUnlocked)
	{
		[localPlayersIconView setDefaultImage:[OFImageLoader loadImage:@"OFUnlockedAchievementIcon.png"]];
		localPlayersIconView.imageUrl = achievement.iconUrl;
	}
	else
	{
		[localPlayersIconView setImage:[OFImageLoader loadImage:@"OFLockedAchievementIcon.png"]];
	}
	
	CGRect gamerScoreFrame = gamerScoreContainer.frame;
	UIView* leftmostVisibleView = secondIconContainer.hidden ? firstIconContainer : secondIconContainer;
	gamerScoreFrame.origin.x = leftmostVisibleView.frame.origin.x - gamerScoreFrame.size.width - 5.f;
	gamerScoreContainer.frame = gamerScoreFrame;
	
	CGRect titleFrame = titleLabel.frame;
	titleFrame.size.width = gamerScoreFrame.origin.x - titleFrame.origin.x - 10.f;
	titleLabel.frame = titleFrame;
	CGRect descriptionFrame = descriptionLabel.frame;
	descriptionFrame.size.width = gamerScoreFrame.origin.x - descriptionFrame.origin.x - 10.f;
	descriptionLabel.frame = descriptionFrame;
	
	NSString* descriptionText = nil;
	if (achievement.isSecret && !achievement.isUnlocked)
	{
		titleLabel.text = @"Secret";
		descriptionText = @"You must unlock this achievement to view its description.";
	}
	else
	{
		titleLabel.text = achievement.title;
		descriptionText = achievement.description;
	}
	
	descriptionLabel.text = descriptionText;

	if([descriptionText length])
	{
		CGSize textSize = [descriptionText sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionFrame.size.width, FLT_MAX)];
		descriptionFrame.size = CGSizeMake(descriptionFrame.size.width, textSize.height);	// never shrink the width
		descriptionLabel.frame = descriptionFrame;
	}
	
	float endY = descriptionFrame.origin.y + descriptionFrame.size.height + 10.f;
	endY = MAX(endY, firstIconContainer.frame.origin.y + firstIconContainer.frame.size.height + firstIconContainer.frame.origin.y);
	CGRect myRect = self.frame;
	myRect.size.height = endY;
	self.frame = myRect;
	[self layoutSubviews];
	
	gamerScoreLabel.text = [NSString stringWithFormat:@"%d", achievement.gamerscore];
}

- (void)dealloc
{
	self.titleLabel = nil;
	self.descriptionLabel = nil;
	self.firstIconContainer = nil;
	self.secondIconContainer = nil;
	self.firstUnlockedIcon = nil;
	self.secondUnlockedIcon = nil;
	self.gamerScoreContainer = nil;
	self.gamerScoreLabel = nil;

	[super dealloc];
}
@end
