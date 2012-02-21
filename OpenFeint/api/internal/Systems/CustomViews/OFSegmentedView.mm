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

#import "OFSegmentedView.h"
#import "OFImageLoader.h"
#import "OFBadgeView.h"

@implementation OFSegmentedView

- (id)initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if (self != nil)
	{
		[self setupDefaults];
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super initWithCoder:coder];
	if (self != nil)
	{
		[self setupDefaults];
	}
	return self;
}
			
- (void)setupDefaults
{
	self.style = OFTabBarStyleSegments;
	self.inactiveTextColor = [UIColor colorWithWhite:98.f/255.f alpha:1.f];
//	self.inactiveShadowColor = [UIColor colorWithWhite:98.f/255.f alpha:0.5f];
	self.activeTextColor = [UIColor colorWithWhite:98.f/255.f alpha:1.f];
//	self.activeShadowColor = [UIColor colorWithWhite:98.f/255.f alpha:0.5f];
	self.backgroundImage = nil;
	self.inactiveItemBackgroundImage = [[OFImageLoader loadImage:@"OFTabBarOverlappingSegment.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:0];
	self.activeItemBackgroundImage   = [[OFImageLoader loadImage:@"OFTabBarOverlappingSegmentActive.png"] stretchableImageWithLeftCapWidth:27 topCapHeight:0];
	self.dividerImage = nil;
	self.leftPadding = -1;
	self.rightPadding = -3;
	self.overlap = -1;
	self.textAlignment = UITextAlignmentCenter;
	self.labelPadding = CGRectMake(31, 1, 0, 0);
	
	self.badgeOffset = CGPointMake(-10.f, 2.0f);		
}


+ (float)segmentedViewHeight
{
	return 33.f;
}

@end
