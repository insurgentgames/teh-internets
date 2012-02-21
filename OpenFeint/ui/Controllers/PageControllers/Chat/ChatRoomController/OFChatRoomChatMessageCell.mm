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
#import "OFChatRoomChatMessageCell.h"
#import "OFChatMessage.h"
#import "OFStringUtility.h"
#import "OFApplicationDescriptionController.h"
#import "OFControllerLoader.h"
#import "OFProfileController.h"
#import "OFImageView.h"
#import "OFGameProfileController.h"
#import "OFChatRoomController.h"
#import "OFChatRoomInstance.h"
#import "OFUser.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "NSObject+WeakLinking.h"

@implementation OFChatRoomChatMessageCell

@synthesize owner;
@synthesize profilePictureView, gamePictureView, playerNameLabel, gameNameLabel, chatMessageLabel;

- (bool)shouldGameNameLink:(OFChatMessage*)message
{
	if(message.user.lastPlayedGameId != nil && ![message.user.lastPlayedGameId isEqualToString:@"null"] && ![message.user.lastPlayedGameId isEqualToString:@""])
	{
		if (message.doesLocalPlayerOwnGame || message.playerCurrentGameIconUrl != nil)
		{
			return true;
		}
	}
	return false;
}

- (IBAction)onClickedFeintName
{
	OFChatMessage* message = (OFChatMessage*)mResource;
	
	if (message.user != nil)
	{
		[OFProfileController showProfileForUser:message.user];
	}
}

- (IBAction)onClickedGameName
{
	OFChatMessage* message = (OFChatMessage*)mResource;

	if([self shouldGameNameLink:message])
	{
		UIViewController* nextController = nil;
		if (message.doesLocalPlayerOwnGame && message.user != nil)	// go to game profile since our user owns the game
		{
			[OFGameProfileController showGameProfileWithClientApplicationId:message.user.lastPlayedGameId compareToUser:message.user];
		}
		else if (message.playerCurrentGameIconUrl != nil) // game has an ipromote page, so go there
		{
			nextController = [OFApplicationDescriptionController applicationDescriptionForId:message.user.lastPlayedGameId appBannerPlacement:@"chatRoomChatMessageCell"];
		}
		
		if (nextController)
		{
			[[owner navigationController] pushViewController:nextController animated:YES];
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFChatMessage* message = (OFChatMessage*)resource;

	[profilePictureView useProfilePictureFromUser:message.user];

	[gamePictureView setDefaultImage:[OFImageLoader loadImage:@"OFDefaultApplicationIcon.png"]];
	gamePictureView.imageUrl = message.playerCurrentGameIconUrl;

	NSString* playerNameSuffix = ([message.user.lastPlayedGameName isEqualToString:@""]) ? @"%@" : @"%@ | ";
	NSString* playerName = [NSString stringWithFormat:playerNameSuffix, message.user.name];
	NSString* gameName = message.user.lastPlayedGameName;
	NSString* chatMessageText = OFStringUtility::convertFromValidParameter(message.message).get();

	float playerNameWidth = [playerName sizeWithFont:playerNameLabel.font].width;

	CGRect frame;
	
	frame = playerNameLabel.frame;
	frame.origin.x = chatMessageLabel.frame.origin.x;
	frame.size.width = playerNameWidth;
	playerNameLabel.frame = frame;

	frame = gameNameLabel.frame;
	frame.origin.x = CGRectGetMaxX(playerNameLabel.frame);
	frame.size.width = chatMessageLabel.frame.size.width - playerNameLabel.frame.size.width;
	gameNameLabel.frame = frame;

	CGSize bodySize = [chatMessageText 
		sizeWithFont:chatMessageLabel.font 
		constrainedToSize:CGSizeMake(chatMessageLabel.frame.size.width, FLT_MAX)];
		
	frame = chatMessageLabel.frame;
	frame.size.height = bodySize.height;
	chatMessageLabel.frame = frame;

	playerNameLabel.text = playerName;
	gameNameLabel.text = gameName;
	chatMessageLabel.text = chatMessageText;
	
	float const kMinHeight = 59.0f;
	float const kCellBottomPad = 5.f;

	frame = self.frame;
	frame.size.height = CGRectGetMaxY(chatMessageLabel.frame) + kCellBottomPad;
	frame.size.height = MAX(kMinHeight, frame.size.height);
	self.frame = frame;
}

- (void)dealloc
{
	self.owner = nil;
	self.profilePictureView = nil;
	self.gamePictureView = nil;
	self.playerNameLabel = nil;
	self.gameNameLabel = nil;
	self.chatMessageLabel = nil;
	
	[super dealloc];
}

@end
