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
#import "OFChallengeDetailController.h"
#import "OFResourceControllerMap.h"
#import "OFChallengeDefinition.h"
#import "OFChallenge.h"
#import "OFChallengeToUser.h"
#import "OFChallengeService+Private.h"
#import "OFViewHelper.h"
#import "OFImageView.h"
#import "OpenFeint+Private.h"
#import "OFPaginatedSeries.h"
#import "OFChallengeDetailCell.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFUser.h"
#import "OFControllerLoader.h"
#import "OFTableSectionDescription.h"
#import "OFChallengeDetailHeaderController.h"
#import "OFProfileController.h"
#import "OpenFeint+Settings.h"

@implementation OFChallengeDetailController

@synthesize userChallenge, challengeId, list, challengeCompleted, clientApplicationId;

- (void)dealloc 
{
	self.userChallenge = nil;
	self.challengeId = nil;
	self.clientApplicationId = nil;
	OFSafeRelease(challengeData);
	OFSafeRelease(oneShotAlertView);
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = @"Challenge";
}


- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFChallengeToUser class], @"ChallengeDetail");
}

- (NSString*)getTableHeaderControllerName
{
	return @"ChallengeDetailHeader";
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (void)onSectionsCreated:(NSMutableArray*)sections
{
	if ([sections count] == 1)
	{
		OFTableSectionDescription* firstSection = [sections objectAtIndex:0];
		firstSection.title = @"People Who Received This Challenge";
	}
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFChallengeService getUsersWhoReceivedChallengeWithId:challengeId 
									   clientApplicationId:clientApplicationId
												 pageIndex:oneBasedPageNumber 
												 onSuccess:success 
												 onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
}

- (NSString*)getNoDataFoundMessage
{
	return [NSString stringWithFormat:@"You have not received any challenges yet. You can send challenges to your friends from within %@.", [OpenFeint applicationDisplayName]];
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFChallengeToUser class]])
	{
		OFChallengeToUser* challengeToUser = (OFChallengeToUser*)cellResource;
		[OFProfileController showProfileForUser:challengeToUser.recipient];
	}
}

- (OFService*)getService
{
	return [OFChallengeService sharedInstance];
}

- (void)startChallenge
{
	[self hideLoadingScreen];
	id<OFChallengeDelegate>delegate = [OpenFeint getChallengeDelegate];
	if([delegate respondsToSelector:@selector(userLaunchedChallenge:withChallengeData:)])
	{
		[OpenFeint dismissDashboard];
		[delegate userLaunchedChallenge:userChallenge withChallengeData:challengeData];
	}
	OFSafeRelease(challengeData);
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	alertView.delegate = nil;
	OFSafeRelease(oneShotAlertView);
	if (challengeData || ![userChallenge.challenge usesChallengeData])
	{
		[self startChallenge];
	}
}

- (IBAction)acceptChallenge:(id)sender
{
	[self showLoadingScreen];
	if (!userChallenge.challenge.challengeDefinition.multiAttempt)
	{
		OFSafeRelease(oneShotAlertView);
		oneShotAlertView = [[UIAlertView alloc] initWithTitle:@"One Shot Challenge" 
													  message:@"You only have one attempt to beat this challenge!" 
													 delegate:self 
											cancelButtonTitle:@"OK" 
											otherButtonTitles:nil];
		[oneShotAlertView show];
	}
	
	if ([userChallenge.challenge usesChallengeData])
	{
		OFDelegate success(self, @selector(_challengeDataDownloaded:));
		OFDelegate failure(self, @selector(_challengeDataDownloadFailed));
		[OFChallengeService downloadChallengeData:userChallenge.challenge.challengeDataUrl onSuccess:success onFailure:failure];
	}
	else if (!oneShotAlertView)
	{
		[self startChallenge];
	}
}

- (void)_challengeDataDownloaded:(NSData*)_challengeData
{
	challengeData = [_challengeData retain];
	if (!oneShotAlertView)
	{
		[self startChallenge];
	}
}

- (void)_challengeDataDownloadFailed
{
	[self hideLoadingScreen];
	[[[[UIAlertView alloc] initWithTitle:@"Error downloading data" 
								 message:@"Please try again." 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
}

- (void)onResourcesDownloaded:(OFPaginatedSeries*)resources
{
	NSArray* metaDataObjects = [self getMetaDataOfType:[OFChallengeToUser class]];
	if ([metaDataObjects count] > 0)
	{
		self.userChallenge = (OFChallengeToUser*)[metaDataObjects objectAtIndex:0];
	}
	else if ([resources count] > 0)
	{
		self.userChallenge = [resources objectAtIndex:0];
	}
}

- (bool)canReceiveCallbacksNow
{
	return true;
}


@end
