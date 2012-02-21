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

#import "OFTableCellBackgroundView.h"
#import "OFImageLoader.h"

@implementation OFTableCellBackgroundView

@synthesize image = mImage;
@synthesize edgeStyle = mEdgeStyle;
@synthesize tileImage = mTileImage;

+ (id)defaultBackgroundView
{
	return [[[OFTableCellBackgroundView alloc] initWithFrame:CGRectZero andImageName:nil andRoundedEdge:kRoundedEdge_None] autorelease];
}

- (id)initWithFrame:(CGRect)frame andImageName:(NSString*)imageName andRoundedEdge:(OFTableCellRoundedEdge)roundedEdge
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		
		if ([imageName length] > 0)
		{
			mImage = [[OFImageLoader loadImage:imageName] retain];
		}

		mEdgeStyle = roundedEdge;
		mTileImage = NO;
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(mImage);
	[super dealloc];
}

- (void)setImage:(UIImage*)_image
{
	if (mImage != _image)
	{
		OFSafeRelease(mImage);
		
		mImage = [_image retain];
		[self setNeedsDisplay];
	}
}

- (void)setEdgeStyle:(OFTableCellRoundedEdge)_edgeStyle
{
	if (mEdgeStyle != _edgeStyle)
	{
		mEdgeStyle = _edgeStyle;
		[self setNeedsDisplay];
	}
}

- (void)setTileImage:(BOOL)_tileImage
{
	if (mTileImage != _tileImage)
	{
		mTileImage = _tileImage;
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect
{
	float minx = CGRectGetMinX(rect);
	float miny = CGRectGetMinY(rect);
	float maxx = CGRectGetWidth(rect);
	float midx = maxx * 0.5f;
	float maxy = CGRectGetHeight(rect);
	float midy = maxy * 0.5f;

	float const radius = 10.0f;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	switch (mEdgeStyle)
	{
		case kRoundedEdge_Top:
		{
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, minx, midy);
			CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
			CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
			CGContextAddLineToPoint(ctx, maxx, maxy);
			CGContextAddLineToPoint(ctx, minx, maxy);
			CGContextAddLineToPoint(ctx, minx, midy);
			CGContextClosePath(ctx);
			CGContextClip(ctx);
		} break;
		
		case kRoundedEdge_Bottom:
		{
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, minx, midy);
			CGContextAddLineToPoint(ctx, minx, miny);
			CGContextAddLineToPoint(ctx, maxx, miny);
			CGContextAddLineToPoint(ctx, maxx, midy);
			CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
			CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
			CGContextClosePath(ctx);
			CGContextClip(ctx);
		} break;
		
		case kRoundedEdge_TopAndBottom:
		{
			CGContextBeginPath(ctx);
			CGContextMoveToPoint(ctx, minx, midy);
			CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
			CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
			CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
			CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
			CGContextClosePath(ctx);
			CGContextClip(ctx);
		} break;
		
		default: break;
	}

	if (mTileImage)
	{
		[mImage drawAsPatternInRect:rect];
	}
	else
	{
		[mImage drawInRect:rect];
	}
}

@end