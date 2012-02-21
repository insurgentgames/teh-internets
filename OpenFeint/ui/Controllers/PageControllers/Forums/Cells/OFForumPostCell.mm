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

#import "OFForumPostCell.h"
#import "OFForumPost.h"

#import "OFImageView.h"
#import "OFUser.h"

#import "NSDateFormatter+OpenFeint.h"
#import "UIButton+OpenFeint.h"

#import "OFImageLoader.h"

#import "OFProfileController.h"

@implementation OFForumPostCell

- (void)dealloc
{
	OFSafeRelease(contentWrapperView);
	
	OFSafeRelease(authorPictureView);
	OFSafeRelease(authorLabel);
	OFSafeRelease(gameLabel);
	OFSafeRelease(bodyLabel);
	
	author = nil;

	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	float const kBodyPrePad = 2.f;
	CGRect bodyFrame = bodyLabel.frame;	
	bodyFrame.origin.y = CGRectGetMaxY(authorLabel.frame) + kBodyPrePad;
	bodyLabel.frame = bodyFrame;
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFForumPost* post = (OFForumPost*)resource;
	
/*	if (post.resourceId == 0)
	{
		return;
	}
*/
	NSString* authorTextSuffix = ([post.author.lastPlayedGameName isEqualToString:@""]) ? @"%@" : @"%@ | ";
	NSString* authorText = [NSString stringWithFormat:authorTextSuffix, post.author.name];
	NSString* gameText = post.author.lastPlayedGameName;
	
	float nameWidth = [authorText sizeWithFont:authorLabel.font].width;
	float const kRightPad = 32.f;

	CGRect frame = authorLabel.frame;
	frame.size.width = nameWidth;
	authorLabel.frame = frame;

	frame = gameLabel.frame;
	frame.origin.x = CGRectGetMaxX(authorLabel.frame);
	frame.size.width = self.frame.size.width - frame.origin.x - kRightPad;
	gameLabel.frame = frame;

	authorLabel.text = authorText;
	gameLabel.text = gameText;

	[authorPictureView useProfilePictureFromUser:post.author];

	CGSize bodySize = [post.body 
					   sizeWithFont:bodyLabel.font 
					   constrainedToSize:CGSizeMake(bodyLabel.frame.size.width, FLT_MAX)];
	
	float const kBodyPrePad = 2.f;
	CGRect bodyFrame = bodyLabel.frame;	
	bodyFrame.origin.y = CGRectGetMaxY(authorLabel.frame) + kBodyPrePad;
	bodyFrame.size.height = bodySize.height;
	bodyLabel.frame = bodyFrame;
	bodyLabel.text = post.body;
	
	float const kMinHeight = 58.f;
	float const kCellBottomPad = 4.f;
	CGRect cellFrame = self.frame;
	cellFrame.size.height = CGRectGetMaxY(bodyFrame) + kCellBottomPad;
	cellFrame.size.height = MAX(cellFrame.size.height, kMinHeight);
	self.frame = cellFrame;
	
	author = post.author;
}

- (IBAction)_goToProfile
{
	[OFProfileController showProfileForUser:author];
}

@end
