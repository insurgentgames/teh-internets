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
#import "OFAchievement.h"
#import "OFAchievementService.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OpenFeint+Private.h"
#import "OFReachability.h"
#import "OpenFeint+UserOptions.h"
#import "OFAchievementService+Private.h"
#import "OFNotification.h"
#import "OFUnlockedAchievement.h"
#import "OFAchievement.h"
#import "OpenFeint+Settings.h"
#import "OFSocialNotificationService+Private.h"
#import "OFAchievementListController.h"
#import "OFInputResponseOpenDashboard.h"
#import "OFControllerLoader.h"
#import "OFDelegateChained.h"
#import "OpenFeint+Dashboard.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFAchievementService)

@implementation OFAchievementService

OPENFEINT_DEFINE_SERVICE(OFAchievementService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFAchievement getResourceName], [OFAchievement class]);
	namedResources->addResource([OFUnlockedAchievement getResourceName], [OFUnlockedAchievement class]);
}

+ (void) getAchievementsForApplication:(NSString*)applicationId 
						comparedToUser:(NSString*)comparedToUserId 
								  page:(NSUInteger)pageIndex
							 onSuccess:(OFDelegate const&)onSuccess 
							 onFailure:(OFDelegate const&)onFailure
{
	[OFAchievementService getAchievementsForApplication:applicationId comparedToUser:comparedToUserId page:pageIndex silently:NO onSuccess:onSuccess onFailure:onFailure];
}
							 
+ (void) getAchievementsForApplication:(NSString*)applicationId 
						comparedToUser:(NSString*)comparedToUserId 
								  page:(NSUInteger)pageIndex
							  silently:(BOOL)silently
							 onSuccess:(OFDelegate const&)onSuccess 
							 onFailure:(OFDelegate const&)onFailure
{
	if ([OpenFeint isOnline])
	{
		OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
		if ([applicationId length] > 0 && ![applicationId isEqualToString:@"@me"])
		{
			params->io("by_app", applicationId);
		}
		
		if (comparedToUserId)
		{
			params->io("compared_to_user_id", comparedToUserId);
		}
		
		params->io("page", pageIndex);
		int per_page = 25;
		params->io("per_page", per_page);
		
		bool kGetUnlockedInfo = true;
		params->io("get_unlocked_info", kGetUnlockedInfo);
		
		[[self sharedInstance] 
		 getAction:@"client_applications/@me/achievement_definitions.xml"
		 withParameters:params
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:(silently ? OFActionRequestSilent : OFActionRequestForeground)
		 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Achievement Information"]];
	} else {
		[OFAchievementService getAchievementsLocal:onSuccess onFailure:onFailure];
	}
}

+ (OFNotificationInputResponse*)createAchievementInputResponse
{
	OFAchievementListController* achievementList = (OFAchievementListController*)OFControllerLoader::load(@"AchievementList");
	achievementList.applicationName = [OpenFeint applicationDisplayName];
	achievementList.applicationId = [OpenFeint clientApplicationId];
	achievementList.applicationIconUrl = [OpenFeint clientApplicationIconUrl];
	achievementList.doesUserHaveApplication = YES;
	
	OFNotificationInputResponse* inputResponse = [[[OFInputResponseOpenDashboard alloc] 
		initWithTab:OpenFeintDashBoardTabNowPlaying 
		andController:achievementList] autorelease];
		
	return inputResponse;
}

- (void)_onAchievementUnlockedDuringSync:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall
{
	[self onAchievementUnlocked:page nextCall:nextCall duringSync:YES fromBatch:YES];
}

- (void)_onAchievementUnlockedFromBatch:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall
{
	[self onAchievementUnlocked:page nextCall:nextCall duringSync:NO fromBatch:YES];
}

- (void)_onAchievementUnlocked:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall
{
	[self onAchievementUnlocked:page nextCall:nextCall duringSync:NO fromBatch:NO];
}

- (void) onAchievementUnlocked:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall duringSync:(BOOL)duringSync fromBatch:(BOOL) fromBatch
{
	unsigned int achievementCnt = [page count];
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	OFUnlockedAchievement* unlockedAchievement = nil;
	
	for (unsigned int i = 0; i < achievementCnt; i++)
	{
		unlockedAchievement = [page objectAtIndex:i];
		if (unlockedAchievement.result == kUnlockResult_Success)
		{
			NSDate* unlockedDate = unlockedAchievement.achievement.unlockDate;
			if (!unlockedDate)
			{
				unlockedDate = [NSDate date];
			}
			[OFAchievementService 
			 synchUnlockedAchievement:unlockedAchievement.achievement.resourceId
			 forUser:lastLoggedInUser
			 gamerScore:[NSString stringWithFormat:@"%d", unlockedAchievement.achievement.gamerscore]
			 serverDate:unlockedDate];		
		}
	}
	
	if (achievementCnt == 1)
	{
		if (!duringSync && !fromBatch)
		{
			OFNotificationInputResponse* inputResponse = [OFAchievementService createAchievementInputResponse];
			[[OFNotification sharedInstance] showAchievementNotice:unlockedAchievement.achievement withInputResponse:inputResponse];
		}
		if (!duringSync && mAutomaticallyPromptToPostUnlocks)
			[OFSocialNotificationService sendWithAchievement:unlockedAchievement];
	}
	else if (achievementCnt > 1)
	{
		if (!duringSync)
		{
			OFNotificationInputResponse* inputResponse = [OFAchievementService createAchievementInputResponse];
			OFNotificationData* notice = [OFNotificationData dataWithText:@"Submitted Achievements To Server" andCategory:kNotificationCategoryAchievement andType:kNotificationTypeSuccess];
			[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusSuccess andInputResponse:inputResponse];
		}
		if (!duringSync && mAutomaticallyPromptToPostUnlocks)
			[OFSocialNotificationService sendWithAchievements:page];
	}
	
	[nextCall invokeWith:page];
}

- (void)_onAchievementUnlockFailed:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall
{
	OFNotificationInputResponse* inputResponse = [OFAchievementService createAchievementInputResponse];
	[[OFNotification sharedInstance] showAchievementNotice:nil withInputResponse:inputResponse];
	[nextCall invokeWith:page];
}

+ (void) unlockAchievement:(NSString*)achievementId 
{
	[OFAchievementService unlockAchievement:achievementId onSuccess:OFDelegate() onFailure:OFDelegate()];
}

+ (void) unlockAchievement:(NSString*)achievementId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	if ([lastLoggedInUser longLongValue] > 0)
	{
		bool unlocked = [OFAchievementService alreadyUnlockedAchievement:achievementId forUser:lastLoggedInUser];
		if (!unlocked)
		{
			[OFAchievementService localUnlockAchievement:achievementId forUser:lastLoggedInUser];
			
			OFDelegate onSuccessOffline([self sharedInstance], @selector(_onAchievementUnlocked:nextCall:), onSuccess);
			OFDelegate onFailureOffline([self sharedInstance], @selector(_onAchievementUnlockFailed:nextCall:), onFailure);
			
			OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
			OFRetainedPtr<NSString> resourceId = achievementId;
			params->io("achievement_definition_id", resourceId);
			
			[[self sharedInstance] 
			 postAction:@"users/@me/unlocked_achievements.xml"
			 withParameters:params
			 withSuccess:onSuccessOffline
			 withFailure:onFailureOffline
			 withRequestType:OFActionRequestSilent
			 withNotice:nil];
		}
	}
}

+ (bool) queueUnlockedAchievement:(NSString*)achievementId 
{
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	bool unlocked = true;
	if ([lastLoggedInUser longLongValue] > 0)
	{
		unlocked = [OFAchievementService alreadyUnlockedAchievement:achievementId forUser:lastLoggedInUser];
		if (!unlocked)
		{
			[OFAchievementService localUnlockAchievement:achievementId forUser:lastLoggedInUser];

			OFAchievement* achievement = [OFAchievementService getAchievement:achievementId];
			[[OFNotification sharedInstance] showAchievementNotice:achievement withInputResponse:nil];
		}
	}
	return !unlocked;
}

+ (void) submitQueuedUnlockedAchievements:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	[OFAchievementService sendPendingAchievements:lastLoggedInUser syncOnly:NO onSuccess:onSuccess onFailure:onFailure];
}

+ (void)setAutomaticallyPromptToPostUnlocks:(BOOL)automaticallyPrompt
{
	OFAchievementService* service = [self sharedInstance];
	if (service)
	{
		service->mAutomaticallyPromptToPostUnlocks = automaticallyPrompt;
	}
}

@end