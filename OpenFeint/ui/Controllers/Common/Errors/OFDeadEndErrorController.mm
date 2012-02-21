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
#import "OFDeadEndErrorController.h"
#import "OFControllerLoader.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OFNavigationController.h"
#import "OFDefaultButton.h"

@implementation OFDeadEndErrorController

@synthesize message = mMessage;
@synthesize messageView = mMessageView;
@synthesize offlineButton = mOfflineButton;


+ (id)mustBeOnlineErrorWithMessage:(NSString*)errorMessage
{
	OFDeadEndErrorController* deadEndError = (OFDeadEndErrorController*)OFControllerLoader::load(@"MustBeOnlineError");
	deadEndError.message = [NSString stringWithFormat:errorMessage];
	return deadEndError;
}

+ (id)deadEndErrorWithMessage:(NSString*)errorMessage
{
	OFDeadEndErrorController* deadEndError = (OFDeadEndErrorController*)OFControllerLoader::load(@"DeadEndError");
	deadEndError.message = [NSString stringWithFormat:errorMessage];
	return deadEndError;
}

+ (id)deadEndErrorWithMessageAndOfflineButton:(NSString*)errorMessage
{
	OFDeadEndErrorController* deadEndError = (OFDeadEndErrorController*)OFControllerLoader::load(@"DeadEndError");
	deadEndError.message = [NSString stringWithFormat:errorMessage];
	deadEndError.offlineButton.hidden = NO;
	return deadEndError;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (self.navigationController && self.navigationController.modalViewController != nil)
	{
		[OFNavigationController addCloseButtonToViewController:self target:self action:@selector(dismiss) leftSide:NO systemItem:UIBarButtonSystemItemDone];
	}

	
	CGRect myRect = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.4f);
	self.view.frame = myRect;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = @"Error";
	mMessageView.text = mMessage;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)dismiss
{
	[OpenFeint dismissDashboard];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.offlineButton.hidden = YES;
}

- (IBAction)offlinePressed
{
	[OpenFeint switchToOfflineDashboard];
}

- (void)dealloc 
{
	self.message = nil;
	self.messageView = nil;
	self.offlineButton = nil;
    [super dealloc];
}

- (void)registerActionsNow
{
}

@end
