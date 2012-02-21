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
#import "OFPlayedGameController.h"
#import "OFResourceControllerMap.h"
#import "OFPlayedGame.h"
#import "OFClientApplicationService.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFGameProfileController.h"
#import "OFControllerLoader.h"
#import "OpenFeint+UserOptions.h"
#import "OFUserGameStat.h"
#import "OFDefaultLeadingCell.h"
#import "OFUser.h"
#import "OFTabbedPageHeaderController.h"
#import "OFApplicationDescriptionController.h"
#import "OFGameDiscoveryService.h"
#import "OFGameDiscoveryNewsItem.h"
#import "OFGameDiscoveryCategory.h"
#import "OFGameDiscoveryNewsItemController.h"
#import "OFGameDiscoveryImageHyperlink.h"
#import "OFTableSectionDescription.h"
#import "OFFramedNavigationController.h"
#import "OFTableCellHelper+Overridables.h"
#import "OFImportFriendsController.h"
#import "OFGameDiscoveryImageHyperlinkCell.h"

@implementation OFPlayedGameController

@synthesize scope;
@dynamic targetDiscoveryPageName;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	if(reloadWhenShownNext)
	{
		[self reloadDataFromServer];
	}
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFPlayedGame class], @"PlayedGame");
	resourceMap->addResource([OFGameDiscoveryImageHyperlink class], @"GameDiscoveryImageHyperlink");
	resourceMap->addResource([OFGameDiscoveryCategory class], @"GameDiscoveryCategory");	
	resourceMap->addResource([OFGameDiscoveryNewsItem class], @"GameDiscoveryNewsItem");
}

- (OFService*)getService
{
	return [OFClientApplicationService sharedInstance];
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (NSString*)getNoDataFoundMessage
{
	if (scope == kPlayedGameScopeFriendsGames)
	{
		return @"You have not added any OpenFeint friends yet. Find friends on the friends tab.";
	}
	else
	{
		if (inFavoriteTab)
		{
			
			OFUser* user = [self getPageContextUser];
			if ([user isLocalUser])
			{
				return @"You don't have any favorite games. To favorite this game go to the game tab and press the Fan Club button.";
			}
			else
			{
				return [NSString stringWithFormat:@"%@ has not added any favorite games yet.", user.name];
			}
		}
		else
		{			
			return @"Failed to download games list";
		}
	}
}

- (NSString*)getTableHeaderControllerName
{
	return (scope == kPlayedGameScopeMyGames) ? @"TabbedPageHeader" : nil;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFTabbedPageHeaderController* header = (OFTabbedPageHeaderController*)tableHeader;
	header.callbackTarget = self;
	[header addTab:@"All Games" andSelectedCallback:@selector(onAllGamesSelected)];
	[header addTab:@"Favorite Games" andSelectedCallback:@selector(onFavoriteGamesSelected)];
}

- (void)onAllGamesSelected
{
	inFavoriteTab = false;
	[self reloadDataFromServer];
}

- (void)onFavoriteGamesSelected
{
	inFavoriteTab = true;
	[self reloadDataFromServer];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	if (scope == kPlayedGameScopeFriendsGames)
	{
		[OFClientApplicationService getPlayedGamesForLocalUsersFriends:oneBasedPageNumber onSuccess:success onFailure:failure];
	}
	else if(scope == kPlayedGameScopeTargetServiceIndex)
	{
		[OFGameDiscoveryService getDiscoveryPageNamed:targetDiscoveryPageName withPage:oneBasedPageNumber onSuccess:success onFailure:failure];
	}
	else
	{
		NSString* userId = [self getPageContextUser].resourceId;
		if (inFavoriteTab)
		{
			[OFClientApplicationService getFavoriteGamesForUser:userId withPage:oneBasedPageNumber andCountPerPage:10 onSuccess:success onFailure:failure];	
		}
		else
		{
			[OFClientApplicationService getPlayedGamesForUser:userId withPage:oneBasedPageNumber andCountPerPage:10 onSuccess:success onFailure:failure];	
		}
	}
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	UIViewController* nextController = nil;

	NSString* categoryToPush = nil;
	NSString* categoryPageDisplayTitle = nil;
	NSString* appPurchaseIdToPush = nil;

	reloadWhenShownNext = false;

	NSString* displayContext = [NSString stringWithFormat:@"playedGameController_%@_%d", targetDiscoveryPageName, [indexPath row]];

	
	if([cellResource isKindOfClass:[OFGameDiscoveryImageHyperlink class]])
	{
		// This is slightly janky =)  may wanna fix.  @ben's bad.
		OFTableCellHelper* cell = (OFTableCellHelper*)[self.tableView cellForRowAtIndexPath:indexPath];
		if ([cell isKindOfClass:[OFGameDiscoveryImageHyperlinkCell class]])
		{
			OFGameDiscoveryImageHyperlinkCell* hyper = (OFGameDiscoveryImageHyperlinkCell*)cell;
			[hyper onCellWasClicked:self.navigationController];	
		}
	}
	else if([cellResource isKindOfClass:[OFPlayedGame class]])
	{
		OFPlayedGame* playedGameResource = (OFPlayedGame*)cellResource;

		if ([playedGameResource isOwnedByLocalUser])
		{
			[OFGameProfileController showGameProfileWithClientApplicationId:playedGameResource.clientApplicationId compareToUser:[self getPageContextUser]];
		}		
		else if (playedGameResource.iconUrl != nil)
		{
			appPurchaseIdToPush = playedGameResource.clientApplicationId;		
		}
	}
	else if([cellResource isKindOfClass:[OFGameDiscoveryNewsItem class]])
	{
		OFGameDiscoveryNewsItemController* newsItemController = [[OFGameDiscoveryNewsItemController new] autorelease];
		newsItemController.newsItem = (OFGameDiscoveryNewsItem*)cellResource;
		nextController = newsItemController;
	}
	else if([cellResource isKindOfClass:[OFGameDiscoveryCategory class]])
	{
		OFGameDiscoveryCategory* category = (OFGameDiscoveryCategory*)cellResource;
		
		if([category.targetDiscoveryActionName isEqualToString:@"what_are_my_friends_playing_find_friends"])
		{
			OFImportFriendsController* friendsController = (OFImportFriendsController*)OFControllerLoader::load(@"ImportFriends", nil);
			nextController = friendsController;	
			reloadWhenShownNext = true;
		}
		else
		{
			categoryToPush = category.targetDiscoveryActionName;
			categoryPageDisplayTitle = category.targetDiscoveryPageTitle;		
		}
	}
	
	if(nextController == nil)
	{
		if(appPurchaseIdToPush != nil)
		{
			nextController = [OFApplicationDescriptionController applicationDescriptionForId:appPurchaseIdToPush appBannerPlacement:displayContext];
		}
		else if(categoryToPush != nil)
		{
			OFPlayedGameController* gameList = (OFPlayedGameController*)OFControllerLoader::load(@"PlayedGame", nil);
			[gameList setTargetDiscoveryPageName:categoryToPush];
			gameList.navigationItem.title = categoryPageDisplayTitle;
			nextController = gameList;
		}
	}

	if (nextController)
	{
		[self.navigationController pushViewController:nextController animated:YES];
	}
	else
	{
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (BOOL)localUsersPage
{
	return [[self getPageContextUser] isLocalUser];
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	[self reloadDataFromServer];
}

- (void)onLeadingCellWasLoaded:(OFTableCellHelper*)leadingCell forSection:(OFTableSectionDescription*)section
{
	if ([leadingCell isKindOfClass:[OFDefaultLeadingCell class]])
	{
		OFDefaultLeadingCell* cell = (OFDefaultLeadingCell*)leadingCell;

		OFUser* userContext = [self getPageContextUser];
		[cell populateRightIconsAsComparison:userContext];
		if (scope == kPlayedGameScopeMyGames)
		{
			cell.headerLabel.text = [self localUsersPage] ? @"My Games" : [NSString stringWithFormat:@"%@'s Games", userContext.name];
		}
		else if (scope == kPlayedGameScopeFriendsGames)
		{
			cell.headerLabel.text = @"Friends' Games";
		}
	}
}

- (NSString*)getLeadingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	if(scope != kPlayedGameScopeTargetServiceIndex)
	{
		return @"DefaultLeading";	
	}
	
	return nil;
}

- (void)dealloc
{
	OFSafeRelease(headerBannerResource);
	self.targetDiscoveryPageName = nil;

	[super dealloc];
}

- (void)setTargetDiscoveryPageName:(NSString*)pageName
{
	targetDiscoveryPageName = pageName;
	scope = kPlayedGameScopeTargetServiceIndex;
	
	if([pageName isEqualToString:@"feint_five"])
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Shuffle" style:UIBarButtonItemStylePlain target:self action:@selector(feintFiveShuffle)] autorelease];
	}
}

- (void)feintFiveShuffle
{
	[self reloadDataFromServer];
}

- (bool)isBannerAvailableNow
{
	return headerBannerResource != nil;
}

- (NSString*)bannerCellControllerName;
{
	return @"GameDiscoveryImageHyperlink";
}

- (OFResource*)getBannerResource
{
	return headerBannerResource;
}

- (void)onBeforeResourcesProcessed:(OFPaginatedSeries*)resources
{
	OFTableSectionDescription* bannerSection = nil;
	for(id currentResource in resources.objects)
	{
		if([currentResource isKindOfClass:[OFTableSectionDescription class]])
		{
			OFTableSectionDescription* currentSection = (OFTableSectionDescription*)currentResource;
			if([currentSection.identifier isEqualToString:@"banner_frame_content"])
			{
				bannerSection = [[currentSection retain] autorelease];
				[resources.objects removeObject:currentSection];
				break;
			}		
		}
	}
	
	headerBannerResource = [[bannerSection.page.objects objectAtIndex:0] retain];	
	[(OFFramedNavigationController*)self.navigationController refreshBanner];
}

- (void)onBannerClicked
{
	[self onCellWasClicked:headerBannerResource indexPathInTable:nil];
}

@end
