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

#import "OFUserSettingDelegate.h"
#import "OFUserSettingPushController.h"
#import "OFAccountSetupBaseController.h"
#import "OFControllerLoader.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFLocation.h"
#import "OFPresenceService.h"

// UINavigationController.h
//#import <UIKit/UINavigationController.h>


@implementation OFUserSettingDelegate

+ (void)settingValueToggled:(OFUserSetting*)setting value:(BOOL)value
{
	if ([setting.key isEqualToString:@"location"])
	{
		if (value)
		{
			[OpenFeint setUserDistanceUnit:kDistanceUnitNotDefined];
			[OpenFeint startLocationManagerIfAllowed];
		}
		else
		{
			[OpenFeint setUserDistanceUnit:kDistanceUnitNotAllowed];
			[OpenFeint setUserLocation:nil];
		}
	}
	else if ( [setting.key isEqualToString:@"facebookstream"] && ![OpenFeint loggedInUserHasFbconnectCredential])
	{
		if (value)
		{
			UINavigationController* currentNavController = [OpenFeint getActiveNavigationController];
			OFAccountSetupBaseController* controllerToPush =
				(OFAccountSetupBaseController*)OFControllerLoader::load(@"FacebookAccountLogin");

			[controllerToPush setAddingAdditionalCredential:YES];
			[currentNavController pushViewController:controllerToPush animated:YES];
		}		
	}
	else if ( [setting.key isEqualToString:@"twitterstream"] && ![OpenFeint loggedInUserHasTwitterCredential])
	{
		if (value)
		{
			UINavigationController* currentNavController = [OpenFeint getActiveNavigationController];
			OFAccountSetupBaseController* controllerToPush =
			(OFAccountSetupBaseController*)OFControllerLoader::load(@"TwitterAccountLogin");
			
			[controllerToPush setAddingAdditionalCredential:YES];
			[currentNavController pushViewController:controllerToPush animated:YES];
		}
	}
	else if ([setting.key isEqualToString:@"presence"])
	{
		if (value)
		{
			[[OFPresenceService sharedInstance] connect];
		}
		else
		{
			[[OFPresenceService sharedInstance] disconnectAndShutdown:NO];
		}
	}
	else if ([setting.key isEqualToString:@"newsletter_open_feint"] && ![OpenFeint loggedInUserHasHttpBasicCredential])
    {
        if (value)
        {
			UINavigationController* currentNavController = [OpenFeint getActiveNavigationController];
            UIViewController* controller = OFControllerLoader::load(@"HttpCredentialsCreate");

			//[controllerToPush setAddingAdditionalCredential:YES];
            [currentNavController pushViewController:controller animated:YES];
            
            [[[[UIAlertView alloc] initWithTitle:@"Enable Account Retrieval"
                                         message:@"In order to subscribe, you must first enable account retrieval with an email address and password."
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil] autorelease] show];
        }
    }
}

@end
