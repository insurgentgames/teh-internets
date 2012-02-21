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

#import "OFAchievementService.h"
#import "OFAchievement.h"

@interface OFAchievementService (Private)

+ (void) setupOfflineSupport:(bool)recreateDB;
+ (bool) localUnlockAchievement:(NSString*)achievementId forUser:(NSString*)userId;
+ (void) unlockAchievements:(NSArray*)achievementIdList onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;
+ (bool) alreadyUnlockedAchievement:(NSString*)achievementId forUser:(NSString*)userId;
+ (bool) synchUnlockedAchievement:(NSString*)achievementId forUser:(NSString*)userId gamerScore:(NSString*)gamerScore serverDate:(NSDate*)serverDate;
+ (void) synchAchievementsList:(NSArray*)achievements forUser:(NSString*)userId;
+ (NSString*) getLastSyncDateForUserId:(NSString*)userId;
+ (void) getAchievementsLocal:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (bool) hasAchievements;
+ (void) sendPendingAchievements:(NSString*)userId syncOnly:(BOOL)syncOnly onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (OFAchievement*) getAchievement:(NSString*)achievementId;

@end