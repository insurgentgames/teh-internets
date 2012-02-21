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

#import "OFFriendImporter.h"
#import "OFFormControllerHelper+Submit.h"
#import "OFControllerLoader.h"
#import "OFResourceControllerMap.h"
#import "OFDeadEndErrorController.h"
#import "OFUsersCredential.h"
#import "OFUsersCredentialService.h"
#import "OFAccountSetupBaseController.h"
#import "OFViewHelper.h"
#import "OFTableSectionDescription.h"
#import "OFShowMessageAndReturnController.h"
#import "UIButton+OpenFeint.h"

@implementation OFFriendImporter

- (void)pushCompleteControllerWithMessage:(NSString*)message andTitle:(NSString*)controllerTitle
{
	OFShowMessageAndReturnController* completeController = (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
	completeController.messageLabel.text = message;
	completeController.messageTitleLabel.text = @"Find Friends";
	completeController.title = controllerTitle;
	[completeController.continueButton setTitleForAllStates:@"OK"];
	if ([mController.navigationController.viewControllers count] > 1)
	{
		completeController.controllerToPopTo = [mController.navigationController.viewControllers objectAtIndex:[mController.navigationController.viewControllers count] - 2];
	}	
	[mController.navigationController pushViewController:completeController animated:YES];
}

- (void)importFriendsSucceeded
{
	if (!mController)
	{
		return;
	}
	
	if ([mController respondsToSelector:@selector(hideLoadingScreen)])
		[mController performSelector:@selector(hideLoadingScreen)];
	[self pushCompleteControllerWithMessage:mImportCompleteMessage.get() andTitle:@"Finding Friends"];
}

- (void)importFriendsFailed
{
	if (!mController)
	{
		return;
	}
	
	if ([mController respondsToSelector:@selector(hideLoadingScreen)])
		[mController performSelector:@selector(hideLoadingScreen)];
	[self pushCompleteControllerWithMessage:@"An error occured when trying to import your friends. Please try again later." andTitle:@"Error"];
}

- (void)onUsersCredentialsDownloaded:(OFPaginatedSeries*)downloadData
{
	if (!mController)
	{
		return;
	}
	
	bool linked = false;
	for (OFTableSectionDescription* section in downloadData.objects)
	{
		for (OFUsersCredential* credential in section.page.objects)
		{
			if ([credential.credentialType isEqualToString:mCredentialType.get()])
			{
				linked = true;
				break;
			}
		}
	}
	if (linked)
	{															  
		mImportCompleteMessage = [NSString stringWithFormat:@"Allow some time for us to find your %@ friends with OpenFeint. Any matches will appear in the friends tab.",
								  [OFUsersCredential getDisplayNameForCredentialType:mCredentialType.get()]];
		
		OFDelegate success(self, @selector(importFriendsSucceeded));
		OFDelegate failure(self, @selector(importFriendsFailed));
		[OFUsersCredentialService importFriendsFromCredentialType:mCredentialType.get() onSuccess:success onFailure:failure];
	}
	else
	{
		if ([mController respondsToSelector:@selector(hideLoadingScreen)])
			[mController performSelector:@selector(hideLoadingScreen)];
		OFAccountSetupBaseController* linkCredentialController = (OFAccountSetupBaseController*)OFControllerLoader::load(mLinkCredentialControllerName.get());
		if (linkCredentialController)
		{
			linkCredentialController.addingAdditionalCredential = YES;
			[mController.navigationController pushViewController:linkCredentialController animated:YES];
		}
	}
}

- (void)importFromSocialNetwork
{
	if ([mController respondsToSelector:@selector(showLoadingScreen)])
		[mController performSelector:@selector(showLoadingScreen)];

	OFDelegate success(self, @selector(onUsersCredentialsDownloaded:));
	OFDelegate failure(self, @selector(importFriendsFailed));
	[OFUsersCredentialService getIndexOnSuccess:success onFailure:failure onlyIncludeLinkedCredentials:YES];
}

+ (id)friendImporterWithController:(UIViewController*)controller
{
	OFFriendImporter* ret = [[self new] autorelease];
	ret->mController = controller;
	return ret;
}

- (IBAction)importFromTwitter
{
	mCredentialType = @"twitter";
	mLinkCredentialControllerName = @"TwitterAccountLogin";
	[self importFromSocialNetwork];
}

- (IBAction)importFromFacebook
{
	mCredentialType = @"fbconnect";
	mLinkCredentialControllerName = @"FacebookAccountLogin";
	[self importFromSocialNetwork];
}

- (IBAction)findByName
{
	UIViewController* controller = (UIViewController*)OFControllerLoader::load(@"FindUser");
	controller.title = @"Find User";
	[mController.navigationController pushViewController:controller animated:YES];
}

- (void)dealloc
{
	mController = nil;
	[super dealloc];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)controllerDealloced
{
	mController = nil;
}

@end

