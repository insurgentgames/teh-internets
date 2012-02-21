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
#import "OFHighScoreHeaderController.h"
#import "OFHighScoreController.h"
#import "OFViewHelper.h"
#import "OpenFeint+Private.h"
#import "OFReachability.h"

static NSString* kGlobalSegmentName  = @"Global";
static NSString* kFriendsSegmentName = @"Friends";
static NSString* kLocalSegmentName = @"Local";
static NSString* kNearMeSegmentName = @"Near Me";

@implementation OFHighScoreHeaderController

@synthesize highScoreController;

- (void)dealloc
{
	OFSafeRelease(tabBar);
	self.highScoreController = nil;
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.frame = CGRectMake(0.0f, 0.0f, [OpenFeint getDashboardBounds].size.width, tabBar.frame.size.height);
	
	if ([OpenFeint isOnline])
	{
		[tabBar addSegmentNamed:kGlobalSegmentName  activeImage:nil inactiveImage:nil disabledImage:nil];
		[tabBar addSegmentNamed:kFriendsSegmentName activeImage:nil inactiveImage:nil disabledImage:nil];
		[tabBar addSegmentNamed:kNearMeSegmentName activeImage:nil inactiveImage:nil disabledImage:nil];
		[tabBar addSegmentNamed:kLocalSegmentName activeImage:nil inactiveImage:nil disabledImage:nil];
		[tabBar showTabNamed:kFriendsSegmentName notifyDelegate:NO];
	} else {
		[tabBar addSegmentNamed:kLocalSegmentName activeImage:nil inactiveImage:nil disabledImage:nil];
		[tabBar showTabNamed:kLocalSegmentName notifyDelegate:NO];
	}
}

- (void)tabBar:(OFTabBar*)tabBar didSelectTabNamed:(NSString*)tabName
{
	if ([tabName isEqualToString:kGlobalSegmentName])
	{
		[highScoreController showGlobalLeaderboard];
	}
	else if ([tabName isEqualToString:kFriendsSegmentName])
	{
		[highScoreController showFriendsLeaderboard];
	}
	else if ([tabName isEqualToString:kNearMeSegmentName])
	{
		[highScoreController showLocationLeaderboard];
	}
	else if ([tabName isEqualToString:kLocalSegmentName])
	{
		[highScoreController showLocalLeaderboard];
	}
}

@end