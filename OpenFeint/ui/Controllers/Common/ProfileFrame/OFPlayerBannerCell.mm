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

#import "OFPlayerBannerCell.h"
#import "OFImageLoader.h"
#import "OFUser.h"
#import "OFResource.h"
#import "OFImageView.h"

#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"

static const float kfFeintPtsPadLeft = 28.f;
static const float kfFeintPtsPadRight = 15.f;
static const float kfProfilePadLeft = 3.f;
static const float kfProfilePadTop = 3.f;
static const float kfLabelPadLeft = 9.f;
static const float kfOnlineStatusIconPadTop = 18.f;
static const float kfOnlineStatusIconPadLeft = 8.f;
static const float kfNameLabelPadBottom = -4.f;
static const float kfPlayingLabelPadTop = 2.f;

@implementation OFPlayerBannerCell

@synthesize user;

- (void)onResourceChanged:(OFResource*)resource
{
	// scrub all existing views
	[bgView removeFromSuperview];
	bgView = nil;
	[feintPtsView removeFromSuperview];
	feintPtsView = nil;
	[profileView removeFromSuperview];
	profileView = nil;
	[feintPtsLabel removeFromSuperview];
	feintPtsLabel = nil;
	[playerNameLabel removeFromSuperview];
	playerNameLabel = nil;
	[nowPlayingLabel removeFromSuperview];
	nowPlayingLabel = nil;
	[onlineStatusLabel removeFromSuperview];
	onlineStatusLabel = nil;

	[user release];
	user = [(OFUser*)resource retain];
	
	if (!user)
	{
		UIImage* bgImg = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerOffline.png" : @"OFNowPlayingBannerOffline.png")];
		bgView = [[UIImageView alloc] initWithImage:bgImg];
		[self addSubview:bgView];
		[bgView release];		
	}
	else
	{
		UIImage* bgImg = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFPlayerBannerLandscape.png" : @"OFPlayerBanner.png")];
		bgView = [[UIImageView alloc] initWithImage:bgImg];
		[self addSubview:bgView];
		[bgView release];
		
		UIImage* feintPtsImg = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFPlayerFeintPts.png" : @"OFPlayerFeintPts.png")];
		feintPtsView = [[UIImageView alloc] initWithImage:feintPtsImg];
		[self addSubview:feintPtsView];
		[feintPtsView release];
		
		profileView = [[OFImageView alloc] init];
		[profileView useProfilePictureFromUser:user];
		[self addSubview:profileView];
		[profileView addTarget:self action:@selector(profilePictureTouched) forControlEvents:UIControlEventTouchUpInside];

		[profileView release];
		
		feintPtsLabel = [[UILabel alloc] init];
		feintPtsLabel.backgroundColor = [UIColor clearColor];
		feintPtsLabel.textColor = [UIColor whiteColor];	
		feintPtsLabel.font = [UIFont boldSystemFontOfSize:12.f];
		feintPtsLabel.text = [NSString stringWithFormat:@"%u", user.gamerScore];
		[self addSubview:feintPtsLabel];
		
		playerNameLabel = [[UILabel alloc] init];
		playerNameLabel.backgroundColor = [UIColor clearColor];
		playerNameLabel.textColor = [UIColor whiteColor];	
		playerNameLabel.shadowColor = [UIColor blackColor];
		playerNameLabel.shadowOffset = CGSizeMake(0, -1);
		playerNameLabel.font = [UIFont boldSystemFontOfSize:15.f];
		playerNameLabel.text = user.name;
		[self addSubview:playerNameLabel];
		
		nowPlayingLabel = [[UILabel alloc] init];
		nowPlayingLabel.backgroundColor = [UIColor clearColor];
		nowPlayingLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];	
		nowPlayingLabel.shadowColor = [UIColor blackColor];
		nowPlayingLabel.shadowOffset = CGSizeMake(0, -1);
		nowPlayingLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:10.f];
		
		if ([user isLocalUser])
		{
			nowPlayingLabel.text = [NSString stringWithFormat:@"Playing %@", user.lastPlayedGameName];
		}
		else if ([user online]) 
		{
			nowPlayingLabel.text = [NSString stringWithFormat:@"playing %@", user.lastPlayedGameName];
            onlineStatusLabel = [[UILabel alloc] init];
            onlineStatusLabel.font =  [UIFont boldSystemFontOfSize:10.0];
            onlineStatusLabel.backgroundColor = [UIColor clearColor];
            onlineStatusLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:180.0/255.0 blue:90.0/255.0 alpha:1.0];
            onlineStatusLabel.shadowColor = [UIColor blackColor];
            onlineStatusLabel.shadowOffset = CGSizeMake(0, -1);
			onlineStatusLabel.text = @"ONLINE";
		} 
		else 
		{
			nowPlayingLabel.text = [NSString stringWithFormat:@"Last played %@", user.lastPlayedGameName];
		}
		
		[self addSubview:nowPlayingLabel];
		
		if (onlineStatusLabel)
		{
			[self addSubview:onlineStatusLabel];
		}
	}
	
	[self layoutSubviews];
}

- (void)layoutSubviews
{
	CGRect frame = self.frame;
	frame.origin = CGPointZero;
	
	bgView.contentMode = UIViewContentModeCenter;
	bgView.frame = frame;

	if (feintPtsLabel)
	{
		feintPtsLabel.contentMode = UIViewContentModeLeft;
		CGSize textSize = [feintPtsLabel.text sizeWithFont:feintPtsLabel.font];
		CGFloat labelWidth = kfFeintPtsPadRight + textSize.width;
		feintPtsLabel.frame = CGRectMake(frame.size.width - labelWidth, 0.f,
									labelWidth, frame.size.height);
		
		profileView.contentMode = UIViewContentModeCenter;
		profileView.shouldScaleImageToFillRect = YES;
		profileView.frame = CGRectMake(kfProfilePadLeft, kfProfilePadTop,
									   36.f, 36.f);

		[frameView removeFromSuperview];
		frameView = nil;

		// This is somewhat of a hack.
		// Our superview is an OFFramedContentWrapperView.
		// His superview is an OFBannerFrame.  Putting the frame into that view
		// will allow us to animate with the banner and render on top of the
		// border frame.
		// This will be null until about the third time we get layout,
		// but at that point, it'll work.
		UIView* frameOwner = self.superview.superview;
		if (frameOwner)
		{
			UIImage* frameImage = [OFImageLoader loadImage:@"OFPlayerFrame.png"];
			frameView = [[UIImageView alloc] initWithImage:frameImage];
			[frameOwner addSubview:frameView];
			[frameView release];
			frameView.contentMode = UIViewContentModeCenter;
			frameView.center = [self convertPoint:profileView.center toView:frameOwner];
		}
		
		if (onlineStatusLabel)
		{
			CGFloat statusOrigin = CGRectGetMaxX(frameView.frame) + kfOnlineStatusIconPadLeft;
			onlineStatusLabel.frame = CGRectMake(statusOrigin, (frame.size.height - kfOnlineStatusIconPadTop - 14.0)/2.0 + kfOnlineStatusIconPadTop,
                                                 40.0, 14.0);
		}
		
		CGFloat labelOrigin = CGRectGetMaxX((onlineStatusLabel ? onlineStatusLabel.frame : frameView.frame)) + kfLabelPadLeft;
		
		playerNameLabel.contentMode = UIViewContentModeCenter;
		CGSize playerNameSize = [playerNameLabel.text sizeWithFont:playerNameLabel.font];
		playerNameLabel.frame = CGRectMake(CGRectGetMaxX(frameView.frame) + kfLabelPadLeft, frame.size.height/2.0 - playerNameSize.height - kfNameLabelPadBottom,
										   playerNameSize.width, playerNameSize.height);

		nowPlayingLabel.contentMode = UIViewContentModeCenter;
		CGSize nowPlayingSize = [nowPlayingLabel.text sizeWithFont:nowPlayingLabel.font];
		nowPlayingLabel.frame = CGRectMake(labelOrigin - (onlineStatusLabel ? 5 : 0), frame.size.height/2.0 + kfPlayingLabelPadTop,
										   nowPlayingSize.width, nowPlayingSize.height);
		
		feintPtsView.contentMode = UIViewContentModeLeft;
		CGFloat imageWidth = labelWidth + kfFeintPtsPadLeft;
		feintPtsView.frame = CGRectMake(frame.size.width - imageWidth, 0,
										imageWidth, frame.size.height);
	}
	
	[self bringSubviewToFront:feintPtsLabel];
}

- (void) profilePictureTouched
{
	if ([bannerProvider respondsToSelector:@selector(bannerProfilePictureTouched)])
	{
		[bannerProvider performSelector:@selector(bannerProfilePictureTouched)];
	}
	else
	{
		[bannerProvider onBannerClicked];
	}
}

- (void) removeFromSuperview
{
	[frameView removeFromSuperview];
	frameView = nil;
	[super removeFromSuperview];
}

@end
