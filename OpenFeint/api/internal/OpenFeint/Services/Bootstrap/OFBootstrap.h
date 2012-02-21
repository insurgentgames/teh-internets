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

@class OFService;
@class OFGameProfilePageInfo;
@class OFUser;

@interface OFBootstrap : OFResource
{
@package
	NSUInteger minimumOpenFeintVersionSupported;
	NSUInteger pollingFrequencyInChat;
	NSUInteger pollingFrequencyDefault;
	BOOL loggedInUserHasSetName;
	BOOL loggedInUserHasNonDeviceCredential;

	BOOL loggedInUserHasHttpBasicCredential;
	BOOL loggedInUserHasFbconnectCredential;
	BOOL loggedInUserHasTwitterCredential;

	BOOL loggedInUserIsNewUser;
	BOOL loggedInUserHadFriendsOnBootup;
	BOOL loggedInUserHasChatEnabled;
	OFGameProfilePageInfo* gameProfilePageInfo;
	OFUser* user;
	NSString* accessToken;
	NSString* accessTokenSecret;	
	NSString* clientApplicationId;
	NSString* clientApplicationIconUrl;
	NSUInteger unviewedChallengesCount;
	NSUInteger pendingFriendsCount;
	NSUInteger postsUnreadCount;
	NSUInteger subscriptionsUnreadCount;

	NSString* suggestionsForumId;
	
	NSString* initialDashboardScreen;
	
	BOOL initializePresenceService;
	BOOL pipeHttpOverPresenceService;
	NSString* presenceQueue;
	BOOL loggedInUserHasShareLocationEnabled;
}

+ (OFResourceDataMap*)getDataMap;
+ (NSString*)getResourceName;

@property (nonatomic, readonly) NSUInteger minimumOpenFeintVersionSupported;
@property (nonatomic, readonly) NSUInteger pollingFrequencyInChat;
@property (nonatomic, readonly) NSUInteger pollingFrequencyDefault;
@property (nonatomic, readonly, retain) OFGameProfilePageInfo* gameProfilePageInfo;
@property (nonatomic, readonly, retain) OFUser* user;
@property (nonatomic, readonly) BOOL loggedInUserHasSetName;
@property (nonatomic, readonly) BOOL loggedInUserHasNonDeviceCredential;

@property (nonatomic, readonly) BOOL loggedInUserHasHttpBasicCredential;
@property (nonatomic, readonly) BOOL loggedInUserHasFbconnectCredential;
@property (nonatomic, readonly) BOOL loggedInUserHasTwitterCredential;

@property (nonatomic, readonly) BOOL loggedInUserIsNewUser;
@property (nonatomic, readonly) BOOL loggedInUserHadFriendsOnBootup;
@property (nonatomic, readonly, retain) NSString* accessToken;
@property (nonatomic, readonly, retain) NSString* accessTokenSecret;
@property (nonatomic, readonly, retain) NSString* clientApplicationId;
@property (nonatomic, readonly, retain) NSString* clientApplicationIconUrl;
@property (nonatomic, readonly) NSUInteger unviewedChallengesCount;
@property (nonatomic, readonly) NSUInteger pendingFriendsCount;
@property (nonatomic, readonly) NSUInteger postsUnreadCount;
@property (nonatomic, readonly) NSUInteger subscriptionsUnreadCount;
@property (nonatomic, readonly) BOOL loggedInUserHasChatEnabled;

@property (nonatomic, readonly) NSString* suggestionsForumId;
@property (nonatomic, readonly) NSString* initialDashboardScreen;

@property (nonatomic, readonly) BOOL initializePresenceService;
@property (nonatomic, readonly) BOOL pipeHttpOverPresenceService;
@property (nonatomic, readonly, retain) NSString* presenceQueue;
@property (nonatomic, readonly) BOOL loggedInUserHasShareLocationEnabled;

@end