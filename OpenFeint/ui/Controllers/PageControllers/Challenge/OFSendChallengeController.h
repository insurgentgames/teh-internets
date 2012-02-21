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

#import "OFTableSequenceControllerHelper.h"
#import "OFFramedNavigationControllerBehavior.h"
#import "OFImageView.h"
#import "OFChallengeToUser.h"

@class OFUser, OFUserCell;

@interface OFSendChallengeController : OFTableSequenceControllerHelper<OFCallbackable, OFFramedNavigationControllerBehavior>
{
	NSString* challengeDefinitionId;
	NSString* challengeText;
	NSString* hiddenText;
	NSData* challengeData;
	NSData* resultData;
	NSMutableArray* mSelectedUsers;
	OFChallengeToUser* userChallenge;
	bool isCompleted;
	bool rechallenge;
    bool stallNextRefresh;
}

@property (nonatomic, retain) NSString* challengeDefinitionId;
@property (nonatomic, retain) NSString* challengeText;
@property (nonatomic, retain) NSString* hiddenText;
@property (nonatomic, retain) NSData* challengeData;
@property (nonatomic, retain) NSData* resultData;
@property (nonatomic, retain) OFChallengeToUser* userChallenge;
@property (nonatomic) bool isCompleted;

- (IBAction)submitChallenge;
- (IBAction)submitChallengeBack;
- (IBAction)tryChallengeAgain;
- (IBAction)cancel;
- (void)toggleSelectionOfUser:(OFUser*)user;
- (void)cell:(OFUserCell*)cell wasAssignedUser:(OFUser*)user;

@end
