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
#import "OFUserCell.h"
#import "OFViewHelper.h"
#import "OFImageView.h"
#import "OFUser.h"
#import "OFUserRelationshipIndicator.h"
#import "OFSendChallengeController.h"

#import "OpenFeint.h"

//static CGRect lastPlayedGameLabelRect = CGRectZero;

@implementation OFUserCell

@synthesize profilePictureView, nameLabel, lastPlayedGameLabel, 
			gamerScoreLabel, relationshipIndicator, 
			feintScoreIconImageView, relationshipDescription, presenceIcon,
            onlineLabel;

- (void)onResourceChanged:(OFResource*)resource
{
	OFUser* user = (OFUser*)resource;
	
	nameLabel.text = user.name;
	[profilePictureView useProfilePictureFromUser:user];
    
	gamerScoreLabel.text = [NSString stringWithFormat:@"%u", user.gamerScore];
    
    NSString* prefix = @"";
    
	if ([user online])
    {
        prefix = @"playing";
        onlineLabel.hidden = NO;
	}
	else
	{
        if ([user isLocalUser])
        {
            prefix = @"You are playing";            
        }
        else
        {
            prefix = @"Last played";
        }
        
        onlineLabel.hidden = YES;
	}
    
    lastPlayedGameLabel.text = [NSString stringWithFormat:@"%@ %@", prefix, user.lastPlayedGameName];

	[self.relationshipIndicator setUser:user];

	if ([owningTable isKindOfClass:[OFSendChallengeController class]])
	{
		[(OFSendChallengeController*)owningTable cell:self wasAssignedUser:user];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	float alpha = editing ? 0.f : 1.f;

	feintScoreIconImageView.alpha = alpha;
	gamerScoreLabel.alpha = alpha;
}

- (void)dealloc
{
	self.presenceIcon = nil;
	self.relationshipDescription = nil;
	self.nameLabel = nil;
	self.profilePictureView = nil;
	self.lastPlayedGameLabel = nil;
	self.gamerScoreLabel = nil;
	self.relationshipIndicator = nil;
	self.feintScoreIconImageView = nil;
    self.onlineLabel= nil;
	[super dealloc];
}

@end
