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
#import "OFFeaturedGameCell.h"
#import "OFImageLoader.h"
#import "OFGameDiscoveryImageHyperlink.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+NSNotification.h"
#import "OFImageView.h"
#import "OFPaginatedSeries.h"
#import "OpenFeint+UserOptions.h"
#import "OFGameDiscoveryService.h"

@implementation OFFeaturedGameCell

@synthesize imageHyperlinks, currentHyperlinkIndex, cyclingTimer;

- (OFGameDiscoveryImageHyperlink*)_getCurrentImageHyperlink
{
	if([self.imageHyperlinks count] == 0)
	{
		return nil;
	}
	
	return (OFGameDiscoveryImageHyperlink*)[self.imageHyperlinks objectAtIndex:self.currentHyperlinkIndex];
}

- (void)_stopCyclingHyperlinks
{
	inProgressTransitionRemainingSeconds = [[self.cyclingTimer fireDate] timeIntervalSinceNow];
	
	[self.cyclingTimer invalidate];
	self.cyclingTimer = nil;
}

- (void)_scheduleNextHyperlinkTransitionIn:(float)secondsUntilTransition
{
	[self.cyclingTimer invalidate];
	self.cyclingTimer = [NSTimer scheduledTimerWithTimeInterval:secondsUntilTransition
			 target:self
			 selector:@selector(_fadeToNextFeaturedGame)
			 userInfo:nil
			 repeats:NO];
}

- (void)_fadeToNextFeaturedGame
{
	if([self.imageHyperlinks count] == 0)
	{
		return;
	}
	
	self.currentHyperlinkIndex = self.currentHyperlinkIndex + 1;
	if(self.currentHyperlinkIndex >= [self.imageHyperlinks count])
	{
		self.currentHyperlinkIndex = 0;
	}
	
	OFGameDiscoveryImageHyperlink* nextHyperlink = [self _getCurrentImageHyperlink];
	[self.imageView setImageUrl:nextHyperlink.imageUrl crossFading:YES];
	[self _scheduleNextHyperlinkTransitionIn:nextHyperlink.secondsToDisplay];

	[self changeResource:nextHyperlink];	
}

- (void)onFeaturedGamesDownloaded:(OFPaginatedSeries*)page
{	
	OFAssert(self.imageView, "Image view needs to be valid for this to work.");
	
	self.imageHyperlinks = page.objects;	
	self.currentHyperlinkIndex = [self.imageHyperlinks count]; // Wrap from the beginning
	[self _fadeToNextFeaturedGame];
}

- (void)_changeBannerToOnline
{
	bgImageView.image = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerLandscape.png" : @"OFNowPlayingBanner.png")];
}

- (void)_changeBannerToOffline
{
	bgImageView.image = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerLandscapeOffline.png" : @"OFNowPlayingBannerOffline.png")];
}

- (void)_commonInit
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeBannerToOnline) name:OFNSNotificationUserOnline object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeBannerToOffline) name:OFNSNotificationUserOffline object:nil];

	UIImage* backgroundImage;

	if([OpenFeint isOnline])
	{
		backgroundImage = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerLandscape.png" : @"OFNowPlayingBanner.png")];
	}
	else
	{
		backgroundImage = [OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerOfflineLandscape.png" : @"OFNowPlayingBannerOffline.png")];
	}
		
	bgImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	[self addSubview:bgImageView];
	[bgImageView release];
	
	self.contentView.contentMode = UIViewContentModeScaleToFill;
	self.contentView.autoresizesSubviews = YES;
	
	self.imageView = [[[OFImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 42.0f)] autorelease];
	self.imageView.unframed = YES;
	self.imageView.useSharpCorners = YES;
	self.imageView.userInteractionEnabled = NO;
	self.imageView.contentMode = UIViewContentModeScaleToFill;
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
	self.imageView.shouldShowLoadingIndicator = NO;
	self.imageView.shouldScaleImageToFillRect = NO;	
	self.imageView.crossFadeDuration = 1.0f;
	self.imageView.backgroundColor = [UIColor clearColor];
	if ([OpenFeint isOnline]) {
		[self.imageView setDefaultImage:[OFImageLoader loadImage:([OpenFeint isInLandscapeMode] ? @"OFNowPlayingBannerLandscape.png" : @"OFNowPlayingBanner.png")]];
	}
	[self addSubview:self.imageView];
	
	if([OpenFeint isOnline])
	{
		// citron note: Make sure we initialize imageView before invoking the now playing URL request.
		//				that requiest depends on the image view existing;
		[OFGameDiscoveryService getNowPlayingFeaturedPlacement:OFDelegate(self, @selector(onFeaturedGamesDownloaded:)) onFailure:OFDelegate()];
	}
}

- (id)initOFTableCellHelper:(NSString*)reuseIdentifier
{
	self = [super initOFTableCellHelper:reuseIdentifier];
	[self _commonInit];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUserOnline object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUserOffline object:nil];

	self.imageHyperlinks = nil;
	self.imageView = nil;
	bgImageView = nil;
	
	[self _stopCyclingHyperlinks];
	
	[super dealloc];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)viewDidAppear
{
	[self _scheduleNextHyperlinkTransitionIn:inProgressTransitionRemainingSeconds];
}

- (void)viewDidDisappear
{
	[self _stopCyclingHyperlinks];
}

- (void)onResourceChanged:(OFResource*)resource
{
	// hide the parent implementation
}

@end
