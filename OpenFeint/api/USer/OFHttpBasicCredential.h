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

@interface OFHttpBasicCredential : OFResource< NSCoding >
{
	@package
	NSString* userId;
	NSString* email;
	NSString* cryptedPassword;
	NSString* salt;
	BOOL rememberToken;
	NSString* rememberTokenExpiresAt;
	NSString* createdAt;
	NSString* updatedAt;
	BOOL verified;
	NSString* lastLoginAt;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

+ (OFResourceDataMap*)getDataMap;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;


@property (nonatomic, readonly, retain) NSString* userId;
@property (nonatomic, readonly, retain) NSString* email;
@property (nonatomic, readonly, retain)	NSString* cryptedPassword;
@property (nonatomic, readonly, retain) NSString* salt;
@property (nonatomic)	BOOL rememberToken;
@property (nonatomic)	BOOL verified;
@property (nonatomic, readonly, retain) NSString* rememberTokenExpiresAt;
@property (nonatomic, readonly, retain) NSString* createdAt;
@property (nonatomic, readonly, retain) NSString* updatedAt;
@property (nonatomic, readonly, retain) NSString* lastLoginAt;

@end