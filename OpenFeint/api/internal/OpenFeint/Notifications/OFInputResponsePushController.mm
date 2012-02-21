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

#import "OFInputResponsePushController.h"
#import "OpenFeint.h"
#import "OFControllerLoader.h"

@implementation OFInputResponsePushController

- (id)initWithControllerName:(NSString*)controllerName andNavController:(UINavigationController*)navController andShowAsModal:(BOOL)showAsModal
{
	self = [super init];
	if (self)
	{
		mControllerName = [controllerName retain];
		mNavController = navController;
		mShowAsModal = showAsModal;
	}
	return self;
}

+ (OFNotificationInputResponse*)responseWithControllerName:(NSString*)controllerName 
										  andNavController:(UINavigationController*)navController
											andShowAsModal:(BOOL)showAsModal
{
	return [[[OFInputResponsePushController alloc] initWithControllerName:controllerName andNavController:navController andShowAsModal:showAsModal] autorelease];
}

- (void)respondToInput
{
	UIViewController* controllerToPush = OFControllerLoader::load(mControllerName);
	if (controllerToPush)
	{
		if (mShowAsModal)
		{
			[mNavController presentModalViewController:controllerToPush animated:YES];
		}
		else
		{
			[mNavController pushViewController:controllerToPush animated:YES];
		}
	}
}

- (void)dealloc
{
	OFSafeRelease(mControllerName);
	[super dealloc];
}
@end
