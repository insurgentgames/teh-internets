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
#import "OFUserSettingActionCell.h"
#import "OFViewHelper.h"
#import "OFTableSequenceControllerHelper.h"
#import "OFUserSettingPushController.h"


@implementation OFUserSettingActionCell

@synthesize owner;

- (void)onResourceChanged:(OFResource*)resource
{	
	if ([resource isKindOfClass:[OFUserSettingPushController class]])
	{
		OFUserSettingPushController* pushControllerResource = (OFUserSettingPushController*)resource;
		UILabel* titleLabel = (UILabel*)OFViewHelper::findViewByTag(self, 1);
		titleLabel.text = pushControllerResource.settingTitle;
	}
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc
{
	[super dealloc];
}

@end
