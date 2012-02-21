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

#import "OFHighScoreService+Private.h"
#import "OFSqlQuery.h"
#import "OFReachability.h"
#import "OFActionRequestType.h"
#import "OFService+Private.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import <sqlite3.h>
#import "OFLeaderboardService+Private.h"
#import "OFHighScoreBatchEntry.h"
#import "OFHighScore.h"
#import "OFUser.h"
#import "OFUserService+Private.h"
#import "OFPaginatedSeries.h"
#import "OFOfflineService.h"
#import "OFLeaderboard+Sync.h";
#import "OFNotification.h";

namespace
{
	static OFSqlQuery sSetHighScoreQuery;
	static OFSqlQuery sPendingHighScoresQuery;
	static OFSqlQuery sScoreToKeepQuery;
	static OFSqlQuery sServerSynchQuery;
	static OFSqlQuery sDeleteScoresQuery;
	static OFSqlQuery sMakeOnlyOneSynchQuery;
	static OFSqlQuery sLastSynchQuery;
	static OFSqlQuery sGetHighScoresQuery;
	static OFSqlQuery sChangeNullUserQuery;
	static OFSqlQuery sNullUserHighScoresQuery;
	static OFSqlQuery sNullUserScoreToSynchInLeaderboardQuery;
	static OFSqlQuery sNullUserNoSynchInLeaderboardQuery;
}

@implementation OFHighScoreService (Private)

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
	sSetHighScoreQuery.destroyQueryNow();
	sPendingHighScoresQuery.destroyQueryNow();
	sScoreToKeepQuery.destroyQueryNow();
	sServerSynchQuery.destroyQueryNow();
	sDeleteScoresQuery.destroyQueryNow();
	sMakeOnlyOneSynchQuery.destroyQueryNow();
	sLastSynchQuery.destroyQueryNow();
	sGetHighScoresQuery.destroyQueryNow();
	sChangeNullUserQuery.destroyQueryNow();
	sNullUserHighScoresQuery.destroyQueryNow();
	sNullUserScoreToSynchInLeaderboardQuery.destroyQueryNow();
	sNullUserNoSynchInLeaderboardQuery.destroyQueryNow();
	[super dealloc];
}

+ (void) setupOfflineSupport:(bool)recreateDB
{
	if( recreateDB )
	{
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle],
			"DROP TABLE IF EXISTS high_scores"
			).execute();
	}
	
	//Special PG patch
	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle],
		"ALTER TABLE high_scores " 
		"ADD COLUMN display_text TEXT DEFAULT NULL",
		false
		).execute(false);
	//

	int highScoresVersion = [OFOfflineService getTableVersion:@"high_scores"];
	if (highScoresVersion == 1)
	{
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle],
			"ALTER TABLE high_scores " 
			"ADD COLUMN custom_data TEXT DEFAULT NULL"
			).execute();
	}
	else
	{
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle],
			"CREATE TABLE IF NOT EXISTS high_scores("
			"user_id INTEGER NOT NULL,"
			"leaderboard_id INTEGER NOT NULL,"
			"score INTEGER DEFAULT 0,"
			"display_text TEXT DEFAULT NULL,"
			"custom_data TEXT DEFAULT NULL,"
			"server_sync_at INTEGER DEFAULT NULL,"
			"UNIQUE(leaderboard_id, user_id, score))"
			).execute();
		
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle], 
			"CREATE INDEX IF NOT EXISTS high_scores_index "
			"ON high_scores (user_id, leaderboard_id)"
			).execute();
	}
	[OFOfflineService setTableVersion:@"high_scores" version:2];
	
	sSetHighScoreQuery.reset(
		[OpenFeint getOfflineDatabaseHandle], 
		"REPLACE INTO high_scores "
		"(user_id, leaderboard_id, score, display_text, custom_data, server_sync_at) "
		"VALUES(:user_id, :leaderboard_id, :score, :display_text, :custom_data, :server_sync_at)"
		);
	
	sPendingHighScoresQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT leaderboard_id, score, display_text, custom_data "
		"FROM high_scores "
		"WHERE user_id = :user_id AND "
		"server_sync_at IS NULL"
		);
	
	//for testing
	//OFSqlQuery([OpenFeint getOfflineDatabaseHandle], "UPDATE high_scores SET server_sync_at = NULL").execute();
	
	sScoreToKeepQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT min(score) AS score FROM "
		"(SELECT score FROM high_scores  "
		"WHERE user_id = :user_id AND "
		"leaderboard_id = :leaderboard_id "
		"ORDER BY score DESC LIMIT :max_scores) AS x"
		);

	sDeleteScoresQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"DELETE FROM high_scores  "
		"WHERE user_id = :user_id AND "
		"leaderboard_id = :leaderboard_id AND "
		"score < :score"
		);
	
	sMakeOnlyOneSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"UPDATE high_scores "
		"SET server_sync_at = :server_sync_at "
		"WHERE user_id = :user_id AND "
		"leaderboard_id = :leaderboard_id AND "
		"score != :score AND "
		"server_sync_at IS NULL"
		);

	sChangeNullUserQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"UPDATE high_scores "
		"SET user_id = :user_id "
		"WHERE user_id IS NULL or user_id = 0"
		);
	
	sNullUserHighScoresQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT * FROM high_scores "
		"WHERE (user_id IS NULL or user_id = 0) ORDER BY leaderboard_id"
		);
	
	sNullUserScoreToSynchInLeaderboardQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"UPDATE high_scores "
		"SET server_sync_at = strftime('%s', 'now') "
		"WHERE (user_id IS NULL or user_id = 0) AND score != :score AND leaderboard_id = :leaderboard_id"
		);
	
	sNullUserNoSynchInLeaderboardQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"UPDATE high_scores "
		"SET server_sync_at = strftime('%s', 'now') "
		"WHERE (user_id IS NULL or user_id = 0) AND leaderboard_id = :leaderboard_id"
		);
}

+ (bool) localSetHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId forUser:(NSString*)userId
{
	return [OFHighScoreService localSetHighScore:score forLeaderboard:leaderboardId forUser:userId displayText:nil serverDate:nil addToExisting:NO];
}

+ (bool) localSetHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId forUser:(NSString*)userId displayText:(NSString*)displayText serverDate:(NSDate*)serverDate addToExisting:(BOOL) addToExisting
{
	return [OFHighScoreService localSetHighScore:score forLeaderboard:leaderboardId forUser:userId displayText:displayText customData:nil serverDate:nil addToExisting:NO];
}

+ (bool) localSetHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId forUser:(NSString*)userId displayText:(NSString*)displayText customData:(NSString*)customData serverDate:(NSDate*)serverDate addToExisting:(BOOL) addToExisting
{
	return [OFHighScoreService localSetHighScore:score forLeaderboard:leaderboardId forUser:userId displayText:displayText customData:customData serverDate:serverDate addToExisting:addToExisting shouldSubmit:nil];
}

+ (bool) localSetHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId forUser:(NSString*)userId displayText:(NSString*)displayText customData:(NSString*)customData serverDate:(NSDate*)serverDate addToExisting:(BOOL) addToExisting shouldSubmit:(BOOL*)outShouldSubmit
{
	BOOL success = NO;
	BOOL shouldSubmitToServer = YES;
	OFLeaderboard_Sync* leaderboard = [OFLeaderboardService getLeaderboardDetails:leaderboardId];
	
	if (leaderboard && (!leaderboard.isAggregate || addToExisting))
	{
		NSString* serverSynch = nil;
		if( serverDate )
		{
			serverSynch = [NSString stringWithFormat:@"%d", (long)[serverDate timeIntervalSince1970]];
		}
		NSString*lastSyncDate = [OFLeaderboardService getLastSyncDateUnixForUserId:userId];
		int64_t previousScore = 0;
		BOOL hasPreviousScore = [OFHighScoreService getPreviousHighScoreLocal:&previousScore forLeaderboard:leaderboardId];
		if (addToExisting && hasPreviousScore)
			score =  previousScore + score;
		
		NSString* sScore = [NSString stringWithFormat:@"%qi", score];
		sSetHighScoreQuery.bind("user_id", userId);		
		sSetHighScoreQuery.bind("leaderboard_id", leaderboardId);
		sSetHighScoreQuery.bind("score", sScore);
		sSetHighScoreQuery.bind("display_text", displayText);
		sSetHighScoreQuery.bind("custom_data", customData);
		sSetHighScoreQuery.bind("server_sync_at", serverSynch);
		sSetHighScoreQuery.execute();
		success = (sSetHighScoreQuery.getLastStepResult() == SQLITE_OK);
		sSetHighScoreQuery.resetQuery();
		
		[self buildScoreToKeepQuery:leaderboard.descendingSortOrder];
		sScoreToKeepQuery.bind("leaderboard_id", leaderboardId);
		sScoreToKeepQuery.bind("user_id", userId);		
		sScoreToKeepQuery.execute();
		if( sScoreToKeepQuery.getLastStepResult() == SQLITE_ROW )
		{
			[self buildDeleteScoresQuery:leaderboard.descendingSortOrder];
			NSString* scoreToKeep = [NSString stringWithFormat:@"%qi", sScoreToKeepQuery.getInt64("keep_score")];
			sDeleteScoresQuery.bind("leaderboard_id", leaderboardId);
			sDeleteScoresQuery.bind("user_id", userId);		
			sDeleteScoresQuery.bind("score", scoreToKeep);		
			sDeleteScoresQuery.execute();
			sDeleteScoresQuery.resetQuery();
		}
		NSString* synchScore = leaderboard.allowPostingLowerScores ? sScore : [NSString stringWithFormat:@"%qi", sScoreToKeepQuery.getInt64("high_score")];
		sScoreToKeepQuery.resetQuery();
		
		//want only one pending score, but keep history of other scores
		sMakeOnlyOneSynchQuery.bind("leaderboard_id", leaderboardId);
		sMakeOnlyOneSynchQuery.bind("user_id", userId);		
		sMakeOnlyOneSynchQuery.bind("score", synchScore);
		sMakeOnlyOneSynchQuery.bind("server_sync_at", lastSyncDate);
		sMakeOnlyOneSynchQuery.execute();
		sMakeOnlyOneSynchQuery.resetQuery();

		//Is leaderboard part of an aggregate
		NSMutableArray* aggregateLeaderboards = [OFLeaderboardService getAggregateParents:leaderboardId];
		for (unsigned int i = 0; i < [aggregateLeaderboards count]; i++)
		{
			OFLeaderboard_Sync* parentLeaderboard = (OFLeaderboard_Sync*)[aggregateLeaderboards objectAtIndex:i];
			[OFHighScoreService localSetHighScore:(score - previousScore)
								   forLeaderboard:parentLeaderboard.resourceId
										  forUser:userId 
									  displayText:nil
									  customData:nil
									   serverDate:[NSDate date]
									addToExisting:YES];
			//[parentLeaderboard release];
		}
		
 		//@note allowPostingLowerScores actually means allow posting WORSE scores
		if (!leaderboard.allowPostingLowerScores && hasPreviousScore)
		{
			if ((leaderboard.descendingSortOrder && score <= previousScore) ||	// if higher is better and this new score is lower
				(!leaderboard.descendingSortOrder && score >= previousScore))	// or lower is better and this new score is higher
			{
				shouldSubmitToServer = NO;										// don't submit it to the server
			}
		}
	}

	if (outShouldSubmit != nil)
	{
		(*outShouldSubmit) = shouldSubmitToServer;
	}

	return success;
}

+ (bool) synchHighScore:(NSString*)userId
{
	sServerSynchQuery.bind("user_id", userId);	
	sServerSynchQuery.execute();
	bool success = (sServerSynchQuery.getLastStepResult() == SQLITE_OK);
	sServerSynchQuery.resetQuery();
	return success;
}

+ (void) sendPendingHighScores:(NSString*)userId silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	if ([OpenFeint isOnline] && userId != @"Invalid" && [userId longLongValue] > 0)
	{
		OFLeaderboard_Sync* nullUserLeaderboard = nil;
		int64_t leaderboardBestScore = 0;
		int64_t nullUserScore = 0;
		BOOL synchScoreInLeaderboard = NO;
		NSString* leaderboardId;
		sNullUserHighScoresQuery.execute(); 
		while (!sNullUserHighScoresQuery.hasReachedEnd() || synchScoreInLeaderboard)
		{
			if (!sNullUserHighScoresQuery.hasReachedEnd())
			{
				nullUserScore = sNullUserHighScoresQuery.getInt64("score");
				leaderboardId = [NSString stringWithFormat:@"%d", sNullUserHighScoresQuery.getInt("leaderboard_id")];
			}
			if( nullUserLeaderboard == nil || ![nullUserLeaderboard.resourceId isEqualToString: leaderboardId] || sNullUserHighScoresQuery.hasReachedEnd() )
			{
				if (nullUserLeaderboard != nil)
				{
					if (synchScoreInLeaderboard)
					{
						sNullUserScoreToSynchInLeaderboardQuery.bind("score", [NSString stringWithFormat:@"%qi", leaderboardBestScore]);
						sNullUserScoreToSynchInLeaderboardQuery.bind("leaderboard_id", nullUserLeaderboard.resourceId);
						sNullUserScoreToSynchInLeaderboardQuery.execute();
						sNullUserScoreToSynchInLeaderboardQuery.resetQuery();
					}
					else
					{
						sNullUserNoSynchInLeaderboardQuery.bind("leaderboard_id", nullUserLeaderboard.resourceId);
						sNullUserNoSynchInLeaderboardQuery.execute();
						sNullUserNoSynchInLeaderboardQuery.resetQuery();
					}
				}

				nullUserLeaderboard = [OFLeaderboardService getLeaderboardDetails:leaderboardId];
				[OFHighScoreService getPreviousHighScoreLocal:&leaderboardBestScore forLeaderboard:leaderboardId];
				synchScoreInLeaderboard = NO;
			}
			
			if (!sNullUserHighScoresQuery.hasReachedEnd())
			{
				BOOL nullScoreBetter = (nullUserLeaderboard.descendingSortOrder ? nullUserScore > leaderboardBestScore : nullUserScore < leaderboardBestScore);
				if (nullScoreBetter)
				{
					leaderboardBestScore = nullUserScore;
					synchScoreInLeaderboard = YES;
				}
				sNullUserHighScoresQuery.step();
			}
		}
		sNullUserHighScoresQuery.resetQuery();

		//associate any offline high scores to user
		sChangeNullUserQuery.bind("user_id", userId);
		sChangeNullUserQuery.execute();
		sChangeNullUserQuery.resetQuery();
				
		OFHighScoreBatchEntrySeries pendingHighScores;
		
		sPendingHighScoresQuery.bind("user_id", userId);
		for (sPendingHighScoresQuery.execute(); !sPendingHighScoresQuery.hasReachedEnd(); sPendingHighScoresQuery.step())
		{
			OFHighScoreBatchEntry *highScore = new OFHighScoreBatchEntry();
			highScore->leaderboardId = [NSString stringWithFormat:@"%d", sPendingHighScoresQuery.getInt("leaderboard_id")];
			highScore->score = sPendingHighScoresQuery.getInt64("score");
			const char* cDisplayText = sPendingHighScoresQuery.getText("display_text");
			if( cDisplayText != nil )
				highScore->displayText = [NSString stringWithUTF8String:cDisplayText];
			const char* cCustomData = sPendingHighScoresQuery.getText("custom_data");
			if( cCustomData != nil )
				highScore->customData = [NSString stringWithUTF8String:cCustomData];
			pendingHighScores.push_back(highScore);
		}
		sPendingHighScoresQuery.resetQuery();
		
		if (pendingHighScores.size() > 0)
		{
			OFDelegate chainedSuccessDelegate([OFHighScoreService sharedInstance], @selector(_onSetHighScore:nextCall:), onSuccess);

			if (false) //(!silently)
			{
				OFNotificationData* notice = [OFNotificationData dataWithText:[NSString stringWithFormat:@"Submitted %i Score%s", pendingHighScores.size(), pendingHighScores.size() > 1 ? "" : "s"] andCategory:kNotificationCategoryLeaderboard andType:kNotificationTypeSuccess];
				[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusSuccess andInputResponse:nil];
			}
			
			[OFHighScoreService 
			     batchSetHighScores:pendingHighScores
			     silently:YES
				 onSuccess:chainedSuccessDelegate
				 onFailure:onFailure
			     optionalMessage: nil
			 ];
		}
	}
}

+ (BOOL) getPreviousHighScoreLocal:(int64_t*)score forLeaderboard:(NSString*)leaderboardId
{
	OFLeaderboard_Sync* leaderboard = [OFLeaderboardService getLeaderboardDetails:leaderboardId];
	[self buildGetHighScoresQuery:leaderboard.descendingSortOrder limit:1];
	sGetHighScoresQuery.bind("leaderboard_id", leaderboardId);
	sGetHighScoresQuery.bind("user_id", [OpenFeint localUser].resourceId);
	sGetHighScoresQuery.execute(); 
	
	BOOL foundScore = NO;
	int64_t scoreToReturn = 0;	// for historical reasons we're going to set 'score' to 0 even if we don't have a score
	if (!sGetHighScoresQuery.hasReachedEnd())
	{
		foundScore = YES;
		scoreToReturn = sGetHighScoresQuery.getInt64("score");
	}
	sGetHighScoresQuery.resetQuery();
	
	if (score != nil)
	{
		(*score) = scoreToReturn;
	}

	return foundScore;
}

+ (void) getHighScoresLocal:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	NSMutableArray* highScores = [[NSMutableArray new] autorelease];
	
	OFLeaderboard_Sync* leaderboard = [OFLeaderboardService getLeaderboardDetails:leaderboardId];
	[self buildGetHighScoresQuery:leaderboard.descendingSortOrder limit:10];
	sGetHighScoresQuery.bind("leaderboard_id", leaderboardId);
	sGetHighScoresQuery.bind("user_id", [OpenFeint localUser].resourceId);
	NSUInteger rank = 0;
	for (sGetHighScoresQuery.execute(); !sGetHighScoresQuery.hasReachedEnd(); sGetHighScoresQuery.step())
	{
		OFUser* user = [OFUserService getLocalUser:[NSString stringWithFormat:@"%s", sGetHighScoresQuery.getText("user_id")]];
		[highScores addObject:[[[OFHighScore alloc] initWithLocalSQL:&sGetHighScoresQuery forUser:user rank:++rank] autorelease]];
	}
	sGetHighScoresQuery.resetQuery();
	
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeriesFromArray:highScores];
	onSuccess.invoke(page);
}

+ (OFHighScore*)getHighScoreForUser:(OFUser*)user leaderboardId:(NSString*)leaderboardId descendingSortOrder:(bool)descendingSortOrder
{
	[self buildGetHighScoresQuery:descendingSortOrder limit:1];
	sGetHighScoresQuery.bind("leaderboard_id", leaderboardId);
	sGetHighScoresQuery.bind("user_id", user.resourceId);
	sGetHighScoresQuery.execute(); 
	OFHighScore* highScore = !sGetHighScoresQuery.hasReachedEnd() ? [[[OFHighScore alloc] initWithLocalSQL:&sGetHighScoresQuery forUser:user rank:1] autorelease] : nil;
	sGetHighScoresQuery.resetQuery();
	return highScore;
}

+ (void) buildGetHighScoresQuery:(bool)descendingOrder limit:(int)limit
{
	NSMutableString* query = [[[NSMutableString alloc] initWithString:@"SELECT * FROM high_scores WHERE leaderboard_id = :leaderboard_id AND user_id = :user_id ORDER BY score "] autorelease];
	NSString* orderClause = (descendingOrder ? @"DESC" : @"ASC");
	[query appendString:orderClause];
	[query appendString:[NSString stringWithFormat:@" LIMIT %i", limit]];
	sGetHighScoresQuery.reset( [OpenFeint getOfflineDatabaseHandle], [query UTF8String] );
}

+ (void) buildScoreToKeepQuery:(bool)descendingOrder
{
	//Book keeping save top 10 scores
	NSMutableString* query = [[[NSMutableString alloc] initWithString:@"SELECT "] autorelease];
	NSString* scoreClause = (descendingOrder ? @"min" : @"max");
	[query appendString:scoreClause];
	[query appendString:@"(x.score) AS keep_score, "];
	scoreClause = (descendingOrder ? @"max" : @"min");
	[query appendString:scoreClause];
	[query appendString:@"(x.score) AS high_score FROM (SELECT score FROM high_scores WHERE user_id = :user_id AND leaderboard_id = :leaderboard_id ORDER BY score "];
	NSString* orderClause = (descendingOrder ? @"DESC" : @"ASC");
	[query appendString:orderClause];
	[query appendString:@" LIMIT 10) AS x"];
	sScoreToKeepQuery.reset( [OpenFeint getOfflineDatabaseHandle], [query UTF8String]);
}

+ (void) buildDeleteScoresQuery:(bool)descendingOrder
{
	NSMutableString* query =[[[NSMutableString alloc] initWithString:@"DELETE FROM high_scores WHERE user_id = :user_id AND leaderboard_id = :leaderboard_id AND score "] autorelease];
	NSString* comparison = (descendingOrder ? @"<" : @">");
	[query appendString:comparison];
	[query appendString:@" :score"];
	sDeleteScoresQuery.reset([OpenFeint getOfflineDatabaseHandle], [query UTF8String]);
}

@end
