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

#import "OFLeaderboardService+Private.h"
#import "OFSqlQuery.h"
#import "OFReachability.h"
#import "OFActionRequestType.h"
#import "OFService+Private.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import <sqlite3.h>
#import "OFLeaderboard.h"
#import "OFLeaderboard+Sync.h"
#import "OFLeaderboardAggregation.h"
#import "OFHighScore.h"
#import "OFHighScoreService.h"
#import "OFHighScoreService+Private.h"
#import "OFUserService+Private.h"
#import "OFPaginatedSeries.h"
#import "OFSettings.h"
#import "OFOfflineService.h"

namespace
{
	static OFSqlQuery sServerSynchQuery;
	static OFSqlQuery sLastSynchQuery;
	static OFSqlQuery sGetActiveLeaderboardsQuery;
	static OFSqlQuery sGetLeaderboardQuery;
	static OFSqlQuery sGetAggregateLeaderboardsQuery;
	static OFSqlQuery sServerSynchAggQuery;
	//static OFSqlQuery sGetActiveLeaderboardsUserQuery;
}

@implementation OFLeaderboardService (Private)

- (id) init
{
	self = [super init];
	
	if (self != nil)
	{
		//[OFHighScoreService setupOfflineSupport];
	}
	
	return self;
}

- (void) dealloc
{
	sServerSynchQuery.destroyQueryNow();
	sLastSynchQuery.destroyQueryNow();
	sGetActiveLeaderboardsQuery.destroyQueryNow();
	sGetLeaderboardQuery.destroyQueryNow();
	sGetAggregateLeaderboardsQuery.destroyQueryNow();
	sServerSynchAggQuery.destroyQueryNow();
	//sGetActiveLeaderboardsUserQuery.destroyQueryNow();
	[super dealloc];
}

+ (void) setupOfflineSupport:(bool)recreateDB
{
	if( recreateDB )
	{
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle],
			"DROP TABLE IF EXISTS leaderboards"
			).execute();

		OFSqlQuery(
		   [OpenFeint getOfflineDatabaseHandle],
		   "DROP TABLE IF EXISTS leaderboard_aggregations"
		   ).execute();
	}
	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle],
		"CREATE TABLE IF NOT EXISTS leaderboards("
		"id INTEGER NOT NULL,"
		"name TEXT DEFAULT NULL,"
		"descending_sort_order INTEGER DEFAULT 0,"
		"active INTEGER DEFAULT 0,"
		"is_aggregate INTEGER DEFAULT 0,"
		"visible INTEGER DEFAULT 0,"
		"allow_posting_lower_scores INTEGER DEFAULT 0,"
		"start_version  TEXT DEFAULT NULL,"
		"end_version  TEXT DEFAULT NULL,"
		"server_sync_at  INTEGER DEFAULT NULL)"
		).execute();

	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle], 
		"CREATE UNIQUE INDEX IF NOT EXISTS leaderboards_index "
		"ON leaderboards (id)"
		).execute();
	
	[OFOfflineService setTableVersion:@"leaderboards" version:1];

	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle],
		"CREATE TABLE IF NOT EXISTS leaderboard_aggregations("
		"aggregate_leaderboard_id INTEGER NOT NULL,"
		"leaderboard_pushing_changes_id INTEGER NOT NULL,"
	    "server_sync_at INTEGER DEFAULT NULL)"
		).execute();

	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle], 
		"CREATE UNIQUE INDEX IF NOT EXISTS leaderboard_aggregations_index "
		"ON leaderboard_aggregations (aggregate_leaderboard_id,leaderboard_pushing_changes_id)"
		).execute();

	[OFOfflineService setTableVersion:@"leaderboard_aggregations" version:1];	
		
	sLastSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT datetime(MAX(server_sync_at), 'unixepoch') last_sync_date, MAX(server_sync_at) last_sync_unix FROM "
		"(SELECT MIN(server_sync_at) AS server_sync_at FROM "
		"(SELECT MAX(server_sync_at) AS server_sync_at FROM "
		"(SELECT MAX(server_sync_at) AS server_sync_at FROM high_scores WHERE user_id = :user_id AND server_sync_at IS NOT NULL UNION SELECT 0 AS server_sync_at) X "
		"UNION SELECT MAX(server_sync_at) AS server_sync_at FROM leaderboards WHERE server_sync_at IS NOT NULL) Y ) Z"
		);
	
	sServerSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"REPLACE INTO leaderboards"
		"(id, name, descending_sort_order, active, is_aggregate, visible, allow_posting_lower_scores, start_version, end_version, server_sync_at) "
		"VALUES (:id, :name, :descending_sort_order, :active, :is_aggregate, :visible, :allow_posting_lower_scores, :start_version, :end_version, :server_sync_at)" //strftime('%s', 'now'))"
		);
	
	sGetActiveLeaderboardsQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT * FROM leaderboards "
		"WHERE active = 1 AND visible = 1 " 
		"AND (start_version <= :app_version AND end_version >= :app_version)"
		);
	/* doesn't work on 2.2 SDK
	sGetActiveLeaderboardsUserQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT lbs.name AS name, lbs.id AS id, lbs.id AS leaderboard_id, lbs.descending_sort_order AS descending_sort_order, us.user_id AS user_id, CASE WHEN (lbs.descending_sort_order = 0) THEN us.min_score ELSE us.max_score END AS score, CASE WHEN (lbs.descending_sort_order = 0) THEN us.min_display_text ELSE us.max_display_text END AS display_text FROM "
		"(SELECT * FROM leaderboards WHERE active = 1 AND visible = 1 AND (start_version <= :app_version AND end_version >= :app_version)) AS lbs " 
		"LEFT JOIN (SELECT min_us.user_id, min_us.leaderboard_id, min_score, min_display_text, max_score, max_display_text FROM "
		"(SELECT h.user_id, h.leaderboard_id, h.score as min_score, display_text as min_display_text from high_scores h, (SELECT user_id, leaderboard_id, MIN(score) as score FROM high_scores WHERE user_id = :user_id GROUP BY user_id, leaderboard_id) AS gmin where gmin.user_id = h.user_id AND gmin.leaderboard_id = h.leaderboard_id AND gmin.score = h.score) AS min_us, "
		"(SELECT h.user_id, h.leaderboard_id, h.score as max_score, display_text as max_display_text from high_scores h, (SELECT user_id, leaderboard_id, MAX(score) as score FROM high_scores WHERE user_id = :user_id GROUP BY user_id, leaderboard_id) AS gmax where gmax.user_id = h.user_id AND gmax.leaderboard_id = h.leaderboard_id AND gmax.score = h.score) AS max_us "
	    "WHERE min_us.user_id = max_us.user_id AND min_us.leaderboard_id = max_us.leaderboard_id) AS us "
		"ON lbs.id = us.leaderboard_id"
		);
	*/
	
	sGetLeaderboardQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT * FROM leaderboards "
		"WHERE id = :id "
		);
	
	sGetAggregateLeaderboardsQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
	    "SELECT aggregate_leaderboard_id FROM leaderboard_aggregations "
		"WHERE leaderboard_pushing_changes_id = :leaderboard_pushing_changes_id "
		);
	
	sServerSynchAggQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"REPLACE INTO leaderboard_aggregations (aggregate_leaderboard_id, leaderboard_pushing_changes_id, server_sync_at) "
		"VALUES (:aggregate_leaderboard_id, :leaderboard_pushing_changes_id, :server_sync_at)"
	);
}

+ (void) synchLeaderboardsList:(NSArray*)leaderboards aggregateLeaderboards:(NSArray*)aggregateLeaderboards forUser:(NSString*)userId setSynchTime:(BOOL)setSynchTime
{
	NSString* serverSynch = (setSynchTime ? [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]] : nil);

	OFSqlQuery([OpenFeint getOfflineDatabaseHandle],"BEGIN TRANSACTION").execute();
	
	unsigned int aggLeaderboardCnt = [aggregateLeaderboards count];
	for (unsigned int i = 0; i < aggLeaderboardCnt; i++)
	{
		OFLeaderboardAggregation* aggLeaderboard = [aggregateLeaderboards objectAtIndex:i];
		sServerSynchAggQuery.bind( "aggregate_leaderboard_id", aggLeaderboard.aggregateLeaderboardId);
		sServerSynchAggQuery.bind( "leaderboard_pushing_changes_id", aggLeaderboard.leaderboardPushingChangesId);
		sServerSynchAggQuery.bind( "server_sync_at", serverSynch);
		sServerSynchAggQuery.execute();
		sServerSynchAggQuery.resetQuery();
	}

	unsigned int leaderboardCnt = [leaderboards count];
	for (unsigned int i = 0; i < leaderboardCnt; i++)
	{
		OFLeaderboard_Sync* leaderboard = [leaderboards objectAtIndex:i];
		
		sServerSynchQuery.bind("id", leaderboard.resourceId);
		sServerSynchQuery.bind("name", leaderboard.name);
		sServerSynchQuery.bind("descending_sort_order", [NSString stringWithFormat:@"%d", (leaderboard.descendingSortOrder? 1 : 0)]);
		sServerSynchQuery.bind("active", [NSString stringWithFormat:@"%d", (leaderboard.active? 1 : 0)]);
		sServerSynchQuery.bind("visible", [NSString stringWithFormat:@"%d", (leaderboard.visible? 1 : 0)]);
		sServerSynchQuery.bind("is_aggregate", [NSString stringWithFormat:@"%d", (leaderboard.isAggregate? 1 : 0)]);
		sServerSynchQuery.bind("allow_posting_lower_scores", [NSString stringWithFormat:@"%d", (leaderboard.allowPostingLowerScores? 1 : 0)]);
		sServerSynchQuery.bind("start_version", leaderboard.startVersion);
		sServerSynchQuery.bind("end_version", leaderboard.endVersion);		
		sServerSynchQuery.bind("server_sync_at", serverSynch);		
		sServerSynchQuery.execute();
		sServerSynchQuery.resetQuery();

		//add user high_score as need 
		if (leaderboard.score > 0 && setSynchTime) 
		{
			[OFHighScoreService 
			 localSetHighScore:leaderboard.score
			 forLeaderboard:leaderboard.resourceId
			 forUser:userId
			 displayText:([leaderboard.displayText length] > 0 ? leaderboard.displayText : nil)
			 customData:([leaderboard.customData length] > 0 ? leaderboard.customData : nil)
			 serverDate:leaderboard.reachedAt
			 addToExisting:NO];
		}
	}
	
	OFSqlQuery([OpenFeint getOfflineDatabaseHandle],"COMMIT").execute();
}

+ (NSString*) getLastSyncDateForUserId:(NSString*)userId
{
	NSString* lastSyncDate = NULL;
	sLastSynchQuery.bind("user_id", userId);
	sLastSynchQuery.execute();
	lastSyncDate = [NSString stringWithFormat:@"%s", sLastSynchQuery.getText("last_sync_date")];
	sLastSynchQuery.resetQuery();
	return lastSyncDate;
}

+ (NSString*) getLastSyncDateUnixForUserId:(NSString*)userId
{
	NSString* lastSyncDate = NULL;
	sLastSynchQuery.bind("user_id", userId);
	sLastSynchQuery.execute();
	lastSyncDate = [NSString stringWithFormat:@"%s", sLastSynchQuery.getText("last_sync_unix")];
	sLastSynchQuery.resetQuery();
	return lastSyncDate;
}


+ (void) getLeaderboardsLocal:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure 
{
	NSMutableArray* leaderboards = [[NSMutableArray new] autorelease];
	
	sGetActiveLeaderboardsQuery.bind("app_version", [OFOfflineService getFormattedAppVersion]);
	OFUser* localUser = [OpenFeint localUser];
	for (sGetActiveLeaderboardsQuery.execute(); !sGetActiveLeaderboardsQuery.hasReachedEnd(); sGetActiveLeaderboardsQuery.step())
	{
		NSString* leaderboardId = [NSString stringWithFormat:@"%s", sGetActiveLeaderboardsQuery.getText("id")];
		bool descendingSortOrder = sGetActiveLeaderboardsQuery.getBool("descending_sort_order");
		OFHighScore* userScore = [OFHighScoreService getHighScoreForUser:localUser leaderboardId:leaderboardId descendingSortOrder:descendingSortOrder];
		
		[leaderboards addObject:[[[OFLeaderboard alloc] initWithLocalSQL:&sGetActiveLeaderboardsQuery 
														  localUserScore:userScore
													   comparedUserScore:nil] autorelease]];
	}
	sGetActiveLeaderboardsQuery.resetQuery();
	
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeriesFromArray:leaderboards];
	onSuccess.invoke(page);
}

+ (OFLeaderboard*) getLeaderboard:(NSString*)leaderboardId
{
	OFLeaderboard* leaderboard = nil;
	sGetLeaderboardQuery.bind("id", leaderboardId);
	sGetLeaderboardQuery.execute();
	if (sGetLeaderboardQuery.getLastStepResult() == SQLITE_ROW)
	{
		leaderboard = [[[OFLeaderboard alloc] initWithLocalSQL:&sGetLeaderboardQuery
												localUserScore:nil
											 comparedUserScore:nil] autorelease];
	}
	else 
	{
		NSLog(@"Definition for leaderboard %@ was not found", leaderboardId);
	}
	sGetLeaderboardQuery.resetQuery();
	return leaderboard;
}

+ (OFLeaderboard_Sync*) getLeaderboardDetails:(NSString*)leaderboardId
{
	OFLeaderboard_Sync* leaderboard = nil;
	sGetLeaderboardQuery.bind("id", leaderboardId);
	sGetLeaderboardQuery.execute();
	if (sGetLeaderboardQuery.getLastStepResult() == SQLITE_ROW)
	{
		leaderboard = [[[OFLeaderboard_Sync alloc] initWithLocalSQL:&sGetLeaderboardQuery] autorelease];
	} 
	else 
	{
		NSLog(@"Definition for leaderboard %@ was not found", leaderboardId);
	}
	sGetLeaderboardQuery.resetQuery();
	return leaderboard;
}

+ (bool) hasLeaderboards
{
	sGetActiveLeaderboardsQuery.bind("app_version",[OFOfflineService getFormattedAppVersion]);
	sGetActiveLeaderboardsQuery.execute(); 
	bool hasActive = (sGetActiveLeaderboardsQuery.getLastStepResult() == SQLITE_ROW);
	sGetActiveLeaderboardsQuery.resetQuery();
	return hasActive;
}

+ (NSMutableArray*) getAggregateParents:(NSString*)leaderboardId
{
	NSMutableArray* leaderboards = [[NSMutableArray new] autorelease];
	
	sGetAggregateLeaderboardsQuery.bind("leaderboard_pushing_changes_id", leaderboardId);
	for (sGetAggregateLeaderboardsQuery.execute(); !sGetAggregateLeaderboardsQuery.hasReachedEnd(); sGetAggregateLeaderboardsQuery.step())
	{
		NSString* aggregateLeaderboardId = [NSString stringWithFormat:@"%s", sGetAggregateLeaderboardsQuery.getText("aggregate_leaderboard_id")];
		OFLeaderboard_Sync* leaderboard = [OFLeaderboardService getLeaderboardDetails:aggregateLeaderboardId];
		if (leaderboard != nil && leaderboard.active)
		{
			[leaderboards addObject:leaderboard];
		}
		else if(leaderboard == nil) 
		{
			NSLog(@"Definition for aggregate leaderboard %@ was not found", leaderboardId);
		}
	}
	sGetAggregateLeaderboardsQuery.resetQuery();
	
	return leaderboards;
}

@end
