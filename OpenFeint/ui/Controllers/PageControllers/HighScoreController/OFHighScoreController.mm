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
#import "OFHighScoreController.h"
#import "OFResourceControllerMap.h"
#import "OFHighScore.h"
#import "OFHighScoreService.h"
#import "OFLeaderboard.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFUser.h"
#import "OFProfileController.h"
#import "OFControllerLoader.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OFTabbedPageHeaderController.h"
#import "OFDefaultLeadingCell.h"
#import "OFTableSectionDescription.h"
#import "OFGameProfilePageInfo.h"
#import "OpenFeint+UserOptions.h"
#import "OFPlainMessageTrailingCell.h"
#import "OFImageLoader.h"
#import "OFHighScoreMapViewController.h"

@implementation OFHighScoreController

@synthesize leaderboard;
@synthesize noDataFoundMessage;
@synthesize gameProfileInfo;

- (void)_willShowGlobalLeaderboardTab
{
	friendsOnly = NO;
	self.noDataFoundMessage = [NSString stringWithFormat:@"No one has posted high scores for %@ yet.", leaderboard.name];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = leaderboard.name;
	
	[self _willShowGlobalLeaderboardTab];

	if (![OpenFeint isOnline])
	{
		self.noDataFoundMessage = [NSString stringWithFormat:@"All of your high scores for %@ will show up here. You have not posted any yet.", leaderboard.name];
	}
}

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFHighScore class], @"HighScore");
}

- (OFService*)getService
{
	return [OFHighScoreService sharedInstance];
}

- (void)showGlobalLeaderboard
{
	local = NO;
	geolocation = NO;
	
	[self _willShowGlobalLeaderboardTab];
	[self showLoadingScreen];
	[self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
}

- (void)showLocationLeaderboard
{
	OFUserDistanceUnitType unit = [OpenFeint userDistanceUnit];
	
	if (unit == kDistanceUnitNotAllowed || unit == kDistanceUnitNotDefined)
	{
		// Clear out data from previously shown tab.
		[self _onDataLoaded:nil isIncremental:NO];
		
		shareLocationController = [(OFShareLocationController*)OFControllerLoader::load(@"ShareLocation") retain];
		shareLocationController.delegate = self;
		[super _displayEmptyDataSetView:shareLocationController andMessage:nil];
	}
	else
	{
		geolocation = YES;
		friendsOnly = NO;
		local = NO;
		if ([OpenFeint getUserLocation])
		{
			self.noDataFoundMessage = [NSString stringWithFormat:@"No players within %@ have posted a high score for %@.", (unit == kDistanceUnitMiles ? @"100 miles" : @"160 kms"), leaderboard.name];
		}
		else
		{
			self.noDataFoundMessage = [NSString stringWithFormat:@"Unable to determine your location."];
		}

		OFDelegate successDelagate = [self getOnSuccessDelegate];
		[self showLoadingScreen];
		[self doIndexActionWithPageForLocation:nil radius:0 pageIndex:1 onSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
	}
}

- (void)showFriendsLeaderboard
{
	friendsOnly = YES;
	geolocation = NO;

	local = NO;
	self.noDataFoundMessage = [NSString stringWithFormat:@"None of your friends have posted high scores for %@.", leaderboard.name];
	[self showLoadingScreen];
	[self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
}

- (void)showLocalLeaderboard
{
	friendsOnly = NO;
	geolocation = NO;

	local = YES;
	
	if ([self getPageComparisonUser])
	{
		self.noDataFoundMessage = [NSString stringWithFormat:@"Personal highscores for %@ are stored on your device and can not be compared with other users.", leaderboard.name];
		[self getOnSuccessDelegate].invoke(nil);
	}
	else if (gameProfileInfo.resourceId && ![gameProfileInfo.resourceId isEqualToString:[OpenFeint localGameProfileInfo].resourceId])
	{
		self.noDataFoundMessage = [NSString stringWithFormat:@"Personal highscores for %@ are stored on your device and can only be viewed from within %@.", leaderboard.name, gameProfileInfo.name];
		[self getOnSuccessDelegate].invoke(nil);
	}
	else
	{
		self.noDataFoundMessage = [NSString stringWithFormat:@"All of your high scores for %@ will show up here. You have not posted any yet.", leaderboard.name];
		[self showLoadingScreen];
		[OFHighScoreService getLocalHighScores:leaderboard.resourceId onSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];
	}
}

- (NSString*)getTableHeaderControllerName
{
	return @"TabbedPageHeader";
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	OFTabbedPageHeaderController* header = (OFTabbedPageHeaderController*)tableHeader;
	header.callbackTarget = self;
	if( [OpenFeint isOnline] )
	{
		[header addTab:@"Global" andSelectedCallback:@selector(showGlobalLeaderboard)];
		[header addTab:@"Friends" andSelectedCallback:@selector(showFriendsLeaderboard)];
		// 2 spaces for Portrait
		[header addTab:@"  Near Me" andSelectedCallback:@selector(showLocationLeaderboard)];
	} else {
	    [header addTab:@"My Scores" andSelectedCallback:@selector(showLocalLeaderboard)];
	}
}

#ifdef __IPHONE_3_0
- (NSString*)getLeadingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	NSRange subStr = [section.identifier rangeOfString:@"mapView"];
	
    if (geolocation && [OpenFeint isTargetAndSystemVersionThreeOh] && subStr.location != NSNotFound) {
        return ([OpenFeint isInLandscapeMode]) ? @"HighScoreNearMeLeadingLandscape" : @"HighScoreNearMeLeading";
    }
    return nil;
}

- (NSString*)getTrailingCellControllerNameForSection:(OFTableSectionDescription*)section
{
    if (geolocation && [OpenFeint isTargetAndSystemVersionThreeOh] && [section.identifier isEqualToString:@"mapViewNoScores"]) {
        //return @"PlainMessageTrailing";
		return @"EmptyDataSetTrailing";
    }
    return nil;
}

- (void)onTrailingCellWasLoaded:(OFTableCellHelper*)trailingCell forSection:(OFTableSectionDescription*)section
{
	OFPlainMessageTrailingCell* cell = (OFPlainMessageTrailingCell*) trailingCell;
	
	if (geolocation && [OpenFeint isTargetAndSystemVersionThreeOh] && [section.identifier isEqualToString:@"mapViewNoScores"]) 
	{
		cell.messageLabel.text = self.noDataFoundMessage;
    }
}

- (void)onTrailingCellWasClickedForSection:(OFTableSectionDescription*)section
{
	if (!(geolocation && [OpenFeint isTargetAndSystemVersionThreeOh] && [section.identifier isEqualToString:@"mapViewNoScores"]))
	{
		[super onTrailingCellWasClickedForSection:section];
	}
}

#endif

- (NSString*)getNoDataFoundMessage
{
	return noDataFoundMessage;	
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFHighScore class]] && [OpenFeint isOnline])
	{
		OFHighScore* highScoreResource = (OFHighScore*)cellResource;
		[OFProfileController showProfileForUser:highScoreResource.user];
	}
}

- (IBAction)_clickedMap
{
#ifdef __IPHONE_3_0
	OFHighScoreMapViewController* mapViewController = (OFHighScoreMapViewController*)OFControllerLoader::load(@"Mapping");
	[mapViewController setLeaderboard:leaderboard.resourceId];
	[[self navigationController] pushViewController:mapViewController animated:YES];
	[mapViewController getScores];
#endif
}

- (void)dealloc
{
	self.noDataFoundMessage = nil;
	self.leaderboard = nil;
	self.gameProfileInfo = nil;
	OFSafeRelease(importFriendsController);
	OFSafeRelease(shareLocationController);
	OFSafeRelease(tabBar);
    #ifdef __IPHONE_3_0	
	OFSafeRelease(mapButton);
	#endif
	[super dealloc];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	if ([OpenFeint isOnline])
	{
		[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
	} else {
		[OFHighScoreService getLocalHighScores:leaderboard.resourceId onSuccess:success onFailure:failure];
	}
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	if( !geolocation )
	{
	[OFHighScoreService getPage:oneBasedPageNumber 
				 forLeaderboard:leaderboard.resourceId 
			   comparedToUserId:[self getPageComparisonUser].resourceId
					friendsOnly:friendsOnly 
					   silently:NO
					  onSuccess:success 
					  onFailure:failure];
	}
	else
	{
		//CLLocation* location = [OpenFeint getUserLocation];
		[self doIndexActionWithPageForLocation:nil radius:0 pageIndex:oneBasedPageNumber onSuccess:success onFailure:failure];
	}
}

- (void)doIndexActionWithPageForLocation:(CLLocation*)origin radius:(int)radius pageIndex:(NSInteger)pageIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFHighScoreService getHighScoresFromLocation:origin
									       radius:radius
										pageIndex:pageIndex
							       forLeaderboard:leaderboard.resourceId 
									    onSuccess:success 
									    onFailure:failure];	
}

- (void)_onDataLoadedWrapper:(OFPaginatedSeries*)resources
{
	if( friendsOnly && ![OpenFeint lastLoggedInUserHadFriendsOnBootup] && [resources.objects count] < 2 )
	{
		[self hideLoadingScreen];
		[self _onDataLoaded:nil isIncremental:NO];
		importFriendsController = [(OFImportFriendsController*)OFControllerLoader::load(@"ImportFriends") retain];
	    [importFriendsController setController:(OFViewController*)self];
		[super _displayEmptyDataSetView:importFriendsController andMessage:nil];
	}
	else
	{
		[super _onDataLoadedWrapper:resources isIncremental:NO];
	}
}

 - (bool)_shouldRefresh
 {
	 if (importFriendsController)
		 return false;
	 else
		 return [super _shouldRefresh];
 }
 

#pragma mark Comparison

- (BOOL)supportsComparison
{
	return NO;
}

- (void)profileUsersChanged:(OFUser*)contextUser comparedToUser:(OFUser*)comparedToUser
{
	if (local)
	{
		[self showLocalLeaderboard];
	}
	else
	{
		if (friendsOnly)
		{
			[self showFriendsLeaderboard];
		}
		else
		{
			[self showGlobalLeaderboard];
		}
	}
}

#pragma mark OFShareLocationControllerCallback

- (void)userSharedLocation
{
	[self showLocationLeaderboard];
}

@end
