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

@class OFService;

@interface OFLeaderboard_Sync: OFResource
{
	@package
	NSString* name;
	BOOL active;
	BOOL allowPostingLowerScores;
	BOOL descendingSortOrder;
	BOOL isAggregate;
	NSDate* reachedAt;
	int64_t score;
	NSString* endVersion;
	NSString* startVersion;
	BOOL visible;
	NSString* displayText;
	NSString* customData;
}

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow;

+ (OFResourceDataMap*)getDataMap;
+ (OFService*)getService;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

@property (nonatomic, readwrite, retain) NSString* name;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic, readonly) BOOL allowPostingLowerScores;
@property (nonatomic, readonly) BOOL descendingSortOrder;
@property (nonatomic, readonly) BOOL isAggregate;
@property (nonatomic, readonly, retain) NSDate* reachedAt;
@property (nonatomic, readonly) int64_t score;
@property (nonatomic, readonly, retain) NSString* endVersion;
@property (nonatomic, readonly, retain) NSString* startVersion;
@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, readonly, retain) NSString* displayText;
@property (nonatomic, readonly, retain) NSString* customData;
@end
