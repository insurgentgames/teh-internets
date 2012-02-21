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

#import "OFBadgeView.h"

#import "OFImageLoader.h"

#pragma mark Internal Interface

@interface OFBadgeView (Internal)
- (void)_commonInitWithLeftImage:(NSString*)leftImageName rightImage:(NSString*)rightImageName centerImage:(NSString*)centerImageName;
@end

#pragma mark Green Badge View

@implementation OFGreenBadgeView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[super _commonInitWithLeftImage:@"OFBadgeLeftGreen.png" rightImage:@"OFBadgeRightGreen.png" centerImage:@"OFBadgeCenterGreen.png"];
	}
	
	return self;
}

@end

#pragma mark Red Badge View

@implementation OFRedBadgeView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[super _commonInitWithLeftImage:@"OFBadgeLeftRed.png" rightImage:@"OFBadgeRightRed.png" centerImage:@"OFBadgeCenterRed.png"];
	}
	
	return self;
}

@end

#pragma mark Badge View

@implementation OFBadgeView

@synthesize label = valueLabel;

#pragma mark Initialization and Dealloc

- (void)_commonInitWithLeftImage:(NSString*)leftImageName rightImage:(NSString*)rightImageName centerImage:(NSString*)centerImageName
{
	self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = NO;
	self.opaque = NO;

	UIImage* leftCapImage = [OFImageLoader loadImage:leftImageName];
	UIImage* rightCapImage = [OFImageLoader loadImage:rightImageName];
	UIImage* centerImage = [OFImageLoader loadImage:centerImageName];
	
	CGRect myFrame = self.frame;
	CGRect frame;		

	leftCap = [[UIImageView alloc] initWithImage:leftCapImage];
	leftCap.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
	
	frame = leftCap.frame;
	frame.origin.x = 0.f;
	frame.origin.y = floorf((myFrame.size.height - centerImage.size.height) * 0.5f);
	leftCap.frame = frame;

	rightCap = [[UIImageView alloc] initWithImage:rightCapImage];
	rightCap.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

	frame = rightCap.frame;
	frame.origin.x = myFrame.size.width - frame.size.width;
	frame.origin.y = floorf((myFrame.size.height - centerImage.size.height) * 0.5f);
	rightCap.frame = frame;

	center = [[UIImageView alloc] initWithImage:centerImage];
	center.contentMode = UIViewContentModeScaleToFill;
	center.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	frame = center.frame;
	frame.origin.x = CGRectGetMaxX(leftCap.frame);
	frame.origin.y = floorf((myFrame.size.height - centerImage.size.height) * 0.5f);
	frame.size.width = myFrame.size.width - leftCap.frame.size.width - rightCap.frame.size.width;
	center.frame = frame;
	
	frame.origin.x = floorf(leftCapImage.size.width * 0.75f);
	frame.origin.y = -1.f;
	frame.size.width = myFrame.size.width - (2.f * frame.origin.x);
	frame.size.height = centerImage.size.height;
	valueLabel = [[UILabel alloc] initWithFrame:frame];
	valueLabel.font = [UIFont boldSystemFontOfSize:14.f];
	valueLabel.text = @"0";
	valueLabel.textAlignment = UITextAlignmentCenter;
	valueLabel.textColor = [UIColor whiteColor];
	valueLabel.backgroundColor = [UIColor clearColor];
	valueLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	[self addSubview:leftCap];
	[self addSubview:rightCap];
	[self addSubview:center];
	[self addSubview:valueLabel];
	
	self.hidden = YES;
}

- (id)initWithLeftImage:(NSString*)leftImageName rightImage:(NSString*)rightImageName centerImage:(NSString*)centerImageName
{
	self = [super initWithFrame:CGRectZero];
	if (self != nil)
	{
		[self _commonInitWithLeftImage:leftImageName rightImage:rightImageName centerImage:centerImageName];
	}
	
	return self;
}

- (void)dealloc
{
	[leftCap removeFromSuperview];
	OFSafeRelease(leftCap);
	
	[rightCap removeFromSuperview];
	OFSafeRelease(rightCap);
	
	[center removeFromSuperview];
	OFSafeRelease(center);
	
	[valueLabel removeFromSuperview];
	OFSafeRelease(valueLabel);
	
	[super dealloc];
}

#pragma mark Creators

+ (id)redBadge
{
	return [[[OFBadgeView alloc] initWithLeftImage:@"OFBadgeLeftRed.png" rightImage:@"OFBadgeRightRed.png" centerImage:@"OFBadgeCenterRed.png"] autorelease];
}

+ (id)greenBadge
{
	return [[[OFBadgeView alloc] initWithLeftImage:@"OFBadgeLeftGreen.png" rightImage:@"OFBadgeRightGreen.png" centerImage:@"OFBadgeCenterGreen.png"] autorelease];
}

#pragma mark Class Methods

+ (CGSize)minimumSize
{
	static CGSize minSize = { 29.f, 29.f };
	return minSize;
}

#pragma mark UIView

- (void)setFrame:(CGRect)_frame
{
	CGSize minSize = [OFBadgeView minimumSize];
	_frame.size.width = MAX(minSize.width, _frame.size.width);
	_frame.size.height = MAX(minSize.height, _frame.size.height);	
	[super setFrame:_frame];
}

#pragma mark Property Methods

- (NSInteger)value
{
	return [valueLabel.text intValue];
}

- (void)setValue:(NSInteger)badgeValue
{
	[self setValueText:[NSString stringWithFormat:@"%d", badgeValue]];
}

- (void)setValueText:(NSString*)valueText
{
	float textWidth = [valueText sizeWithFont:valueLabel.font].width;
	
	float widthDelta = textWidth - valueLabel.frame.size.width;
	
	CGRect frame = self.frame;
	frame.origin.x -= ceilf(widthDelta * 0.5f);
	frame.size.width += widthDelta;
	self.frame = frame;
	
	valueLabel.text = valueText;
	
	self.hidden = ([valueText isEqualToString:@"0"]);
}

@end
