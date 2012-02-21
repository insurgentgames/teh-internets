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


#import "OFResource.h"
#import "OFSqlQuery.h"

@interface OFUser : OFResource< NSCoding >
{
	@package
	NSString* name;
	NSString* profilePictureUrl;
	NSString* profilePictureSource;
	BOOL usesFacebookProfilePicture;
	NSString* lastPlayedGameId;
	NSString* lastPlayedGameName;
	BOOL followsLocalUser;
	BOOL followedByLocalUser;
	NSUInteger gamerScore;
	BOOL online;
	double latitude;
	double longitude;
}

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

+ (id)invalidUser;

+ (OFResourceDataMap*)getDataMap;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

- (bool)isLocalUser;
- (void)adjustGamerscore:(int)gamerscoreAdjustment;

- (void)changeProfilePictureUrl:(NSString*)url facebook:(BOOL)isFacebook twitter:(BOOL)isTwitter uploaded:(BOOL)isUploaded;

@property (nonatomic, retain) NSString* name;
@property (nonatomic, readonly, retain) NSString* profilePictureUrl;
@property (nonatomic, readonly, retain) NSString* profilePictureSource;
@property (nonatomic, readonly) BOOL usesFacebookProfilePicture;
@property (nonatomic, readonly, retain)	NSString* lastPlayedGameId;
@property (nonatomic, readonly, retain) NSString* lastPlayedGameName;
@property (nonatomic, readonly)	NSUInteger gamerScore;
@property (nonatomic)	BOOL followsLocalUser;
@property (nonatomic)	BOOL followedByLocalUser;
@property (nonatomic)	BOOL online;
@property (nonatomic, readonly)	double latitude;
@property (nonatomic, readonly)	double longitude;


@end