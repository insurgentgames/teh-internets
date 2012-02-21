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
#import "OFUserSettingCell.h"
#import "OFViewHelper.h"
#import "OFUserSetting.h"
#import "OFTableSequenceControllerHelper.h"
#import "OFUserSettingService.h"
#import "OFUserSettingDelegate.h"
#import "OFControllerLoader.h"
#import "OpenFeint+UserOptions.h"

@implementation OFUserSettingCell

@synthesize name;
@synthesize booleanSwitch;
@synthesize owner;

- (void)dealloc
{
	[super dealloc];
}

- (void)setControlToSettingValue:(OFUserSetting*)setting
{
	if([setting.valueType isEqualToString:@"bool"])
	{
		booleanSwitch.on = [setting.value boolValue];
		booleanSwitch.enabled = true;
	}
	else
	{
		booleanSwitch.enabled = false;
		booleanSwitch.on = NO;
	}
}

- (void)setSettingToControlValue:(OFUserSetting*)setting
{
	if([setting.valueType isEqualToString:@"bool"])
	{
		setting.value = booleanSwitch.on ? @"1" : @"0";
	}
}

- (void)onResourceChanged:(OFResource*)resource
{	
	OFUserSetting* setting = (OFUserSetting*)resource;
	name.text = setting.name;
	
	// Takeshi note: temporal fix, I think
	if ([setting.key isEqualToString:@"newsletter_open_feint"] && [setting.value isEqualToString:@"1"] && ![OpenFeint loggedInUserHasHttpBasicCredential])
		setting.value = @"0";

	[self setControlToSettingValue:setting];
}

- (IBAction)switchToggled
{
	[owner showLoadingScreen];
	
	OFUserSetting* setting = (OFUserSetting*)mResource;
    
	[OFUserSettingService 
		setUserSettingWithId:setting.resourceId
		toBoolValue:booleanSwitch.on 
		onSuccess:OFDelegate(self, @selector(onSubmitSuccess))
		onFailure:OFDelegate(self, @selector(onSubmitFailure))];
	
	[OFUserSettingDelegate settingValueToggled:setting value:booleanSwitch.on];
}

- (void)onSubmitFailure
{
	[owner hideLoadingScreen];
	
	[self setControlToSettingValue:(OFUserSetting*)mResource];
	
	[[[[UIAlertView alloc]
		initWithTitle:@"Oops! There was a problem"
		message:@"Something went wrong and we weren't able to save your change. Please try again later."
		delegate:nil
		cancelButtonTitle:@"OK"
		otherButtonTitles:nil] autorelease] show];
		
	[self setNeedsLayout];
}

- (void)onSubmitSuccess
{
	[owner hideLoadingScreen];
	[self setSettingToControlValue:(OFUserSetting*)mResource];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
