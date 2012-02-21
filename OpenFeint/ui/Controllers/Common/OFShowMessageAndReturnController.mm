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

#import "OFShowMessageAndReturnController.h"
#import "OpenFeint+Private.h"

@implementation OFShowMessageAndReturnController

@synthesize messageLabel;
@synthesize messageTitleLabel;
@synthesize controllerToPopTo;
@synthesize continueButton;

-(IBAction)clickedContinue
{
	if (self.controllerToPopTo)
	{
		[self.navigationController popToViewController:self.controllerToPopTo animated:YES];
		self.controllerToPopTo = nil;
	}
	else if (self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController != nil)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)dealloc
{
	self.controllerToPopTo = nil;
	self.continueButton = nil;
	self.messageLabel = nil;
	self.messageTitleLabel = nil;
	[super dealloc];
}

@end