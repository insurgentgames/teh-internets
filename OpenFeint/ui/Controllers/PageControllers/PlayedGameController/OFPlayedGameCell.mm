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
#import "OFPlayedGameCell.h"
#import "OFViewHelper.h"
#import "OFImageView.h"
#import "OFPlayedGame.h"
#import "OFUserGameStat.h"
#import "OFApplicationDescriptionController.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserOptions.h"

@implementation OFPlayedGameCell

@synthesize iconView, 
			nameLabel,
			friendsWithAppLabel,
			secondStatView, 
			firstStatView, 
			firstGamerScoreLabel, 
			secondGamerScoreLabel, 
			shoppingCartButton, 
			owner,
			firstGamerScoreIcon,
			secondGamerScoreIcon,
			miniScreenshotOneView,
			miniScreenshotTwoView,
			firstFavoritedIcon,
			secondFavoritedIcon,
			comparisonDividerIcon;

- (void)onResourceChanged:(OFResource*)resource
{
	OFPlayedGame* playedGame = (OFPlayedGame*)resource;
		
	OFSafeRelease(clientApplicationId);
	clientApplicationId = [playedGame.clientApplicationId retain];
	nameLabel.text = playedGame.name;
	if (playedGame.friendsWithApp == 0)
	{
		friendsWithAppLabel.hidden = YES;
	}
	else
	{
		friendsWithAppLabel.hidden = NO;
		friendsWithAppLabel.text = [NSString stringWithFormat:@"%d %@ this game", playedGame.friendsWithApp, playedGame.friendsWithApp == 1 ? @"friend has" : @"friends have"];
	}
	
	[iconView setDefaultImage:[OFImageLoader loadImage:@"OFDefaultApplicationIcon.png"]];
	iconView.imageUrl = playedGame.iconUrl;

	firstStatView.hidden = YES;
	secondStatView.hidden = YES;
	shoppingCartButton.hidden = YES;
	firstFavoritedIcon.hidden = YES;
	secondFavoritedIcon.hidden = YES;
	comparisonDividerIcon.hidden = YES;

	bool showGetItNow = NO;
	const bool hasIPurchasePage = playedGame.iconUrl != nil;
	if([playedGame.userGameStats count] > 0)
	{
		OFUserGameStat* firstStat = [playedGame.userGameStats objectAtIndex:0];
		OFUserGameStat* secondStat = ([playedGame.userGameStats count] > 1) ? [playedGame.userGameStats objectAtIndex:1] : nil;
		OFUserGameStat* yourStats = [firstStat.userId isEqualToString:[OpenFeint lastLoggedInUserId]] ? firstStat : secondStat;
		OFUserGameStat* otherUsersStats = (yourStats == firstStat) ? secondStat : firstStat;
		
		firstGamerScoreIcon.image = [OFImageLoader loadImage:@"OFTableFeintPoints.png"];
		secondGamerScoreIcon.image = [OFImageLoader loadImage:@"OFTableFeintPoints.png"];
		
		firstStatView.hidden = NO;
		
		if (otherUsersStats)
		{
			showGetItNow = !yourStats.userHasGame && hasIPurchasePage;
			secondStatView.hidden = showGetItNow;

			firstGamerScoreLabel.text = [NSString stringWithFormat:@"%u", otherUsersStats.userGamerScore];	
			secondGamerScoreLabel.text = [NSString stringWithFormat:@"%u", yourStats.userGamerScore];

			[self bringSubviewToFront:comparisonDividerIcon];
			comparisonDividerIcon.hidden = NO;
			firstFavoritedIcon.hidden = !otherUsersStats.userFavoritedGame;
			secondFavoritedIcon.hidden = !yourStats.userFavoritedGame;
			
			if (!showGetItNow)
			{
				if (otherUsersStats.userGamerScore < yourStats.userGamerScore)
				{
					secondGamerScoreIcon.image = [OFImageLoader loadImage:@"OFTableFeintPointsWin.png"];
				}
				else if (otherUsersStats.userGamerScore > yourStats.userGamerScore)
				{
					firstGamerScoreIcon.image = [OFImageLoader loadImage:@"OFTableFeintPointsWin.png"];
				}
			}
		}
		else
		{
			firstGamerScoreLabel.text = [NSString stringWithFormat:@"%u", yourStats.userGamerScore];
			firstFavoritedIcon.hidden = !yourStats.userFavoritedGame;
		}		
	}
	
	if(false) // citron note: cut for 2.4
	{
		self.miniScreenshotOneView.imageUrl = nil;
		self.miniScreenshotTwoView.imageUrl = nil;
		self.miniScreenshotOneView.hidden = NO;
		self.miniScreenshotTwoView.hidden = NO;
		self.miniScreenshotOneView.unframed = YES;
		self.miniScreenshotTwoView.unframed = YES;
				
		CGRect frame = self.frame;
		frame.size.height = 107.f;
		self.frame = frame;
	}
	else
	{
		self.miniScreenshotOneView.hidden = YES;
		self.miniScreenshotTwoView.hidden = YES;
		
		CGRect frame = self.frame;
		frame.size.height = 56.f;
		self.frame = frame;
	}	
	
	shoppingCartButton.hidden = !showGetItNow;
	shoppingCartButton.userInteractionEnabled = showGetItNow;

	if(shoppingCartButton.hidden && firstStatView.hidden && hasIPurchasePage)
	{
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		self.accessoryType = UITableViewCellAccessoryNone;
	}
}

- (IBAction)showIPurchasePage
{
	OFApplicationDescriptionController* iPromoteController = [OFApplicationDescriptionController applicationDescriptionForId:clientApplicationId appBannerPlacement:@"playedGameCell"];
	[owner.navigationController pushViewController:iPromoteController animated:YES];
}

- (IBAction)showAppStorePage
{
	OFPlayedGame* game = (OFPlayedGame*)self.resource;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:game.iTunesAppStoreUrl]];
}


- (void)dealloc
{
	OFSafeRelease(clientApplicationId);
	self.nameLabel = nil;
	self.iconView = nil;
	self.firstStatView = nil;
	self.secondStatView = nil;
	self.firstGamerScoreLabel = nil;
	self.secondGamerScoreLabel = nil;
	self.shoppingCartButton = nil;
	self.firstGamerScoreIcon = nil;
	self.secondGamerScoreIcon = nil;
	self.owner = nil;
	self.miniScreenshotOneView = nil;
	self.miniScreenshotTwoView = nil;
	self.firstFavoritedIcon = nil;
	self.secondFavoritedIcon = nil;
	self.comparisonDividerIcon = nil;
	[super dealloc];
}

@end
