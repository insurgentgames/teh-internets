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
#import "OFSendChallengeController.h"
#import "OFResourceControllerMap.h"
#import "OFFriendsService.h"
#import "OFUser.h"
#import "OFSelectableUserCell.h"
#import "OFTableSectionDescription.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"
#import "OFControllerLoader.h"
#import "OFUsersCredential.h"
#import "OFFullScreenImportFriendsMessage.h"
#import "OFChallengeDelegate.h"
#import "OFChallengeService+Private.h"
#import "OFChallenge.h"
#import "OFCompletedChallengeHeaderController.h"
#import "OFSendChallengeHeaderController.h"
#import "OFCompletedChallengeHeaderController.h"
#import "OFDefaultTextField.h"
#import "OFReachability.h"
#import "OFTableControllerHelper+Overridables.h"
#import "OFTableSequenceControllerHelper+ViewDelegate.h"
#import "OFTableSequenceControllerHelper+Overridables.h"

@interface OFSendChallengeController ()

- (void) _refreshData;
- (void) _refreshDataNow;

@end

@implementation OFSendChallengeController

@synthesize challengeDefinitionId, challengeText, challengeData, resultData, hiddenText, isCompleted, userChallenge;

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUser class], @"SelectableUser");
}

- (OFService*)getService
{
	return [OFFriendsService sharedInstance];
}

- (void)doIndexActionWithPage:(NSUInteger)pageIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	NSString* instigatingChallengerId = nil;
	if (isCompleted && ![userChallenge.challenge.challenger isLocalUser])
	{
		instigatingChallengerId = userChallenge.challenge.challenger.resourceId;
	}
	[OFChallengeService getUsersToChallenge:(NSString*)instigatingChallengerId pageIndex:pageIndex onSuccess:success onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	[self doIndexActionWithPage:1 onSuccess:success onFailure:failure];
    stallNextRefresh = YES;
}

- (UIViewController*)getNoDataFoundViewController
{
    OFFullScreenImportFriendsMessage* noDataController = (OFFullScreenImportFriendsMessage*)OFControllerLoader::load(@"FullscreenImportFriendsMessage");
    noDataController.owner = self;
    return noDataController;
}

- (NSString*)getNoDataFoundMessage
{
	return [NSString stringWithFormat:@"You have no friends with %@.", [OpenFeint applicationDisplayName]];
}

- (bool)usePlainTableSectionHeaders
{
	return true;
}

- (NSString*)getTableHeaderControllerName
{
	if(isCompleted)
	{
		return @"CompletedChallengeHeader";
	}
	else
	{
		return @"SendChallengeHeader";
	}
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	if(isCompleted)
	{
		[(OFCompletedChallengeHeaderController*)tableHeader setChallenge:self.userChallenge];
	}
}

- (void)onSectionsCreated:(NSMutableArray*)sections
{
	if (!isCompleted && [sections count] == 1)
	{
		OFTableSectionDescription* firstSection = [sections objectAtIndex:0];
		firstSection.title = @"Friends To Challenge";
	}
}

- (void)toggleSelectionOfUser:(OFUser*)user
{
	if (mSelectedUsers == nil)
	{
		mSelectedUsers = [NSMutableArray new];
	}
	
	NSIndexPath* indexPath = [self getFirstIndexPathForResource:user];
	if (!indexPath)
	{
		return;
	}
	OFSelectableUserCell* userCell = (OFSelectableUserCell*)[self.tableView cellForRowAtIndexPath:indexPath];
	OFUser* userInTable = (OFUser*)[self getResourceAtIndexPath:indexPath]; 
	if (userInTable)
	{
		if ([mSelectedUsers containsObject:userInTable])
		{
			userCell.checked = NO;
			[mSelectedUsers removeObject:userInTable];
		}
		else
		{
			userCell.checked = YES;
			[mSelectedUsers addObject:userInTable];
		}
	}
	
	[userCell setSelected:NO animated:YES];
}

- (void)cell:(OFUserCell*)cell wasAssignedUser:(OFUser*)user
{
	if ([cell isKindOfClass:[OFSelectableUserCell class]])
	{
		[(OFSelectableUserCell*)cell setChecked:[mSelectedUsers containsObject:user]];
	}
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFUser class]])
	{
		UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if ([cell isKindOfClass:[OFSelectableUserCell class]])
		{	
			[self toggleSelectionOfUser:(OFUser*)cellResource];
		}
	}
}

- (void)showNoFriendsSelectedMessage
{
	[[[[UIAlertView alloc] initWithTitle:@"No Friends Selected" 
								 message:@"You must select at least one friend to challenge." 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
}

- (void)showNoConnectionMessage
{
	[[[[UIAlertView alloc] initWithTitle:@"No internet connection" 
								 message:@"You must have an internet connection to submit challenges." 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
}

- (void)showSubmitFailedMessage
{
	[[[[UIAlertView alloc] initWithTitle:@"An error occurred" 
								 message:@"Your challenge was not submitted. Please try again." 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
}

- (NSString*)getUserMessage:(UITextField*)textField
{
	return (textField.text && ![textField.text isEqualToString:@""]) ? textField.text : textField.placeholder;
}

- (IBAction)submitChallenge
{
	if ([mSelectedUsers count] == 0)
	{
		[self showNoFriendsSelectedMessage];
	}
	else if (!OFReachability::Instance()->isGameServerReachable())
	{
		[self showNoConnectionMessage];
	}
	else
	{
		NSMutableArray* userIds =  [NSMutableArray arrayWithCapacity:[mSelectedUsers count]];
		for (OFUser* user in mSelectedUsers)
		{
			[userIds addObject:user.resourceId];
		}
		
		OFDelegate success(self, @selector(challengeSubmittedSuccess));
		OFDelegate failure(self, @selector(challengeSubmittedFailure));

		[self showLoadingScreen];
		OFSendChallengeHeaderController* header = (OFSendChallengeHeaderController*)mTableHeaderController;
		[OFChallengeService sendChallenge:self.challengeDefinitionId
							challengeText:challengeText
							challengeData:challengeData
							  userMessage:[self getUserMessage:header.userMessageTextField]
							   hiddenText:hiddenText
								  toUsers:userIds
					inResponseToChallenge:nil
								onSuccess:success
								onFailure:failure];
	}
}

- (IBAction)submitChallengeBack
{
	if ([mSelectedUsers count] == 0)
	{
		[self showNoFriendsSelectedMessage];
	}
	else if (!OFReachability::Instance()->isGameServerReachable())
	{
		[self showNoConnectionMessage];
	}
	else
	{
		NSMutableArray* userIds =  [NSMutableArray arrayWithCapacity:[mSelectedUsers count]];
		for (OFUser* user in mSelectedUsers)
		{
			[userIds addObject:user.resourceId];
		}
		
		[self showLoadingScreen];
		OFDelegate success(self, @selector(challengeSubmittedSuccess));
		OFDelegate failure(self, @selector(challengeSubmittedFailure));
		
		OFCompletedChallengeHeaderController* header = (OFCompletedChallengeHeaderController*)mTableHeaderController;
		[OFChallengeService sendChallenge:self.challengeDefinitionId
							challengeText:challengeText
							challengeData:self.resultData
							  userMessage:[self getUserMessage:header.userMessageTextField]
							   hiddenText:hiddenText
								  toUsers:userIds
					inResponseToChallenge:self.userChallenge.resourceId
								onSuccess:success
								onFailure:failure];
	}
	
}

- (IBAction)tryChallengeAgain
{
	id<OFChallengeDelegate>delegate = [OpenFeint getChallengeDelegate];
	[OpenFeint dismissDashboard];
	[delegate userRestartedChallenge];
}

- (IBAction)cancel
{
	[OpenFeint dismissDashboard];
	if (rechallenge)
	{
		OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], completedChallengeScreenClosed);
	}
	else
	{
		OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], sendChallengeScreenClosed);
	}
}

- (void)challengeSubmittedSuccess
{
	[self hideLoadingScreen];
	
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], userSentChallenges);
	[self cancel];
}

- (void)challengeSubmittedFailure
{
	[self showSubmitFailedMessage];
	[self hideLoadingScreen];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (BOOL)shouldShowNavBar
{
	return YES;
}

- (void) _refreshData
{
    if (stallNextRefresh)
    {
        [self showLoadingScreen];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(_refreshDataNow) userInfo:nil repeats:NO];
    }
    else
    {
        [self _refreshDataNow];
    }
}

- (void) _refreshDataNow
{
    [super _refreshData];
}


- (void)dealloc
{
	self.challengeDefinitionId = nil;
	self.challengeText = nil;
	self.challengeData = nil;
	self.hiddenText = nil;
	OFSafeRelease(mSelectedUsers);
	[super dealloc];
}

@end

