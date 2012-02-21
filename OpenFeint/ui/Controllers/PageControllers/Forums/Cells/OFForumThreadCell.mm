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

#import "OFForumThreadCell.h"
#import "OFForumThread.h"

#import "OFUser.h"
#import "OFImageView.h"
#import "OFImageLoader.h"

#define NORMAL_STATUS_IMAGE_NAME	@"OFForumThreadNormalIcon.png"
#define LOCKED_STATUS_IMAGE_NAME	@"OFForumThreadLockedIcon.png"

@implementation OFForumThreadCell

- (void)dealloc
{
	OFSafeRelease(titleLabel);
	OFSafeRelease(stickyLabel);
	OFSafeRelease(postsCountLabel);
	OFSafeRelease(favoritedIcon);
	OFSafeRelease(threadStatusIcon);
	[super dealloc];
}

- (void)onResourceChanged:(OFResource*)resource
{
	OFForumThread* thread = (OFForumThread*)resource;

	float const kRightPad = 40.f;
	
	CGRect frame = titleLabel.frame;
	frame.origin.x = thread.isSticky ? CGRectGetMaxX(stickyLabel.frame) : CGRectGetMinX(stickyLabel.frame);
	frame.size.width = self.frame.size.width - frame.origin.x - kRightPad;
	titleLabel.frame = frame;
	titleLabel.text = thread.title;
	
	NSLocale* enUSLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	
	NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setLocale:enUSLocale];
	
	NSDateFormatter* timeFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[timeFormatter setDateStyle:NSDateFormatterNoStyle];
	[timeFormatter setTimeStyle:NSDateFormatterShortStyle];
	[timeFormatter setLocale:enUSLocale];

	postsCountLabel.text = [NSString stringWithFormat:@"Last post by %@ on %@ at %@", thread.lastPostAuthor.name, [dateFormatter stringFromDate:thread.date], [timeFormatter stringFromDate:thread.date]];

	favoritedIcon.hidden = !thread.isSubscribed;
	stickyLabel.hidden = !thread.isSticky;
	
	NSString* statusImageName = thread.isLocked ? LOCKED_STATUS_IMAGE_NAME : NORMAL_STATUS_IMAGE_NAME;
	threadStatusIcon.image = [OFImageLoader loadImage:statusImageName];

}

@end
