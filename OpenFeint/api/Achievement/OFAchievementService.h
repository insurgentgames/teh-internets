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

#import "OFService.h"
#import "OFNotificationView.h"
#import "OFPaginatedSeries.h"
#import "OFDelegateChained.h"

@interface OFAchievementService : OFService
{
	BOOL mAutomaticallyPromptToPostUnlocks;
}

OPENFEINT_DECLARE_AS_SERVICE(OFAchievementService);

+ (void) getAchievementsForApplication:(NSString*)applicationId 
						comparedToUser:(NSString*)comparedToUserId 
								  page:(NSUInteger)pageIndex
							 onSuccess:(OFDelegate const&)onSuccess 
							 onFailure:(OFDelegate const&)onFailure;

+ (void) getAchievementsForApplication:(NSString*)applicationId 
						comparedToUser:(NSString*)comparedToUserId 
								  page:(NSUInteger)pageIndex
							  silently:(BOOL)silently
							 onSuccess:(OFDelegate const&)onSuccess 
							 onFailure:(OFDelegate const&)onFailure;

+ (void) unlockAchievement:(NSString*)achievementId;
+ (void) unlockAchievement:(NSString*)achievementId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

+ (bool) queueUnlockedAchievement:(NSString*)achievementId;
+ (void) submitQueuedUnlockedAchievements:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

- (void) onAchievementUnlocked:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)nextCall duringSync:(BOOL)duringSync fromBatch:(BOOL) fromBatch;
+ (OFNotificationInputResponse*) createAchievementInputResponse;

+ (void)setAutomaticallyPromptToPostUnlocks:(BOOL)automaticallyPrompt;

@end