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
#import "OFAchievementListController.h"
#import "OFResourceControllerMap.h"
#import "OFControllerLoader.h"
#import "OFProfileController.h"
#import "OFAchievementService.h"
#import "OFAchievement.h"
#import "OFPlayedGame.h"
#import "OFUserGameStat.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OFDefaultLeadingCell.h"
#import "OFUser.h"
#import "OFApplicationDescriptionController.h"

@implementation OFAchievementListController

@synthesize applicationName, applicationId, applicationIconUrl, doesUserHaveApplication;

- (void)dealloc
{
	self.applicationName = nil;
	self.applicationId = nil;
	self.applicationIconUrl = nil;
	[super dealloc];
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFAchievement class], @"AchievementList");
}

- (OFService*)getService
{
	return [OFAchievementService sharedInstance];
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
}

- (NSString*)getNoDataFoundMessage
{
	return [NSString stringWithFormat:@"There are no achievements for %@", applicationName];
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFAchievementService getAchievementsForApplication:applicationId 
										 comparedToUser:[self getPageComparisonUser].resourceId 
												   page:oneBasedPageNumber
											  onSuccess:success 
											  onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (void)populateContextualDataFromPlayedGame:(OFPlayedGame*)playedGame
{
	self.applicationName = playedGame.name;
	self.applicationId = playedGame.clientApplicationId;
	self.applicationIconUrl = playedGame.iconUrl;
	for (OFUserGameStat* gameStat in playedGame.userGameStats)
	{
		if ([gameStat.userId isEqualToString:[OpenFeint lastLoggedInUserId]])
		{
			self.doesUserHaveApplication = gameStat.userHasGame;
		}
	}
}

- (BOOL)supportsComparison;
{
	return YES;
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	[self reloadDataFromServer];
}

- (void)onLeadingCellWasLoaded:(OFTableCellHelper*)leadingCell forSection:(OFTableSectionDescription*)section
{
	OFDefaultLeadingCell* defaultCell = (OFDefaultLeadingCell*)leadingCell;
	[defaultCell enableLeftIconViewWithImageUrl:applicationIconUrl andDefaultImage:@"OFDefaultApplicationIcon.png"];
	defaultCell.headerLabel.text = applicationName;
	[defaultCell populateRightIconsAsComparison:[self getPageComparisonUser]];
}

- (NSString*)getLeadingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	if ([self getPageComparisonUser])
		return @"DefaultLeading";
	else
		return nil;
}

- (NSString*)getTableHeaderControllerName
{
	return nil;
}

@end