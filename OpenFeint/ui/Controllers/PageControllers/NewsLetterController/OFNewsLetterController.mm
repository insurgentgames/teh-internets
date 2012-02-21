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
#import "OFNewsLetterController.h"
#import "OFUserSettingService.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"
#import "OFControllerLoader.h"
#import "OFHttpCredentialsCreateController.h"
#import "OFPaginatedSeries.h"
#import "OFActionRequest.h"
#import "OFGameProfilePageInfo.h"
#import "OFFramedNavigationController.h"
#import "OpenFeint+Private.h"

@implementation OFNewsLetterController

@synthesize summaryLabel, descriptionLabel, subscriptionSwitch;

- (void) dealloc
{
	OFSafeRelease(summaryLabel);
	OFSafeRelease(descriptionLabel);
	OFSafeRelease(subscriptionSwitch);
	[super dealloc];
}

- (NSString*)getClientApplicationId
{
	OFGameProfilePageInfo* gameProfile = [(OFFramedNavigationController*)self.navigationController currentGameContext];
	return gameProfile.resourceId;
}

- (void)setSubscriptionState:(BOOL)subscribe
{
	[self showLoadingScreen];
	[subscriptionSwitch setOn:subscribe];
	[OFUserSettingService setSubscribeToDeveloperNewsLetter:subscriptionSwitch.on 
										clientApplicationId:[self getClientApplicationId]
												  onSuccess:OFDelegate(self, @selector(onSubscriptionChanged:)) 
												  onFailure:OFDelegate(self, @selector(onSubscriptionFailedToChange))];
}

- (IBAction)subscriptionChanged
{
	
	if (subscriptionSwitch.on && ![OpenFeint loggedInUserHasHttpBasicCredential])
	{
		[subscriptionSwitch setOn:NO];
		UIActionSheet* actionSheet = [[[UIActionSheet alloc] initWithTitle:@"To subscribe you must first enable account retrieval with an e-mail and password." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Enable Account Retrieval" otherButtonTitles:nil] autorelease];
		[actionSheet showInView:self.view];
	}
	else
	{
		[self setSubscriptionState:subscriptionSwitch.on];
	}
}
	
- (void)onSubscriptionChanged:(OFPaginatedSeries*)resources
{
	[self hideLoadingScreen];
}

- (void)onSubscriptionFailedToChange
{
	[self hideLoadingScreen];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.destructiveButtonIndex)
	{
		securingAccount = YES;
		OFHttpCredentialsCreateController* httpController = (OFHttpCredentialsCreateController*)OFControllerLoader::load(@"HttpCredentialsCreate");
		httpController.addingAdditionalCredential = YES;
		[self.navigationController pushViewController:httpController animated:YES];
		
	}
	else
	{
		securingAccount = NO;
	}
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (![OpenFeint isInLandscapeMode])
		self.summaryLabel.text = @"Subscribe to new updates!";
	self.descriptionLabel.text = [NSString stringWithFormat:
		@"Subscribe to email updates from the developer of %@.  Don't worry, your email address is stored securely and won't be shared with any third parties.",
		[OpenFeint applicationDisplayName]];
}

- (void)doServerAction
{
	[OFUserSettingService getSubscribingToDeveloperNewsLetter:[self getClientApplicationId] onSuccess:OFDelegate(self, @selector(onRetrievedSetting:)) onFailure:OFDelegate(self, @selector(onFailedRetrievingSetting))];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (securingAccount)
	{
		if ([OpenFeint loggedInUserHasHttpBasicCredential])
		{
			[self setSubscriptionState:YES];
		}
	}
	else
	{
		[self showLoadingScreen];
		[self doServerAction];
	}
	
	securingAccount = NO;
}

- (void)onRetrievedSetting:(OFPaginatedSeries*)resources
{
	if ([resources count] == 0)
	{
		[subscriptionSwitch setOn:NO];
	}
	else
	{
		[subscriptionSwitch setOn:YES];
	}
	
	[self hideLoadingScreen];
}

- (void)onFailedRetrievingSetting
{
	[self hideLoadingScreen];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}
@end
