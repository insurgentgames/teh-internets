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
@class OFChallenge;
@class OFUser;

enum OFChallengeResult {kChallengeIncomplete, kChallengeResultRecipientWon, kChallengeResultRecipientLost, kChallengeResultTie};

@interface OFChallengeToUser : OFResource
{
	@package
	OFChallenge* challenge;
	OFUser*		recipient;
	OFChallengeResult result;
	NSString* resultDescription;
	NSUInteger attempts;
	BOOL isCompleted;
	BOOL hasBeenViewed;
	
	BOOL hasDecrementedChallengeCount;
}

+ (OFResourceDataMap*)getDataMap;
+ (OFService*)getService;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

@property (nonatomic, readonly, retain) OFChallenge* challenge;
@property (nonatomic, readonly, retain) OFUser*		recipient;
@property (nonatomic, assign)			OFChallengeResult result;
@property (nonatomic, retain)			NSString* resultDescription;
@property (nonatomic, readonly)			NSString* formattedResultDescription;
@property (nonatomic, assign)			BOOL isCompleted;
@property (nonatomic, readonly)			BOOL hasBeenViewed;
@property (nonatomic, readonly)			NSUInteger attempts;

@property (nonatomic, assign)			BOOL hasDecrementedChallengeCount;

+ (NSString*)getChallengeResultIconName:(OFChallengeResult)result;

@end