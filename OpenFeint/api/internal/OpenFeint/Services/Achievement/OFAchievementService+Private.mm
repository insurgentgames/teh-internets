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
#import "OFAchievementService+Private.h"
#import "OFDependencies.h"
#import "OFAchievement.h"
#import "OFSqlQuery.h"
#import "OFReachability.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFActionRequestType.h"
#import "OFService+Private.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import <sqlite3.h>
#import "OFPaginatedSeries.h"
#import "OFOfflineService.h"
#import "OFUser.h"

namespace
{
	static OFSqlQuery sUnlockQuery;
	static OFSqlQuery sPendingUnlocksQuery;
	static OFSqlQuery sDeleteRowQuery;
	static OFSqlQuery sAlreadyUnlockedQuery;
	static OFSqlQuery sServerSynchQuery;
	static OFSqlQuery sAchievementDefSynchQuery;
	static OFSqlQuery sLastSynchQuery;
	static OFSqlQuery sGetUnlockedAchievementsQuery;
	static OFSqlQuery sGetAchievementsQuery;
	static OFSqlQuery sGetAchievementDefQuery;
	static OFSqlQuery sChangeNullUserQuery;
}

@implementation OFAchievementService (Private)

- (id) init
{
	self = [super init];
	
	if (self != nil)
	{
		//[OFAchievementService setupOfflineSupport];
	}
	
	return self;
}

- (void) dealloc
{
	sUnlockQuery.destroyQueryNow();
	sPendingUnlocksQuery.destroyQueryNow();
	sDeleteRowQuery.destroyQueryNow();
	sAlreadyUnlockedQuery.destroyQueryNow();
	sServerSynchQuery.destroyQueryNow();
	sAchievementDefSynchQuery.destroyQueryNow();
	sLastSynchQuery.destroyQueryNow();
	sGetUnlockedAchievementsQuery.destroyQueryNow();
	sGetAchievementsQuery.destroyQueryNow();
	sGetAchievementDefQuery.destroyQueryNow();
	sChangeNullUserQuery.destroyQueryNow();
	[super dealloc];
}

+ (void) setupOfflineSupport:(bool)recreateDB
{
	bool oldSchema = false;
	//Check for latest DB schema
	if( !recreateDB )
	{
		oldSchema = ([OFOfflineService getTableVersion:@"unlocked_achievements"] == 1);
	}
	
	if( recreateDB || oldSchema )
	{
		//Doesn't have new table schema, so create it.
		if( oldSchema )
		{
			OFSqlQuery(
				[OpenFeint getOfflineDatabaseHandle], 
				"DROP TABLE IF EXISTS unlocked_achievements_save"
				).execute();
			
		    OFSqlQuery(
				[OpenFeint getOfflineDatabaseHandle], 
				"CREATE TABLE unlocked_achievements_save "
				"AS SELECT * FROM unlocked_achievements",
				false
				).execute(false);
		}
		
		OFSqlQuery(
				   [OpenFeint getOfflineDatabaseHandle], 
				   "DROP TABLE IF EXISTS unlocked_achievements"
				   ).execute();
		
		OFSqlQuery(
				   [OpenFeint getOfflineDatabaseHandle], 
				   "DROP TABLE IF EXISTS achievement_definitions"
				   ).execute();
	}
		
	OFSqlQuery(
			   [OpenFeint getOfflineDatabaseHandle],
			   "CREATE TABLE IF NOT EXISTS unlocked_achievements("
			   "user_id INTEGER NOT NULL,"
			   "achievement_definition_id INTEGER NOT NULL,"
			   "gamerscore INTEGER DEFAULT 0,"
			   "created_at INTEGER DEFAULT NULL,"
			   "server_sync_at INTEGER DEFAULT NULL)"
			   ).execute();
	
	OFSqlQuery(
			   [OpenFeint getOfflineDatabaseHandle], 
			   "CREATE UNIQUE INDEX IF NOT EXISTS unlocked_achievements_index "
			   "ON unlocked_achievements (achievement_definition_id, user_id)"
			   ).execute();
	
	[OFOfflineService setTableVersion:@"unlocked_achievements" version:2];
	
	int achievementDefinitionVersion = [OFOfflineService getTableVersion:@"achievement_definitions"];
	if( achievementDefinitionVersion == 0)
	{
		OFSqlQuery(
			   [OpenFeint getOfflineDatabaseHandle],
			   "CREATE TABLE IF NOT EXISTS achievement_definitions(" 
			   "id INTEGER NOT NULL,"
			   "title TEXT DEFAULT NULL,"
			   "description TEXT DEFAULT NULL,"
			   "gamerscore  INTEGER DEFAULT 0,"
			   "is_secret INTEGER DEFAULT 0,"
			   "icon_file_name TEXT DEFAULT NULL,"
			   "position INTEGER DEFAULT 0,"
			   "start_version  TEXT DEFAULT NULL,"
			   "end_version  TEXT DEFAULT NULL,"
			   "server_sync_at INTEGER DEFAULT NULL)"
			   ).execute();
		
		OFSqlQuery(
		   [OpenFeint getOfflineDatabaseHandle], 
		   "CREATE UNIQUE INDEX IF NOT EXISTS achievement_definitions_index "
		   "ON achievement_definitions (id)"
		   ).execute();
	}
	else
	{
		if( achievementDefinitionVersion == 1)
		{
			OFSqlQuery(
				   [OpenFeint getOfflineDatabaseHandle],
				   "ALTER TABLE achievement_definitions " 
				   "ADD COLUMN start_version  TEXT DEFAULT NULL"
				   ).execute();
		
			OFSqlQuery(
				   [OpenFeint getOfflineDatabaseHandle],
				   "ALTER TABLE achievement_definitions " 
				   "ADD COLUMN end_version  TEXT DEFAULT NULL"
				   ).execute();
		}
		if( achievementDefinitionVersion != 3 )
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle],
			"ALTER TABLE achievement_definitions " 
			"ADD COLUMN position INT DEFAULT 0"
			).execute();
	}
	[OFOfflineService setTableVersion:@"achievement_definitions" version:3];
	
	
	if( oldSchema )
	{
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle], 
			"INSERT INTO unlocked_achievements "
			"(user_id, achievement_definition_id,created_at) "
			"SELECT user_id, achievement_definition_id, strftime('%s', 'now') FROM unlocked_achievements_save",
			false
			).execute(false);
		
		OFSqlQuery(
			[OpenFeint getOfflineDatabaseHandle], 
			"DROP TABLE IF EXISTS unlocked_achievements_save"
			).execute();
	}

	//for testing
	//OFSqlQuery([OpenFeint getOfflineDatabaseHandle], "UPDATE unlocked_achievements SET server_sync_at = NULL").execute();

	//queries needed for offline achievement support
	sUnlockQuery.reset(
		[OpenFeint getOfflineDatabaseHandle], 
		"REPLACE INTO unlocked_achievements "
		"(achievement_definition_id, user_id, created_at) "
		"VALUES(:achievement_definition_id, :user_id, strftime('%s', 'now'))"
		);
	
	sPendingUnlocksQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT achievement_definition_id "
		"FROM unlocked_achievements "
		"WHERE user_id = :user_id AND "
		"server_sync_at IS NULL"
		);
	
	sAlreadyUnlockedQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT count(*) as unlocked "
		"FROM unlocked_achievements "
		"WHERE user_id = :user_id AND "
		"achievement_definition_id = :achievement_definition_id"
		);
	
	sServerSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"REPLACE INTO unlocked_achievements "
		"(user_id, achievement_definition_id, gamerscore, created_at, server_sync_at) "
		"VALUES (:user_id, :achievement_definition_id, :gamerscore, :server_sync_at, :server_sync_at)"
		);

	sGetAchievementsQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT * FROM achievement_definitions ORDER BY position"
		);
		
	sGetAchievementDefQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT *, 0 AS unlocked_date FROM achievement_definitions WHERE id = :id"
		);
	
	sDeleteRowQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"DELETE FROM unlocked_achievements "
		"WHERE user_id = :user_id AND "
		"achievement_definition_id = :achievement_definition_id"
		);
	
	sAchievementDefSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"REPLACE INTO achievement_definitions "
		"(id, title, description, gamerscore, is_secret, icon_file_name, position, start_version, end_version, server_sync_at) "
		"VALUES (:id , :title , :description , :gamerscore , :is_secret , :icon_file_name, :position, :start_version, :end_version, strftime('%s', 'now'))"
		);	

  	sLastSynchQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT datetime(MAX(server_sync_at), 'unixepoch') as last_sync_date FROM "
		"(SELECT MIN(server_sync_at) AS server_sync_at FROM "
		"(SELECT MAX(server_sync_at) AS server_sync_at FROM "
		"(SELECT MAX(server_sync_at) AS server_sync_at FROM unlocked_achievements WHERE user_id = :user_id AND server_sync_at IS NOT NULL UNION SELECT 0 AS server_sync_at) X "
		"UNION SELECT MAX(server_sync_at) AS server_sync_at FROM achievement_definitions WHERE server_sync_at IS NOT NULL) Y ) Z"
		);
	
	sGetUnlockedAchievementsQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"select defs.*, unlocked_achievements.created_at AS unlocked_date "
		"FROM (select * from achievement_definitions WHERE start_version <= :app_version AND end_version >= :app_version) AS defs "
		"LEFT JOIN unlocked_achievements ON unlocked_achievements.achievement_definition_id = defs.id "
		"AND unlocked_achievements.user_id = :user_id "
		"ORDER BY unlocked_achievements.created_at DESC, position ASC, defs.id ASC"
		);
	
	sChangeNullUserQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"UPDATE unlocked_achievements "
		"SET user_id = :user_id "
		"WHERE user_id IS NULL or user_id = 0"
		);
}

- (void) _successfullyCommittedAchievementsWithIgnoredResources:(NSArray*)resources andAchievements:(NSArray*)achievementIdList
{
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	sServerSynchQuery.bind("user_id", lastLoggedInUser);
	
	for (NSString* achievementId in achievementIdList)
	{
		sServerSynchQuery.bind("achievement_definition_id", achievementId);
		sServerSynchQuery.execute();
	}
	sServerSynchQuery.resetQuery();
}

+ (void) sendPendingAchievements:(NSString*)userId syncOnly:(BOOL)syncOnly onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	//NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	if ([OpenFeint isOnline] && [userId longLongValue] > 0)
	{
		//associate any offline achievements to user
		sChangeNullUserQuery.bind("user_id", userId);
		sChangeNullUserQuery.execute();
		sChangeNullUserQuery.resetQuery();
		
		NSMutableArray* achievementIdList = [[NSMutableArray new] autorelease];
		
		sPendingUnlocksQuery.bind("user_id", userId);
		for (sPendingUnlocksQuery.execute(); !sPendingUnlocksQuery.hasReachedEnd(); sPendingUnlocksQuery.step())
		{
			NSString* achievementId = [NSString stringWithFormat:@"%d", sPendingUnlocksQuery.getInt("achievement_definition_id")];
			[achievementIdList addObject:achievementId];
		}
		sPendingUnlocksQuery.resetQuery();

		if ([achievementIdList count] > 0)
		{
			OFDelegate chainedSuccessDelegate([OFAchievementService sharedInstance], @selector(_onAchievementUnlockedFromBatch:nextCall:), onSuccess);
			OFDelegate chainedSuccessSyncDelegate([OFAchievementService sharedInstance], @selector(_onAchievementUnlockedDuringSync:nextCall:), onSuccess);
			//OFDelegate chainedFailedDelegate([OFAchievementService sharedInstance], @selector(_onAchievementFailed:nextCall:), onFailure);
			
			[OFAchievementService unlockAchievements:achievementIdList onSuccess:(syncOnly ? chainedSuccessSyncDelegate : chainedSuccessDelegate) onFailure:onFailure];
		}
	}
}

+ (bool) localUnlockAchievement:(NSString*)achievementId forUser:(NSString*)userId
{
	sGetAchievementDefQuery.bind("id", achievementId);
	sGetAchievementDefQuery.execute();
	int gamerscore = sGetAchievementDefQuery.getInt("gamerscore");	
	if (gamerscore > 0)
	{
		OFUser* localUser = [OpenFeint localUser];
		[localUser adjustGamerscore:gamerscore];
		[OpenFeint setLocalUser:localUser];
	}
	sGetAchievementDefQuery.resetQuery();

	sUnlockQuery.bind("achievement_definition_id", achievementId);
	sUnlockQuery.bind("user_id", userId);		
	sUnlockQuery.execute();
	bool success = (sUnlockQuery.getLastStepResult() == SQLITE_OK);
	sUnlockQuery.resetQuery();
	
	return success;
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

+ (void) unlockAchievements:(NSArray*)achievementIdList onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	{
		OFISerializer::Scope high_score(params, "achievement_list", true);
		
		for (NSString* achievementId in achievementIdList)
		{
			OFISerializer::Scope high_score(params, "achievement");
			OFRetainedPtr<NSString> resourceId = achievementId;
			params->io("achievement_definition_id", resourceId);		
		}
	}
	
	[[self sharedInstance] 
	 postAction:@"users/@me/unlocked_achievements.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:[OFNotificationData dataWithText:@"Submitted Unlocked Achivements" andCategory:kNotificationCategoryAchievement andType:kNotificationTypeSubmitting]];
}

+ (bool) alreadyUnlockedAchievement:(NSString*)achievementId forUser:(NSString*)userId
{
	sAlreadyUnlockedQuery.bind("achievement_definition_id", achievementId);
	sAlreadyUnlockedQuery.bind("user_id", userId);		
	sAlreadyUnlockedQuery.execute();
	bool unlocked = (sAlreadyUnlockedQuery.getInt("unlocked") > 0);
	sAlreadyUnlockedQuery.resetQuery();
	return unlocked;
}

+ (bool) synchUnlockedAchievement:(NSString*)achievementId forUser:(NSString*)userId gamerScore:(NSString*)gamerScore serverDate:(NSDate*)serverDate
{
	NSString* serverSynch = [NSString stringWithFormat:@"%d", (long)[serverDate timeIntervalSince1970]];
	sServerSynchQuery.bind("achievement_definition_id", achievementId);
	sServerSynchQuery.bind("user_id", userId);
	sServerSynchQuery.bind("gamerscore", gamerScore);
	sServerSynchQuery.bind("server_sync_at", serverSynch);
	sServerSynchQuery.execute();
	bool success = (sServerSynchQuery.getLastStepResult() == SQLITE_OK);
	sServerSynchQuery.resetQuery();
	return success;
}

+ (void)synchAchievementsList:(NSArray*)achievements forUser:(NSString*)userId
{
	unsigned int achievementCnt = [achievements count];
	OFSqlQuery([OpenFeint getOfflineDatabaseHandle],"BEGIN TRANSACTION").execute();
	for (unsigned int i = 0; i < achievementCnt; i++)
	{
		OFAchievement* achievement = [achievements objectAtIndex:i];
		
		//update or add achievement definition as needed
		 sAchievementDefSynchQuery.bind("id", achievement.resourceId);
		 sAchievementDefSynchQuery.bind("title", achievement.title);
		 sAchievementDefSynchQuery.bind("description", achievement.description);
		 sAchievementDefSynchQuery.bind("gamerscore", [NSString stringWithFormat:@"%d", achievement.gamerscore]);
		 sAchievementDefSynchQuery.bind("is_secret", [NSString stringWithFormat:@"%d", (achievement.isSecret? 1 : 0)]);
		 sAchievementDefSynchQuery.bind("position", [NSString stringWithFormat:@"%d", achievement.position]);
		 sAchievementDefSynchQuery.bind("icon_file_name", achievement.iconUrl);
		 sAchievementDefSynchQuery.bind("start_version", achievement.startVersion);
		 sAchievementDefSynchQuery.bind("end_version", achievement.endVersion);
		 sAchievementDefSynchQuery.execute();
		 sAchievementDefSynchQuery.resetQuery();

		//add user achievements as need 
		if (achievement.isUnlocked) 
		{
			[OFAchievementService 
			 synchUnlockedAchievement:achievement.resourceId
			 forUser:userId
			 gamerScore:[NSString stringWithFormat:@"%d", achievement.gamerscore]
			 serverDate:achievement.unlockDate];
		}
	}
	OFSqlQuery([OpenFeint getOfflineDatabaseHandle],"COMMIT").execute();
}

+ (void) getAchievementsLocal:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure 
{
	NSMutableArray* achievements = [[NSMutableArray new] autorelease];
	
	sGetUnlockedAchievementsQuery.bind("app_version", [OFOfflineService getFormattedAppVersion]);
	sGetUnlockedAchievementsQuery.bind("user_id", [OpenFeint lastLoggedInUserId]);
	for (sGetUnlockedAchievementsQuery.execute(); !sGetUnlockedAchievementsQuery.hasReachedEnd(); sGetUnlockedAchievementsQuery.step())
	{
		[achievements addObject:[[[OFAchievement alloc] initWithLocalSQL:&sGetUnlockedAchievementsQuery] autorelease]];
	}
	sGetUnlockedAchievementsQuery.resetQuery();
	
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeriesFromArray:achievements];
	onSuccess.invoke(page);
}

+ (bool) hasAchievements
{
	sGetAchievementsQuery.execute(); 
	bool hasActive = (sGetAchievementsQuery.getLastStepResult() == SQLITE_ROW);
	sGetAchievementsQuery.resetQuery();
	return hasActive;
}

+ (OFAchievement*) getAchievement:(NSString*)achievementId
{
	sGetAchievementDefQuery.bind("id", achievementId);
	OFAchievement* achievement = nil;
	sGetAchievementDefQuery.execute();
	if (sGetAchievementDefQuery.getLastStepResult() == SQLITE_ROW)
	{
		achievement = [[[OFAchievement alloc] initWithLocalSQL:&sGetAchievementDefQuery] autorelease];
	}
	sGetAchievementDefQuery.resetQuery();
	return achievement;
}

@end
