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

#import "OFInputResponseOpenDashboard.h"
#import "OpenFeint+Private.h"
#import "OFControllerLoader.h"

@implementation OFInputResponseOpenDashboard

- (id)initWithTab:(NSString*)tabName andController:(UIViewController*)controller
{
	self = [super init];
	if (self != nil)
	{
		mStartingTab = tabName;
		mStartingController = [controller retain];
	}
	
	return self;
}

- (id)initWithTab:(NSString*)tabName andControllerName:(NSString*)controllerName
{
	self = [super init];
	if (self != nil)
	{
		mStartingTab = tabName;
		mControllerName = controllerName;
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(mStartingController);
	[super dealloc];
}

- (void)respondToInput
{
	if (mControllerName && !mStartingController)
	{
		mStartingController = [OFControllerLoader::load(mControllerName) retain];
	}
	NSArray* controllers = mStartingController ? [NSArray arrayWithObject:mStartingController] : nil;
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:mStartingTab andControllers:controllers];
}

@end
