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
#import "OFOfflineService.h"
#import "OFService+Private.h"
#import "OpenFeint+Private.h"
#import "OpenFeint.h"
#import "OFAchievement.h"
#import "OFUnlockedAchievement.h"
#import "OFAchievementService+Private.h"
#import "OFHighScore.h"
#import "OFHighScoreService+Private.h"
#import "OFLeaderboard+Sync.h"
#import "OFLeaderboardService.h"
#import "OFLeaderboardService+Private.h"
#import "OFLeaderboardAggregation.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFUserService+Private.h"
#import "OpenFeint+Dashboard.h"
#import "OFXmlDocument.h"
#import "OFResource.h"
#import "OFGameProfilePageInfo.h"
#import "OFBootstrap.h"
#import "OFUser.h"
#import "OpenFeint+UserOptions.h"
#import "OFSettings.h"
#import <sqlite3.h>

static NSString* formattedAppVersion;

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFOfflineService)

namespace
{
	static OFSqlQuery sSchemaVersionQuery;
	static OFSqlQuery sSetSchemaVersionQuery;
}

@implementation OFOfflineService

OPENFEINT_DEFINE_SERVICE(OFOfflineService)

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		[OpenFeint setupOfflineDatabase];
		[OFOfflineService setupOfflineSupport];

		//Look for offline configuration file
		NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:"openfeint_offline_config"] ofType:@"xml"];
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
		{
			
			int readInDate = [OFOfflineService getTableVersion:@"offline_config_file_date"];
			int lastModifiedDate = [[[[NSFileManager defaultManager]
									   attributesOfItemAtPath:filePath error:NULL] fileModificationDate] 
									 timeIntervalSince1970];
			
			if( readInDate != lastModifiedDate )
			{
				OFPaginatedSeries* offlineResouces = [OFResource resourcesFromXml:[OFXmlDocument xmlDocumentWithData:[NSData dataWithContentsOfFile:filePath]] withMap:[self getKnownResources]];
				
				for (id obj in offlineResouces)
				{
					if ([obj isKindOfClass:[OFOffline class]])
					{
						OFOffline* offline = (OFOffline*)obj;
						[OFLeaderboardService synchLeaderboardsList:offline.leaderboards aggregateLeaderboards:offline.leaderboardAggregations forUser:nil setSynchTime:NO];
					}
					else if ([obj isKindOfClass:[OFGameProfilePageInfo class]])
					{
						OFGameProfilePageInfo* profileInfo = (OFGameProfilePageInfo*)obj;
						[OpenFeint setLocalGameProfileInfo:profileInfo];
					}
				}
				[OFOfflineService setTableVersion:@"offline_config_file_date" version:lastModifiedDate];
			}
		}
	}
	return self;
}

- (void) dealloc
{
	if (formattedAppVersion)
		OFSafeRelease(formattedAppVersion);
	sSchemaVersionQuery.destroyQueryNow();
	sSetSchemaVersionQuery.destroyQueryNow();
	[OpenFeint teardownOfflineDatabase];
	[super dealloc];
}

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	[OFOfflineService shareKnownResources:namedResources];
}

+ (void) shareKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFGameProfilePageInfo getResourceName], [OFGameProfilePageInfo class]);
	namedResources->addResource([OFOffline getResourceName], [OFOffline class]);
	namedResources->addResource([OFAchievement getResourceName], [OFAchievement class]);
	namedResources->addResource([OFUnlockedAchievement getResourceName], [OFUnlockedAchievement class]);
	namedResources->addResource([OFHighScore getResourceName], [OFHighScore class]);
	namedResources->addResource([OFLeaderboard_Sync getResourceName], [OFLeaderboard_Sync class]);
	namedResources->addResource([OFLeaderboardAggregation getResourceName], [OFLeaderboardAggregation class]);
	namedResources->addResource([OFUser getResourceName], [OFUser class]);
}

+ (void) setupOfflineSupport
{
	//OFSqlQuery([OpenFeint getOfflineDatabaseHandle], "DROP TABLE IF EXISTS table_versions").execute();
		
	OFSqlQuery(
		[OpenFeint getOfflineDatabaseHandle],
		"CREATE TABLE IF NOT EXISTS table_versions("
		"name TEXT NOT NULL,"
 	    "version INTEGER NOT NULL,"
		"UNIQUE(name))"
	    ).execute();


	sSchemaVersionQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"SELECT * FROM table_versions "
		"WHERE name = :name"
		);

	sSetSchemaVersionQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"REPLACE INTO table_versions "
		"(name, version) values "
		"(:name, :version)" 
		);
	
	[OFOfflineService setTableVersion:@"table_versions" version:1];
	
	//This is needed because of the orginal online functionality
	//had an unlocked_achievements table
	OFSqlQuery sUnlockAchievementsTableQuery;
	sUnlockAchievementsTableQuery.reset(
		[OpenFeint getOfflineDatabaseHandle],
		"INSERT INTO table_versions "
		"(name, version) values "
		"('unlocked_achievements', 1)"
		);
	sUnlockAchievementsTableQuery.execute();
	sUnlockAchievementsTableQuery.destroyQueryNow();
	
	bool recreateDB = false; //ask about compile flag
	[OFAchievementService setupOfflineSupport:recreateDB];
	[OFHighScoreService setupOfflineSupport:recreateDB];
	[OFLeaderboardService setupOfflineSupport:recreateDB];
	[OFUserService setupOfflineSupport:recreateDB];
}

+ (void) syncOfflineData:(OFOffline*)offline bootStrap:(OFBootstrap*)bootStrap;
{
	[OFUserService createLocalUser:bootStrap.user.resourceId userName:bootStrap.user.name profilePictureUrl:bootStrap.user.profilePictureUrl];
	[OFAchievementService synchAchievementsList:offline.achievements forUser:bootStrap.user.resourceId];
	[OFLeaderboardService synchLeaderboardsList:offline.leaderboards aggregateLeaderboards:offline.leaderboardAggregations forUser:bootStrap.user.resourceId setSynchTime:YES];
}

- (void) sendPendingData:(NSString*)userId
{
	[OFAchievementService sendPendingAchievements:userId syncOnly:YES onSuccess:OFDelegate() onFailure:OFDelegate()];
	[OFHighScoreService sendPendingHighScores:userId silently:YES onSuccess:OFDelegate() onFailure:OFDelegate()];
}

+ (void) getBootstrapCallParams:(OFHttpNestedQueryStringWriter*)params userId:(NSString*)userId
{
	params->io("achievements_sync_date", [OFAchievementService getLastSyncDateForUserId:userId]);
	params->io("leaderboards_sync_date", [OFLeaderboardService getLastSyncDateForUserId:userId]);
}

+ (int) getTableVersion:(NSString*) tableName
{
	int version = 0;
	sSchemaVersionQuery.bind("name", tableName);
	sSchemaVersionQuery.execute();
	if (sSchemaVersionQuery.getLastStepResult() == SQLITE_ROW) {
		version = sSchemaVersionQuery.getInt("version");
	}
	sSchemaVersionQuery.resetQuery();

	return version;
}

+ (bool) setTableVersion:(NSString*)tableName version:(int) version
{
	sSetSchemaVersionQuery.bind("name", tableName);
	sSetSchemaVersionQuery.bind("version", [NSString stringWithFormat:@"%d", version]);
	sSetSchemaVersionQuery.execute();
	bool success =  (sSetSchemaVersionQuery.getLastStepResult() == SQLITE_OK);
	sSetSchemaVersionQuery.resetQuery();
	return success;
}

+ (NSString*) getFormattedAppVersion
{
	if (!formattedAppVersion) 
	{
		//format the client application version
		NSArray *parts = [OFSettings::Instance()->getClientBundleVersion() componentsSeparatedByString: @"."];
		int partCount = [parts count];
		int vMajor = (partCount > 0 ? [[parts objectAtIndex:0] integerValue]: 0);
		int vMinor = (partCount > 1 ? [[parts objectAtIndex:1] integerValue]: 0);
		int vPatch = (partCount > 2 ? [[parts objectAtIndex:2] integerValue]: 0);
		formattedAppVersion = [[NSString stringWithFormat:@"%04i.%02i.%02i", vMajor, vMinor, vPatch] retain];
	}
	
	return formattedAppVersion;
}
@end
