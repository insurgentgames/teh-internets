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

#import "OFUserService+Private.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OFSqlQuery.h"
#import "OFOfflineService.h"
#import <sqlite3.h>

namespace
{
	static OFSqlQuery sCreateUserQuery;
	static OFSqlQuery sGetUserQuery;
}

@implementation OFUserService (Private)

- (id) init
{
	self = [super init];
	
	if (self != nil)
	{
	}
	
	return self;
}

- (void) dealloc
{
	sCreateUserQuery.destroyQueryNow();
	sGetUserQuery.destroyQueryNow();
	[super dealloc];
}


+ (void) setupOfflineSupport:(bool)recreateDB
{
	if( recreateDB )
	{
		OFSqlQuery(
				   [OpenFeint getOfflineDatabaseHandle],
				   "DROP TABLE IF EXISTS users"
				   ).execute();
	}
	OFSqlQuery(
			   [OpenFeint getOfflineDatabaseHandle],
			   "CREATE TABLE IF NOT EXISTS users("
			   "id INTEGER NOT NULL,"
			   "name TEXT DEFAULT NULL,"
			   "profile_picture_url TEXT DEFAULT NULL)"
			   ).execute();
	OFSqlQuery(
			   [OpenFeint getOfflineDatabaseHandle], 
			   "CREATE UNIQUE INDEX IF NOT EXISTS users_index "
			   "ON users (id)"
			   ).execute();
	
	[OFOfflineService setTableVersion:@"users" version:1];
	
	sCreateUserQuery.reset(
							[OpenFeint getOfflineDatabaseHandle],
							"REPLACE INTO users "
							"(id, name, profile_picture_url) "
							"VALUES (:id, :name, :profile_picture_url)"
							);

	sGetUserQuery.reset(
						   [OpenFeint getOfflineDatabaseHandle],
						   "SELECT * FROM users "
						   "WHERE id = :id"
						   );
	
}

+ (bool) createLocalUser:(NSString*) userId userName:(NSString*)userName profilePictureUrl:(NSString*)profilePictureUrl
{
	sCreateUserQuery.bind("id", userId);		
	sCreateUserQuery.bind("name", userName);
	sCreateUserQuery.bind("profile_picture_url", profilePictureUrl);
	sCreateUserQuery.execute();
	bool success = (sCreateUserQuery.getLastStepResult() == SQLITE_OK);
	sCreateUserQuery.resetQuery();
	return success;
}

+ (void) getLocalUser:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFUser* user = [self getLocalUser:userId];
	if( user ) 
	{
		NSArray* resources = [[[NSArray alloc] initWithObjects:user,nil] autorelease];
		onSuccess.invoke(resources);
	} else {
		onFailure.invoke();
	}
}

+ (OFUser*) getLocalUser:(NSString*) userId
{
	OFUser* user = nil;
	sGetUserQuery.bind("id", userId);
	sGetUserQuery.execute();
	if (sGetUserQuery.getLastStepResult() == SQLITE_ROW)
	{
		user = [[[OFUser alloc] initWithLocalSQL:&sGetUserQuery] autorelease];
	}
	sGetUserQuery.resetQuery();
	
	return user;
}

@end
