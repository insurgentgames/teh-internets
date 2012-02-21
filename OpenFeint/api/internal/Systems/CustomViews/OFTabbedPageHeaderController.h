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

#pragma once

#import "OFTabBarDelegate.h"
#import "OFTableControllerHeader.h"
@class OFTabBar;

@interface OFTabbedPageHeaderController : UIViewController<OFTabBarDelegate, OFTableControllerHeader>
{
@package
	NSMutableDictionary* mTabCallbacks;
	IBOutlet OFTabBar* tabBar;
	id callbackTarget;
}

@property (nonatomic, assign) id callbackTarget;

- (void)addTab:(NSString*)tabText andSelectedCallback:(SEL)selectedCallback;
- (void)showTab:(NSString*)tabText;

- (void)setBadgeValue:(NSInteger)value forTabNamed:(NSString*)tabText;

- (void)resizeView:(UIView*)parentView;

@end
