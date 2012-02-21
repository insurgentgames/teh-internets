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
#import "OFTabbedPageHeaderController.h"
#import "OFTabBar.h"
#import "OpenFeint+Private.h"
@implementation OFTabbedPageHeaderController

@synthesize callbackTarget;

- (void)addTab:(NSString*)tabText andSelectedCallback:(SEL)selectedCallback
{
	bool firstTab = false;
	if (mTabCallbacks == nil)
	{
		firstTab = true;
		mTabCallbacks = [NSMutableDictionary new]; 
	}
	
	[mTabCallbacks setValue:NSStringFromSelector(selectedCallback) forKey:tabText];
	[tabBar addSegmentNamed:tabText activeImage:nil inactiveImage:nil disabledImage:nil];
	if (firstTab)
	{
		[self showTab:tabText];
	}
}

- (void)showTab:(NSString*)tabText
{
	[tabBar showTabNamed:tabText notifyDelegate:NO];
}

- (void)setBadgeValue:(NSInteger)value forTabNamed:(NSString*)tabText
{
	[tabBar setBadgeValue:value forItemNamed:tabText];
}

- (void)resizeView:(UIView*)parentView
{
	self.view.frame = CGRectMake(0.f, 0.f, parentView.frame.size.width, self.view.frame.size.height);
}

- (void)tabBar:(OFTabBar*)tabBar didSelectTabNamed:(NSString*)tabName
{
	NSString* callbackAsString = (NSString*)[mTabCallbacks objectForKey:tabName];
	if (callbackAsString)
	{
		[callbackTarget performSelector:NSSelectorFromString(callbackAsString)];
	}
}

- (void)dealloc
{
	self.callbackTarget = nil;
	OFSafeRelease(tabBar);
	OFSafeRelease(mTabCallbacks);
	[super dealloc];
}

@end
