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

#import "OFLeaderboardService.h"
#import "OFLeaderboard.h"
#import "OFLeaderboard+Sync.h"

@interface OFLeaderboardService (Private)
+ (void) setupOfflineSupport:(bool)recreateDB;
+ (void) synchLeaderboardsList:(NSArray*)leaderboards aggregateLeaderboards:(NSArray*)aggregateLeaderboards forUser:(NSString*)userId setSynchTime:(BOOL)setSynchTime;
+ (void) getLeaderboardsLocal:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (NSString*) getLastSyncDateForUserId:(NSString*)userId;
+ (NSString*) getLastSyncDateUnixForUserId:(NSString*)userId;
+ (NSMutableArray*) getAggregateParents:(NSString*)leaderboardId;
+ (OFLeaderboard*) getLeaderboard:(NSString*)leaderboardId;
+ (OFLeaderboard_Sync*) getLeaderboardDetails:(NSString*)leaderboardId;
+ (bool) hasLeaderboards;
@end
