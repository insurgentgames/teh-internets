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
#import "OFHighScoreCell.h"
#import "OFViewHelper.h"
#import "OFHighScore.h"
#import "OFUser.h"
#import "OFImageView.h"
#import "OFStringUtility.h"
#import "OpenFeint.h"
#import "OpenFeint+UserOptions.h"
#import "OFStringUtility.h"
#import "OFUserRelationshipIndicator.h"

const double kmsPerMile = 1.0/.621371;

@implementation OFHighScoreCell

@synthesize disclosureIndicator;

- (void)onResourceChanged:(OFResource*)resource
{
	OFHighScore* highScore = (OFHighScore*)resource;
		
	OFImageView* profilePictureView = (OFImageView*)OFViewHelper::findViewByTag(self, 1);
	[profilePictureView useProfilePictureFromUser:highScore.user];
	
	UILabel* nameLabel = (UILabel*)OFViewHelper::findViewByTag(self, 3);
	UILabel* distLabel = (UILabel*)OFViewHelper::findViewByTag(self, 4);
	UILabel* scoreLabel = (UILabel*)OFViewHelper::findViewByTag(self, 5);
	if ([OpenFeint isOnline])
	{
		if (highScore.rank == -1)
		{
			nameLabel.text = highScore.user.name;
			scoreLabel.text = @"Not Ranked";
		}
		else
		{
			nameLabel.text = [NSString stringWithFormat:@"%d. %@", highScore.rank, highScore.user.name];
			scoreLabel.text = [NSString stringWithFormat:@"%@", OFStringUtility::convertFromValidParameter(highScore.displayText).get()];
		}

		if (highScore.distance)
		{
			OFUserDistanceUnitType unit = [OpenFeint userDistanceUnit];
			double dist = highScore.distance * (unit == kDistanceUnitMiles ? 1 : kmsPerMile);
			NSString* unitText = (unit == kDistanceUnitMiles ? @"miles" : @"kms"); 
			distLabel.text = [NSString stringWithFormat:@"%.2f %@ away", dist, unitText];
		}
		else
		{
			distLabel.text = nil;
		}
		
		OFUserRelationshipIndicator* relationshipIndicator = (OFUserRelationshipIndicator*)OFViewHelper::findViewByTag(self, 6);
		[relationshipIndicator setUser:highScore.user];
        disclosureIndicator.hidden = NO;
	}
	else
	{
		//if ([OpenFeint hasUserApprovedFeint]) //might want to show something different
		NSString* userName = highScore.user ? highScore.user.name : @"Unregistered User";
		nameLabel.text = [NSString stringWithFormat:@"%d. %@", highScore.rank, userName];
		scoreLabel.text = [NSString stringWithFormat:@"%@", OFStringUtility::convertFromValidParameter(highScore.displayText).get()];
		distLabel.text = nil;
        disclosureIndicator.hidden = YES;
	}
	
	if (nil == distLabel.text)
	{
		distLabel.hidden = YES;
		CGRect nameFrame = nameLabel.frame;
		nameFrame.origin.y = (self.frame.size.height - nameFrame.size.height) / 2.0;
		nameLabel.frame = nameFrame;
	}
	else
	{
		distLabel.hidden = NO;
		CGRect nameFrame = nameLabel.frame;
		nameFrame.origin.y = (self.frame.size.height - nameFrame.size.height) / 3.0;
		nameLabel.frame = nameFrame;
		CGRect distFrame = distLabel.frame;
		distFrame.origin.y = (self.frame.size.height - distFrame.size.height) * 2.5 / 3.0;
		distLabel.frame = distFrame;
	}
}

- (void)awakeFromNib
{
	if (![OpenFeint isOnline])
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	[super awakeFromNib];
}

- (void)dealloc
{
    self.disclosureIndicator = nil;
    [super dealloc];
}


@end
