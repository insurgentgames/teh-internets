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

@interface OFAchievement : OFResource
{
@package
	NSString* title;
	NSString* description;
	NSUInteger gamerscore;
	NSString* iconUrl;
	BOOL isSecret;
	BOOL isUnlocked;
	BOOL isUnlockedByComparedToUser;
	NSString* comparedToUserId;
	NSDate* unlockDate;
	NSString* endVersion;
	NSString* startVersion;
	NSUInteger position;
}

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow;

+ (OFResourceDataMap*)getDataMap;
+ (OFService*)getService;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

@property (nonatomic, readonly, retain) NSString* title;
@property (nonatomic, readonly, retain) NSString* description;
@property (nonatomic, readonly) NSUInteger gamerscore;
@property (nonatomic, readonly, retain) NSString* iconUrl;
@property (nonatomic, readonly) BOOL isSecret;
@property (nonatomic, readonly) BOOL isUnlocked;
@property (nonatomic, readonly) BOOL isUnlockedByComparedToUser;
@property (nonatomic, readonly, retain) NSString* comparedToUserId;
@property (nonatomic, readonly, retain) NSDate* unlockDate;
@property (nonatomic, readonly, retain) NSString* endVersion;
@property (nonatomic, readonly, retain) NSString* startVersion;
@property (nonatomic, readonly) NSUInteger position;

@end