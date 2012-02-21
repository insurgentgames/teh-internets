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
#import "OFSelectAccountTypeController.h"
#import "OFControllerLoader.h"
#import "OFFacebookAccountController.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFUseNewOrOldAccountController.h"

@implementation OFSelectAccountTypeController

@synthesize socialNetworkNotice;
@synthesize openFeintNotice;	

@synthesize twitterButton;
@synthesize facebookButton;

- (void)_pushAccountSetupControllerFor:(NSString*)containerName
{
	OFAccountSetupBaseController* accountController = (OFAccountSetupBaseController*)OFControllerLoader::load([NSString stringWithFormat:@"%@AccountLogin", containerName]);
	[accountController setCancelDelegate:mCancelDelegate];
	[accountController setCompletionDelegate:mCompletionDelegate];
	[[self navigationController] pushViewController:accountController animated:YES];
}

- (void)_onPressedTwitter
{
	[self _pushAccountSetupControllerFor:@"Twitter"];
}

- (void)_onPressedFacebook
{
	[self _pushAccountSetupControllerFor:@"Facebook"];
}

- (void)registerActionsNow
{
	[twitterButton addTarget:self action:@selector(_onPressedTwitter) forControlEvents:UIControlEventTouchUpInside];
	[facebookButton addTarget:self action:@selector(_onPressedFacebook) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc
{
	self.socialNetworkNotice = nil;
	self.openFeintNotice = nil;
	[super dealloc];
}

@end
