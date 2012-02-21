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

@interface OFGameProfilePageInfo : OFResource< NSCoding >
{
@package
	NSString* name;
	NSString* shortName;
	NSString* iconUrl;
	BOOL hasChatRooms;
	BOOL hasLeaderboards;
	BOOL hasAchievements;
	BOOL hasChallenges;
	BOOL hasiPurchase;
	BOOL ownedByLocalPlayer;
	BOOL hasFeaturedApplication;
	NSString* suggestionsForumId;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (BOOL)isLocalGameInfo;

+ (id)defaultInfo;

+ (OFResourceDataMap*)getDataMap;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* shortName;
@property (nonatomic, readonly) NSString* iconUrl;
@property (nonatomic, readonly) BOOL hasChatRooms;
@property (nonatomic, readonly) BOOL hasLeaderboards;
@property (nonatomic, readonly) BOOL hasAchievements;
@property (nonatomic, readonly) BOOL hasChallenges;
@property (nonatomic, readonly) BOOL hasiPurchase;
@property (nonatomic, readonly) BOOL ownedByLocalPlayer;
@property (nonatomic, readonly) NSString* suggestionsForumId;
@property (nonatomic, readonly) BOOL hasFeaturedApplication;
@end