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
#import "OFNotification.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFNotificationView.h"
#import "OFAchievementNotificationView.h"
#import "OFAchievement.h"
#import "OFChallengeToUser.h"
#import "OFChallengeNotificationView.h"
#import "OpenFeint+Private.h"

@implementation OFNotification

+ (OFNotification*)sharedInstance				
{												
	static OFNotification* sInstance = nil;		
	if(sInstance == nil)						
	{											
		sInstance = [OFNotification new];		
	}											
	
	return sInstance;							
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (BOOL)allowNotice:(OFNotificationData*)notificationData
{
	id<OFNotificationDelegate> notificationDelegate = [OpenFeint getNotificationDelegate];
	if (notificationDelegate && [notificationDelegate respondsToSelector:@selector(isOpenFeintNotificationAllowed:)])
	{
		return [notificationDelegate isOpenFeintNotificationAllowed:notificationData];
	}
	else
	{
		return true;
	}
}

- (void)handleDisallowedNotification:(OFNotificationData*)notificationData
{
	OF_OPTIONALLY_INVOKE_DELEGATE_WITH_PARAMETER([OpenFeint getNotificationDelegate], handleDisallowedNotification:, notificationData);
}

- (void)onNotificationWillShow:(OFNotificationData*)notificationData
{
	OF_OPTIONALLY_INVOKE_DELEGATE_WITH_PARAMETER([OpenFeint getNotificationDelegate], notificationWillShow:, notificationData);
}

- (void)showBackgroundNoticeForLoader:(MPOAuthAPIRequestLoader*)request withNotice:(OFNotificationData*)noticeData
{
	OFAssert(noticeData, @"Can't show a nil notification");
	if ([self allowNotice:noticeData])
	{
		UIView* topView = [OpenFeint getTopApplicationWindow];
		if (topView)
		{
			[self onNotificationWillShow:noticeData];
			[OFNotificationView showNotificationWithRequest:request andNotice:noticeData.notificationText inView:topView withInputResponse:nil];
		}
	}
	else
	{
		[request loadSynchronously:NO];
		[self handleDisallowedNotification:noticeData];
	}
}

- (void)showBackgroundNotice:(OFNotificationData*)noticeData andStatus:(OFNotificationStatus*)status andInputResponse:(OFNotificationInputResponse*)inputResponse
{
	if (![OpenFeint isDashboardHubOpen])
	{
		if ([self allowNotice:noticeData])
		{
			UIView* topView = [OpenFeint getTopApplicationWindow];
			if (topView)
			{
				[self onNotificationWillShow:noticeData];
				[OFNotificationView showNotificationWithText:noticeData.notificationText andStatus:status inView:topView withInputResponse:inputResponse];
			}
		}
		else
		{
			[self handleDisallowedNotification:noticeData];
		}
	}
}

- (void)showAchievementNotice:(OFAchievement*)unlockedAchievement withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFUnlockedAchievementNotificationData* noticeData = [OFUnlockedAchievementNotificationData dataWithAchievement:unlockedAchievement];
	if ([self allowNotice:noticeData])
	{
		UIView* topView = [OpenFeint getTopApplicationWindow];
		if (topView)
		{
			[self onNotificationWillShow:noticeData];
			[OFAchievementNotificationView showAchievementNotice:noticeData inView:topView withInputResponse:inputResponse];
		}
	}
	else
	{
		[self handleDisallowedNotification:noticeData];
	}
}

- (void)showChallengeNotice:(OFChallengeToUser*)challengeToUser withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFReceivedChallengeNotificationData* noticeData = [OFReceivedChallengeNotificationData dataWithChallengeToUser:challengeToUser];
	if ([self allowNotice:noticeData])
	{
		UIView* topView = [OpenFeint getTopApplicationWindow];
		if (topView)
		{
			[self onNotificationWillShow:noticeData];
			[OFChallengeNotificationView showChallengeNotice:noticeData inView:topView withInputResponse:inputResponse];
		}
	}
	else
	{
		[self handleDisallowedNotification:noticeData];
	}
}

@end