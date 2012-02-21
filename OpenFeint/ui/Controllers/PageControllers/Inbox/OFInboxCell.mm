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

#import "OFInboxCell.h"
#import "OFSubscription.h"
#import "OFImageLoader.h"
#import "OFUser.h"
#import "OFForumThread.h"

@implementation OFInboxCell

- (void)dealloc
{
	OFSafeRelease(typeLabel);
	OFSafeRelease(titleLabel);
	OFSafeRelease(bodyPreviewLabel);

	OFSafeRelease(iconView);
	OFSafeRelease(profilePictureView);

	OFSafeRelease(unreadBadge);
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	cachedTitleMaxHeight = titleLabel.frame.size.height * MAX(1, titleLabel.numberOfLines);
	cachedBodyMaxHeight = bodyPreviewLabel.frame.size.height * MAX(1, bodyPreviewLabel.numberOfLines);
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFSubscription* subscription = (OFSubscription*)resource;

	CGRect frame = iconView.frame;
	
	NSString* titleText = nil;
	if ([subscription isForumThread])
	{
        if (subscription.discussion.isLocked)
        {
            iconView.image = [OFImageLoader loadImage:@"OFForumThreadLockedIcon.png"];
        }
        else
        {
            iconView.image = [OFImageLoader loadImage:@"OFForumThreadNormalIcon.png"];
        }
		frame.size.width = 48.f;
		typeLabel.text = @"Forum Posting";
		titleText = subscription.title;
		profilePictureView.hidden = YES;
	}
	else if ([subscription isConversation])
	{
		iconView.image = [OFImageLoader loadImage:@"OFPlayerFrameIM.png"];
		frame.size.width = 65.f;
		typeLabel.text = @"IM Conversation";
		titleText = subscription.otherUser.name;
		[profilePictureView useProfilePictureFromUser:subscription.otherUser];
		profilePictureView.unframed = YES;
		profilePictureView.hidden = NO;
	}
	
	iconView.frame = frame;
	
	float titleHeight = [titleText sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width, cachedTitleMaxHeight)].height;
	float bodyHeight = [subscription.summary sizeWithFont:bodyPreviewLabel.font constrainedToSize:CGSizeMake(bodyPreviewLabel.frame.size.width, cachedBodyMaxHeight)].height;
	
	frame = titleLabel.frame;
	frame.size.height = titleHeight;
	titleLabel.frame = frame;
	
	frame = bodyPreviewLabel.frame;
	frame.origin.y = CGRectGetMaxY(titleLabel.frame);
	frame.size.height = bodyHeight;
	bodyPreviewLabel.frame = frame;

	titleLabel.text = titleText;
	bodyPreviewLabel.text = subscription.summary;
	
	unreadBadge.hidden = (subscription.unreadCount == 0);
	unreadBadge.value = subscription.unreadCount;
	
	frame = self.frame;
	frame.size.height = CGRectGetMaxY(bodyPreviewLabel.frame) + 5.f;
	frame.size.height = MAX(frame.size.height, 54.f);
	self.frame = frame;
}

@end
