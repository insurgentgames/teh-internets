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
#import "OFProfilePictureCell.h"
#import "OFImageView.h"
#import "OFImageLoader.h"
#import "OFUsersCredential.h"
#import "OFUsersCredentialCell.h"
#import "OFUser.h"

#import "OpenFeint+UserOptions.h"

@implementation OFProfilePictureCell

@synthesize profilePictureView, credentialImageView, credentialTextLabel, checkmark;

- (void)onResourceChanged:(OFResource*)resource
{
	OFUsersCredential* credential = (OFUsersCredential*)resource;

	OFUser* localUser = [OpenFeint localUser];
	NSString* pictureSource = localUser.profilePictureSource;
	NSString* pictureUrl = localUser.profilePictureUrl;
	
	bool isActiveCredential = 
		([pictureSource isEqualToString:@"TwitterCredential"] && [credential isTwitter]) ||
		([pictureSource isEqualToString:@"FbconnectCredential"] && [credential isFacebook]) ||
		([pictureSource isEqualToString:@"Upload"] && [credential isHttpBasic] && [pictureUrl length] > 0) ||
		([pictureSource isEqualToString:@"Upload"] && [credential.credentialType length] == 0 && [pictureUrl length] == 0);

	self.checkmark.hidden = !isActiveCredential;
	
	if (credential.credentialProfilePictureUrl)
	{
		[profilePictureView setUseFacebookOverlay:[credential isFacebook]];
		[profilePictureView useLocalPlayerProfilePictureDefault];
		profilePictureView.imageUrl = credential.credentialProfilePictureUrl;	
	}
	else if ([credential.credentialType length] == 0)
	{
		[profilePictureView useLocalPlayerProfilePictureDefault];
	}
	else
	{
		[profilePictureView setDefaultImage:[OFImageLoader loadImage:@"OFUnknownProfilePicture.png"]];
	}

	self.accessoryType = UITableViewCellAccessoryNone;

	NSString* imageName = [OFUsersCredentialCell getCredentialImage:credential.credentialType];
	if (imageName)
	{
		OFAssert([credential isTwitter] || [credential isFacebook], "Assuming Twitter or Facebook here");

		credentialImageView.hidden = NO;
		credentialTextLabel.hidden = YES;

		credentialImageView.image = [OFImageLoader loadImage:imageName];

		if (![credential isLinked])
		{
			self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if ([credential isHttpBasic])
	{
		OFAssert([credential isHttpBasic], "Assuming HttpBasic here");
		
		credentialTextLabel.hidden = NO;
		credentialImageView.hidden = YES;
		
		credentialTextLabel.text = @"Choose your own!";

		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		credentialTextLabel.hidden = NO;
		credentialImageView.hidden = YES;
        
		credentialTextLabel.text = @"Default OpenFeint Icon";
	}
}

- (void)dealloc
{
	self.profilePictureView = nil;
	self.credentialImageView = nil;
	self.credentialTextLabel = nil;
	self.checkmark = nil;
	[super dealloc];
}

@end
