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
#import "OFChallengeListController.h"
#import "OFResourceControllerMap.h"
#import "OFControllerLoader.h"
#import "OFProfileController.h"
#import "OFChallengeService+Private.h"
#import "OFChallengeDefinitionService.h"
#import "OFChallenge.h"
#import "OFChallengeToUser.h"
#import "OFChallengeDefinitionStats.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeDetailController.h"
#import "OFPlayedGame.h"
#import "OFUserGameStat.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OFUser.h"
#import "OFApplicationDescriptionController.h"
#import "OFDelegate.h"
#import "OFGameProfileController.h"
#import "OFTabbedPageHeaderController.h"
#import "OFTableSectionDescription.h"
#import "OFFramedNavigationController.h"
#import "OFViewHelper.h"
#import "OFTableSequenceControllerHelper+ViewDelegate.h"


namespace 
{
	const NSString* kPendingTabName = @"Pending";
	const NSString* kHistoryTabName = @"History";
}

@implementation OFChallengeListController

@synthesize clientApplicationId, listType, challengeDefinitionStats;

- (void)dealloc
{
	self.clientApplicationId = nil;
	self.challengeDefinitionStats = nil;
	[super dealloc];
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFChallengeToUser class], @"ChallengeToUser");
	resourceMap->addResource([OFChallenge class], @"ChallengeSent");
	resourceMap->addResource([OFChallengeDefinitionStats class], @"ChallengeDefinitionStats");
}

- (OFService*)getService
{
	return [OFChallengeService sharedInstance];
}

- (OFUser*)getComparisonUser
{
	OFFramedNavigationController* framedNavController = (OFFramedNavigationController*)self.navigationController;
	return framedNavController.comparisonUser;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if (listType == kChallengeListDefinitionStats)
	{
		if ([cellResource isKindOfClass:[OFChallengeDefinitionStats class]])
		{
			OFChallengeDefinitionStats* stats = (OFChallengeDefinitionStats*)cellResource;
			OFChallengeListController* historyController = (OFChallengeListController*)OFControllerLoader::load(@"ChallengeList");
			historyController.clientApplicationId = self.clientApplicationId;
			historyController.listType = kChallengeListHistory;
			historyController.challengeDefinitionStats = stats;
			[self.navigationController pushViewController:historyController animated:YES];
		}
	}
	else
	{
		OFChallengeDetailController* detailController = (OFChallengeDetailController*)OFControllerLoader::load(@"ChallengeDetail");
		detailController.clientApplicationId = clientApplicationId;
		if(listType == kChallengeListPending)
		{	
			detailController.challengeId = ((OFChallengeToUser*)cellResource).challenge.resourceId;
			detailController.list = kChallengeListPending;
			detailController.challengeCompleted = NO;
			[[self navigationController] pushViewController:detailController animated:YES];
		}
		else if(listType == kChallengeListHistory)
		{
			if ([cellResource isKindOfClass:[OFChallengeToUser class]])
			{
				OFChallengeToUser* challengeToUser = (OFChallengeToUser*)cellResource;
				detailController.challengeId = challengeToUser.challenge.resourceId;
				detailController.list = kChallengeListHistory;
				detailController.challengeCompleted = challengeToUser.isCompleted;
				[[self navigationController] pushViewController:detailController animated:YES];
			}
			else if ([cellResource isKindOfClass:[OFChallenge class]])
			{
				detailController.challengeId = ((OFChallenge*)cellResource).resourceId;
				detailController.list = kChallengeListHistory;
				detailController.challengeCompleted = NO;
				[[self navigationController] pushViewController:detailController animated:YES];
			}
			
		}
		else
		{
			OFLog(@"OFChallengeList selected segement does not exist-This should never happen");
		}
	}
}

- (NSString*)getTableHeaderControllerName
{
	return (listType == kChallengeListHistory) ? nil : @"TabbedPageHeader";
}

- (void)onPendingSelected
{
	listType = kChallengeListPending;
	[self reloadDataFromServer];
}

- (void)onHistorySelected
{
	listType = kChallengeListDefinitionStats;
	[self reloadDataFromServer];
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFTabbedPageHeaderController* header = (OFTabbedPageHeaderController*)tableHeader;
	header.callbackTarget = self;
	[header addTab:kPendingTabName andSelectedCallback:@selector(onPendingSelected)];
	[header addTab:kHistoryTabName andSelectedCallback:@selector(onHistorySelected)];
}

- (NSString*)getNoDataFoundMessage
{
	OFUser* comparisonUser = [self getComparisonUser];
	if (comparisonUser)
	{
		if (listType == kChallengeListPending)
		{
			return [NSString stringWithFormat:@"There are no pending challenges between you and %@.", comparisonUser.name];
		}
		else if (listType == kChallengeListHistory)
		{
			return [NSString stringWithFormat:@"There have not been any challenges between you and %@.", comparisonUser.name];
		}
		else
		{
			return [NSString stringWithFormat:@"There are no available challenge types for %@ at this moment.", [OpenFeint applicationDisplayName]];
		}
	}
	else
	{
		if (clientApplicationId && ![clientApplicationId isEqualToString:[OpenFeint clientApplicationId]])
		{
			if (listType == kChallengeListPending)
			{
				return @"You have no pending challenges for this game.";
			}
			else
			{
				return @"You have not sent or received any challenges of this type.";
			}
		}
		else
		{
			return [NSString stringWithFormat:@"You don't have any pending challenges for %@.", [OpenFeint applicationDisplayName]];
		}
	}
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	NSString* comparisonUserId = [self getComparisonUser].resourceId;
	if(listType == kChallengeListPending)
	{
		[OFChallengeService getPendingChallengesForLocalUserAndApplication:clientApplicationId
																 pageIndex:oneBasedPageNumber
														  comparedToUserId:comparisonUserId
																 onSuccess:success 
																 onFailure:failure];
	}
	else if(listType == kChallengeListDefinitionStats)
	{
		[OFChallengeDefinitionService getChallengeDefinitionStatsForLocalUser:oneBasedPageNumber
														  clientApplicationId:clientApplicationId
															 comparedToUserId:comparisonUserId
																	onSuccess:success
																	onFailure:failure];
	}
	else if(listType == kChallengeListHistory)
	{
		[OFChallengeService getChallengeHistoryForType:challengeDefinitionStats.resourceId
								   clientApplicationId:clientApplicationId
											 pageIndex:oneBasedPageNumber
									  comparedToUserId:comparisonUserId
											 onSuccess:success
											 onFailure:failure];
	}
	else
	{
		OFLog(@"OFChallengeList selected segment does not exist-This should never happen");
	}
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (UIView*)createPlainTableSectionHeader:(NSInteger)sectionIndex
{
	if (listType == kChallengeListDefinitionStats){
		if ((unsigned int)sectionIndex < [mSections count])
		{
			OFTableSectionDescription* tableDescription = (OFTableSectionDescription*)[mSections objectAtIndex:sectionIndex];
			UIView* headerView = OFControllerLoader::loadView(@"ChallengeListSectionHeaderView");
			UILabel* label = (UILabel*)OFViewHelper::findViewByTag(headerView, 1);
			label.text = tableDescription.title;
			return headerView;
		}
		else
		{
			return nil;
		}
	}else{
		//return nil;
		return [super createPlainTableSectionHeader:sectionIndex];
	}
}

- (void)onSectionsCreated:(NSMutableArray*)sections
{
	if ([sections count] == 1)
	{
		OFTableSectionDescription* firstSection = [sections objectAtIndex:0];
		if(listType == kChallengeListPending)
		{
			firstSection.title = @"Pending Challenges";
		}
		else if(listType == kChallengeListDefinitionStats)
		{
			firstSection.title = @"Challenge Types";
		}
		else if(listType == kChallengeListHistory)
		{
			firstSection.title = @"Challenge History";
		}
	}
}

#pragma mark Comparison
		
- (BOOL)supportsComparison;
{
	return YES;
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	[self reloadDataFromServer];	
}


@end
