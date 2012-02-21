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
#import "OFWhosPlayingCell.h"
#import "OFViewHelper.h"
#import "OFImageView.h"
#import "OFGamePlayer.h"
#import "OFUser.h"

//static CGRect lastPlayedGameLabelRect = CGRectZero;

@implementation OFWhosPlayingCell

@synthesize profilePictureView, nameLabel, lastPlayedGameLabel, gamerScoreLabel, appGamerScoreLabel, onlineLabel;

- (void)onResourceChanged:(OFResource*)resource
{
	OFGamePlayer* player = (OFGamePlayer*)resource;
	OFUser* user = player.user;

	NSString* lastPlayedText;
	if ([user online] || [user isLocalUser])
    {
        lastPlayedText = @"Playing %@";
        onlineLabel.hidden = NO;
    }
    else
    {
		lastPlayedText = @"Last played %@";
		onlineLabel.hidden = YES;
	}

	nameLabel.text = user.name;
	[profilePictureView useProfilePictureFromUser:user];
	lastPlayedGameLabel.text = [NSString stringWithFormat:lastPlayedText, user.lastPlayedGameName];
	appGamerScoreLabel.text = [NSString stringWithFormat:@"%u", player.applicationGamerscore];
	gamerScoreLabel.text = [NSString stringWithFormat:@"%u", user.gamerScore];
}

- (void)dealloc
{
	self.nameLabel = nil;
	self.profilePictureView = nil;
	self.lastPlayedGameLabel = nil;
	self.appGamerScoreLabel = nil;
	self.gamerScoreLabel = nil;
	self.onlineLabel = nil;
	[super dealloc];
}

@end
