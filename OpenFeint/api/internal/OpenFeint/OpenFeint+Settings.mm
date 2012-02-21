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

#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"

static const NSString* OpenFeintSettingPollingFrequencyDefault = @"OpenFeintSettingPollingFrequencyDefault";
static const NSString* OpenFeintSettingPollingFrequencyChat = @"OpenFeintSettingPollingFrequencyChat";

@implementation OpenFeint (OFSettings)

+ (void)intiailizeSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"30",  OpenFeintSettingPollingFrequencyDefault,
		@"3",   OpenFeintSettingPollingFrequencyChat,
		nil
	];
	
	
	[defaults registerDefaults:appDefaults];
}

+ (NSString*)applicationDisplayName
{
	return [self sharedInstance]->mDisplayName;
}	 		

+ (NSString*)applicationShortDisplayName
{
	return [self sharedInstance]->mShortDisplayName;
}

//////////////////////////////////////////////////

+ (NSUInteger)getPollingFrequencyDefault
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintSettingPollingFrequencyDefault];
}

+ (void)storePollingFrequencyDefault:(NSUInteger)pollingFrequencyDefault
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:pollingFrequencyDefault]
											  forKey:OpenFeintSettingPollingFrequencyDefault];
}

//////////////////////////////////////////////////

+ (NSUInteger)getPollingFrequencyInChat
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintSettingPollingFrequencyChat];
}

+ (void)storePollingFrequencyInChat:(NSUInteger)pollingFrequencyInChat
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:pollingFrequencyInChat]
											  forKey:OpenFeintSettingPollingFrequencyChat];
}

@end