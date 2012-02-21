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

#import "OFSocialNotificationService.h"
#import "OFSocialNotificationService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"
#import "OFUsersCredentialService.h"
#import "OFUsersCredential.h"
#import "OFPaginatedSeries.h"
#import "OFTableSectionDescription.h"
#import "OFUnlockedAchievement.h"
#import "OFAchievement.h"

@implementation OFSocialNotificationService (Private)

+ (void)_notificationSent
{
}

+ (void)_notificationFailed
{
}

+ (BOOL)canReceiveCallbacksNow
{
	return true;
}

+ (void)onFailure
{
}

+ (BOOL)_hasGlobalPermissionsOnLinkedCredentials:(NSMutableArray*)usersCredentials
{
	NSEnumerator* usersCredentialsEnumerator = [usersCredentials objectEnumerator];
	OFUsersCredential* userCredential = nil;
	while((userCredential = [usersCredentialsEnumerator nextObject]))
	{
		if(![userCredential isHttpBasic] && userCredential.hasGlobalPermissions == true)
		{
			return true;
		}
	}
	return false;
}

+ (void)_requestPermissionToSendSocialNotification:(OFSocialNotification*)socialNotification withCredentialTypes:(NSArray*)credentials
{
	if([OpenFeint userHasRememberedChoiceForNotifications])
	{
		if([OpenFeint userAllowsNotifications])
		{
			[self sendWithoutRequestingPermissionWithSocialNotification:socialNotification];
		}
	}
	else
	{
		[OpenFeint launchRequestUserPermissionForSocialNotification:socialNotification withCredentialTypes:(NSArray*)credentials];
	}
}

+ (void)onSuccess:(OFPaginatedSeries*)usersCredentialsPaginatedResources withSocialNotification:(OFSocialNotification*)socialNotification
{
	OFTableSectionDescription* usersCredentialsTableSection = [usersCredentialsPaginatedResources.objects objectAtIndex:0];
	OFPaginatedSeries* usersCredentialsPaginated = usersCredentialsTableSection.page;
	NSMutableArray* usersCredentials = usersCredentialsPaginated.objects;
	if([self _hasGlobalPermissionsOnLinkedCredentials:usersCredentials])
	{
		[self _requestPermissionToSendSocialNotification:socialNotification withCredentialTypes:usersCredentials];
	}
}


+ (void)sendWithSocialNotification:(OFSocialNotification*)socialNotification
{
	[OFUsersCredentialService getIndexOnSuccess:OFDelegate(self, @selector(onSuccess:withSocialNotification:), socialNotification) 
									  onFailure:OFDelegate(self, @selector(onFailure)) 
				   onlyIncludeLinkedCredentials:true];
}

+ (void)sendWithAchievement:(OFUnlockedAchievement*)achievement
{
	NSString* notificationText = [NSString 
		stringWithFormat:@"I unlocked \"%@\" in \"%@\"!",
		achievement.achievement.title,
		[OpenFeint applicationShortDisplayName]];

	OFSocialNotification* notice = [[[OFSocialNotification alloc] 
		initWithText:notificationText 
		imageType:@"achievement_definitions" 
		imageId:achievement.achievement.resourceId] autorelease];

	notice.imageUrl = achievement.achievement.iconUrl;

	[OFSocialNotificationService sendWithSocialNotification:notice];
}

+ (void)sendWithAchievements:(OFPaginatedSeries*)page
{
	NSString* notificationText = [NSString 
								  stringWithFormat:@"I unlocked %i achievements in \"%@\"!",
								  [page count],
								  [OpenFeint applicationShortDisplayName]];
	
	OFSocialNotification* notice = [[[OFSocialNotification alloc] 
									 initWithText:notificationText 
									 imageType:@"achievement_definitions"
									 imageId:@"game_icon"] autorelease];
	
	[OFSocialNotificationService sendWithSocialNotification:notice];
}

+ (void)sendWithoutRequestingPermissionWithSocialNotification:(OFSocialNotification*)socialNotification
{
	OFDelegate success = OFDelegate(self, @selector(_notificationSent));	
	OFDelegate failure = OFDelegate(self, @selector(_notificationFailed));
	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> msg = socialNotification.text;
	OFRetainedPtr<NSString> image_type = socialNotification.imageType;
	OFRetainedPtr<NSString> image_name_or_id = socialNotification.imageIdentifier;
	params->io("msg", msg);
	params->io("image_type", image_type);
	if([socialNotification.imageType isEqualToString:@"notification_images"])
	{
		params->io("image_name", image_name_or_id);
	}
	else
	{
		params->io("image_id", image_name_or_id);
	}
	
	OFNotificationData* noticeData = [OFNotificationData 
		dataWithText:[NSString stringWithFormat:@"Published Game Event: %@", socialNotification.text] 
		andCategory:kNotificationCategorySocialNotification
		andType:kNotificationTypeSubmitting];
	noticeData.notificationUserData = socialNotification;
	
	[[self sharedInstance]
	 postAction:@"notifications.xml"
	 withParameters:params
	 withSuccess:success
	 withFailure:failure
	 withRequestType:OFActionRequestBackground
	 withNotice:noticeData];
}

@end