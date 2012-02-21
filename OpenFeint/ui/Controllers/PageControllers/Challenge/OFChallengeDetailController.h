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

#pragma once
#import "OFTableSequenceControllerHelper.h"

@class OFChallengeToUser;
@class OFChallenge;

enum OFChallengeListType { kChallengeListPending = 0, kChallengeListHistory, kChallengeListDefinitionStats };

@interface OFChallengeDetailController : OFTableSequenceControllerHelper <OFCallbackable, UIAlertViewDelegate>
{
@package
	OFChallengeToUser*	userChallenge;
	NSString* challengeId;
	NSString* clientApplicationId;
	OFChallengeListType	list;
	UIAlertView* oneShotAlertView;
	BOOL challengeCompleted;
	NSData * challengeData;
}

@property (nonatomic, retain) NSString* challengeId;
@property (nonatomic, retain) NSString* clientApplicationId;
@property (nonatomic, retain) OFChallengeToUser* userChallenge;
@property (nonatomic) OFChallengeListType list;
@property (nonatomic, assign) BOOL challengeCompleted;

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath;
- (bool)canReceiveCallbacksNow;
- (IBAction)acceptChallenge:(id)sender;

//- (void)setWithChallenge:(OFChallengeToUser*)newChallenge;

@end
