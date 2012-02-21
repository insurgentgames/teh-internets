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

#import "OFConversationCell.h"
#import "OFForumPost.h"

#import "OFImageView.h"
#import "OFUser.h"

#import "NSDateFormatter+OpenFeint.h"
#import "UIButton+OpenFeint.h"

#import "OFImageLoader.h"

#import "OFProfileController.h"

@implementation OFConversationCell

- (void)dealloc
{
	OFSafeRelease(authorPictureView);
	OFSafeRelease(authorLabel);
	OFSafeRelease(bodyLabel);
	OFSafeRelease(dateLabel);
	OFSafeRelease(greenBubbleView);
	OFSafeRelease(greyBubbleView);
	OFSafeRelease(arrowView);
	author = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	greenBubbleView.contentMode = UIViewContentModeScaleToFill;
	greyBubbleView.contentMode = UIViewContentModeScaleToFill;
	
	greenBubbleView.image = [greenBubbleView.image stretchableImageWithLeftCapWidth:8 topCapHeight:16];
	greyBubbleView.image = [greyBubbleView.image stretchableImageWithLeftCapWidth:8 topCapHeight:16];
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFForumPost* post = (OFForumPost*)resource;

	CGRect frame;
	
	NSString* authorText = [NSString stringWithFormat:@"%@ | ", post.author.name];
	NSString* dateText = [[NSDateFormatter normalFormatter] stringFromDate:post.date];
	
	[authorPictureView useProfilePictureFromUser:post.author];

	float nameWidth = [authorText sizeWithFont:authorLabel.font].width;

	float const kBubbleSidePad = 7.f;
	float const kAuthorPictureOffset = 14.f;
	float const kBubbleContentPad = 8.f;

	if ([post.author isLocalUser])
	{
		greyBubbleView.hidden = YES;
		bubbleView = greenBubbleView;
		bubbleView.hidden = NO;
        
		frame = bubbleView.frame;
		frame.origin.x = kBubbleSidePad;
		frame.size.width = self.frame.size.width - authorPictureView.frame.size.width - (kAuthorPictureOffset * 2.f) - kBubbleSidePad;
		bubbleView.frame = frame;

		frame = arrowView.frame;
		frame.origin.x = CGRectGetMaxX(bubbleView.frame) - 1.f;
		arrowView.frame = frame;

		frame = authorPictureView.frame;
		frame.origin.x = self.frame.size.width - frame.size.width - kAuthorPictureOffset;
		authorPictureView.frame = frame;

		arrowView.transform = CGAffineTransformMake(-1.f, 0.f, 0.f, -1.f, 0.f, 0.f);
	}
	else
	{
		greenBubbleView.hidden = YES;
		bubbleView = greyBubbleView;
		bubbleView.hidden = NO;
        
		frame = bubbleView.frame;
		frame.origin.x = authorPictureView.frame.size.width + (kAuthorPictureOffset * 2.f);
		frame.size.width = self.frame.size.width - authorPictureView.frame.size.width - (kAuthorPictureOffset * 2.f) - kBubbleSidePad;
		bubbleView.frame = frame;
		
		frame = arrowView.frame;
		frame.origin.x = CGRectGetMinX(bubbleView.frame) - frame.size.width + 2.f;
		arrowView.frame = frame;
		
		frame = authorPictureView.frame;
		frame.origin.x = kAuthorPictureOffset;
		authorPictureView.frame = frame;

		arrowView.transform = CGAffineTransformIdentity;
	}
	
	CGSize bodySize = [post.body 
		sizeWithFont:bodyLabel.font 
		constrainedToSize:CGSizeMake(bodyLabel.frame.size.width, FLT_MAX)];

	frame = authorLabel.frame;
	frame.origin.x = CGRectGetMinX(bubbleView.frame) + kBubbleContentPad;
	frame.size.width = nameWidth;
	authorLabel.frame = frame;

	frame = dateLabel.frame;
	frame.origin.x = CGRectGetMaxX(authorLabel.frame);
	dateLabel.frame = frame;

	float const kMinBodyHeight = 25.f;
	
    frame = bodyLabel.frame;
    frame.origin.x = CGRectGetMinX(bubbleView.frame) + kBubbleContentPad;
    frame.size.height = MAX(kMinBodyHeight, bodySize.height);
    bodyLabel.frame = frame;
    
    bodyLabel.text = post.body;
    authorLabel.text = authorText;
    dateLabel.text = dateText;    

	float const kMinHeight = 64.f;
	float const kCellBottomPad = 14.f;

	frame = self.frame;
	frame.size.height = bodyLabel.frame.origin.y + bodySize.height + kCellBottomPad;
	frame.size.height = MAX(frame.size.height, kMinHeight);
	self.frame = frame;
	
	author = post.author;
}

- (IBAction)clickedAuthorProfileView {
	[OFProfileController showProfileForUser:author];
}

@end
