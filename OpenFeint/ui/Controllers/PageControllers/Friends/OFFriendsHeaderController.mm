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

#import "OFFriendsHeaderController.h"
#import "OFTabBar.h"
#import "OFDefaultButton.h"

@implementation OFFriendsHeaderController

- (void)setIsDisplayingForLocalUser:(BOOL)_isForLocalUser
{
	isForLocalUser = _isForLocalUser;
}

- (void)resizeView:(UIView*)parentView
{
	if (isForLocalUser)
	{
		[super resizeView:parentView];
	}
	else
	{
		float const kTabBarDropShadow = 6.f;

		self.view.frame = CGRectMake(0.f, 0.f, parentView.frame.size.width, tabBar.frame.size.height - kTabBarDropShadow);
		tabBar.frame = CGRectMake(0.f, 0.f, tabBar.frame.size.width, tabBar.frame.size.height);
	}
}

- (void)dealloc
{
	[super dealloc];
}

@end