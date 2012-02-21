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

#import "OFFanClubController.h"
#import "OFFanClubCell.h"
#import "OFControllerLoader.h"
#import "OFPaginatedSeries.h"
#import "OFTableSectionDescription.h"
#import "OFForumThreadListController.h"
#import "OFForumTopic.h"
#import "OFImageLoader.h"
#import "OFPlayedGameController.h"
#import "OFBadgeView.h"
#import "OFAnnouncementService.h"
#import "OFGameProfilePageInfo.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"

#pragma mark Initialization and Dealloc

@implementation OFFanClubController

- (id)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

- (void)dealloc
{
	
	[super dealloc];
}

#pragma mark Setup

- (void) createCell:(NSMutableArray*)cellArray withTitle:(NSString*)cellTitle andIconName:(NSString*)iconName andControllerName:(NSString*)controllerName andCreateSelector:(SEL)createSelector
{
	OFFanClubCell* curCell = (OFFanClubCell*)OFControllerLoader::loadCell(@"FanClub");
	curCell.titleLabel.text = cellTitle;
	curCell.controllerName = controllerName;
	curCell.createControllerSelector = createSelector;
	curCell.iconView.image = iconName ? [OFImageLoader loadImage:iconName] : nil;
	[cellArray addObject:curCell];
}

- (UIViewController*)createSuggestionBrowser
{
	return [OFForumThreadListController threadBrowser:[OFForumTopic suggestionsTopic:[[self getPageContextGame] suggestionsForumId]]];
}

- (UIViewController*)createDeveloperRecommendationsBrowser
{
	OFPlayedGameController* controller = (OFPlayedGameController*)OFControllerLoader::load(@"PlayedGame");
	controller.scope = kPlayedGameScopeTargetServiceIndex;
	controller.targetDiscoveryPageName = @"developers_picks";
	controller.title = @"More Games";
	return controller;
	
}

- (NSMutableArray*) buildTableSectionDescriptions
{
	NSMutableArray* staticCells = [NSMutableArray arrayWithCapacity:5];
	
	[self createCell:staticCells withTitle:@"Add Game as Favorite" andIconName:@"OFStarIcon.png" andControllerName:@"FavoriteThisGame" andCreateSelector:nil];
	[self createCell:staticCells withTitle:@"Developer Announcements" andIconName:@"OFDevAnnouncementsIcon.png" andControllerName:@"AnnouncementBrowser" andCreateSelector:nil];
	[self createCell:staticCells withTitle:@"Subscribe to Newsletter" andIconName:@"OFNewsLetterIcon.png" andControllerName:@"NewsLetter" andCreateSelector:nil];
	if ([OpenFeint allowUserGeneratedContent])
	{
		[self createCell:staticCells withTitle:@"Suggest a Feature" andIconName:@"OFIdeaIcon.png" andControllerName:nil andCreateSelector:@selector(createSuggestionBrowser)];
	}
	if ([OpenFeint appHasFeaturedApplication])
	{
		[self createCell:staticCells withTitle:@"More Games" andIconName:@"OFMoreGamesIcon.png" andControllerName:nil andCreateSelector:@selector(createDeveloperRecommendationsBrowser)];	
	}
	
	
	return [NSMutableArray arrayWithObject:[OFTableSectionDescription sectionWithTitle:nil andStaticCells:staticCells]];
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([mSections count] > 0)
	{
		NSMutableArray* staticCells = [[mSections objectAtIndex:0] staticCells];
		if ([staticCells count] > indexPath.row)
		{
			OFFanClubCell* cell = [staticCells objectAtIndex:indexPath.row];
			UIViewController* controller = cell.createControllerSelector ? [self performSelector:cell.createControllerSelector] : OFControllerLoader::load(cell.controllerName);
			[self.navigationController pushViewController:controller animated:YES];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([mSections count] > 0 && [[self getPageContextGame] isLocalGameInfo])
	{
		OFFanClubCell* cell = [[[mSections objectAtIndex:0] staticCells] objectAtIndex:1];
		cell.badgeView.value = [OFAnnouncementService unreadAnnouncements];
	}	
}

#pragma mark OFBannerProvider

- (bool)isBannerAvailableNow
{
	return false;
}

- (NSString*)bannerCellControllerName
{
	return @"GameDiscoveryImageHyperlink";
}

- (OFResource*)getBannerResource
{
	return nil;
}

- (void)onBannerClicked
{
	
}

@end
