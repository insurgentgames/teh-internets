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

#import "OFRoundedRectView.h"
#import "OFImageLoader.h"

@implementation OFRoundedRectView

- (void)_commonInit
{
	[super setBackgroundColor:[UIColor clearColor]];

	self.opaque = NO;
	
	mRoundedRect = [[[OFImageLoader loadImage:@"OFRoundedRectBorder.png"] stretchableImageWithLeftCapWidth:10.f topCapHeight:10.f] retain];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[self _commonInit];
	}

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self _commonInit];
		mBackgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];	
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(mBackgroundColor);
	OFSafeRelease(mRoundedRect);
	[super dealloc];
}

- (void)setBackgroundColor:(UIColor*)backgroundColor
{
	OFSafeRelease(mBackgroundColor);
	mBackgroundColor = [backgroundColor retain];
}

- (void)drawRect:(CGRect)rect
{
	float minx = CGRectGetMinX(rect);
	float miny = CGRectGetMinY(rect);
	float maxx = CGRectGetWidth(rect);
	float midx = maxx * 0.5f;
	float maxy = CGRectGetHeight(rect);
	float midy = maxy * 0.5f;

	// adill note: photoshop radius used to make the rounded rect border image + 0.5f seems to make things work well.
	float const radius = 10.5f;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	CGContextSaveGState(ctx);
	{
		CGContextBeginPath(ctx);
		CGContextMoveToPoint(ctx, minx, midy);
		CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
		CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
		CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
		CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
		CGContextClosePath(ctx);
		CGContextClip(ctx);

		[mBackgroundColor setFill];
		CGContextFillRect(ctx, rect);
	}
	CGContextRestoreGState(ctx);

	[mRoundedRect drawInRect:rect];
}

@end