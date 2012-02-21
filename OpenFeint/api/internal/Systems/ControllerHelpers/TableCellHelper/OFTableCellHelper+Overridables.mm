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
#import "OFTableCellHelper+Overridables.h"
#import "OFControllerHelpersCommon.h"

@implementation OFTableCellHelper ( Overridables )

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	ASSERT_OVERRIDE_MISSING;
}

- (void)onResourceChanged:(OFResource*)resource
{
}

- (void)onResourceChanged:(OFResource*)resource withCellIndex:(NSUInteger)index
{
	[self onResourceChanged:resource];
}

- (BOOL)wantsToConfigureSelf
{
	return NO;
}

- (void)configureSelfAsLeading:(BOOL)_isLeading asTrailing:(BOOL)_isTrailing asOdd:(BOOL)_isOdd
{
	// do nothing
}

- (void)viewDidAppear
{
	// Do nothing
}

- (void)viewDidDisappear
{
	// Do nothing
}

@end
