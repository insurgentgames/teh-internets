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

#import "OFDependencies.h"
#import "OFChallengeDetailCell.h"
#import "OFViewHelper.h"
#import "OFChallenge.h"
#import "OFChallengeToUser.h"
#import "OFChallengeDefinition.h"
#import "OFImageView.h"
#import "OFUser.h"
#import "OFImageLoader.h"

@implementation OFChallengeDetailCell

- (void)onResourceChanged:(OFResource*)resource
{

	OFChallengeToUser* userChallenge = (OFChallengeToUser*)resource;
	
	UILabel* userNameLabel = (UILabel*)OFViewHelper::findViewByTag(self, 2);
	userNameLabel.text = userChallenge.recipient.name;
	
	UILabel* resultLabel = (UILabel*)OFViewHelper::findViewByTag(self, 5);
	if (userChallenge.isCompleted)
	{
		resultLabel.text = userChallenge.formattedResultDescription;
	}
	else
	{
		resultLabel.text = @"Challenge not completed yet.";
	}
	
	UILabel* numTriesLabel = (UILabel*)OFViewHelper::findViewByTag(self, 7);
	if (userChallenge.challenge.challengeDefinition.multiAttempt && (userChallenge.attempts > 0))
	{
		numTriesLabel.hidden = NO;
		NSString* triesText = (userChallenge.attempts > 1) ? @"tries" : @"try";
		numTriesLabel.text = [NSString stringWithFormat:@"%d %@", userChallenge.attempts, triesText];
	}
	else
	{
		numTriesLabel.hidden = YES;
	}
	
	
	OFImageView* challengerProfilePictureView = (OFImageView*)OFViewHelper::findViewByTag(self, 1);
	[challengerProfilePictureView useProfilePictureFromUser:userChallenge.recipient];
	
	UIImageView* statusIconView = (UIImageView*)OFViewHelper::findViewByTag(self, 4);
	if(userChallenge.isCompleted == YES)
	{
		statusIconView.image = [OFImageLoader loadImage:[OFChallengeToUser getChallengeResultIconName:userChallenge.result]];
		statusIconView.hidden = NO;
	}
	else
	{
		statusIconView.hidden = YES;
	}
}


@end
