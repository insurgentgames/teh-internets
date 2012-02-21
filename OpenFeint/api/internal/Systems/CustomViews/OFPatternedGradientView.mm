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

#import "OFPatternedGradientView.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"
#import "OFContentFrameView.h"

@implementation OFPatternedGradientView

@synthesize patternImage = mPattern;

#pragma mark Creators

+ (CGGradientRef)createDefaultGradient
{
	CGFloat locations[2] = { 
		0.0, 
		1.0 
	};
	CGFloat components[4] = { 
		128.f / 255.f, 1.f, 
		87.f / 255.f, 1.f 
	};

	CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(graySpace, components, locations, 2);
	CFRelease(graySpace);
	
	return gradient;
}

+ (CGGradientRef)createLightGradient
{
	CGFloat locations[2] = { 
		0.0, 
		1.0 
	};
	CGFloat components[4] = { 
		230.f / 255.f, 1.f, 
		155.f / 255.f, 1.f 
	};

	CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(graySpace, components, locations, 2);
	CFRelease(graySpace);
	
	return gradient;
}

+ (id)defaultView:(CGRect)frame
{
	CGGradientRef gradient = [OFPatternedGradientView createDefaultGradient];
	OFPatternedGradientView* view = [[[OFPatternedGradientView alloc] initWithFrame:frame gradient:gradient patternImage:@"OFIntroPattern.png"] autorelease];	
	CFRelease(gradient);
	[view setGradientAngle:M_PI * 0.5f];
	return view;
}

+ (id)introView
{
	CGGradientRef gradient = [OFPatternedGradientView createLightGradient];
	OFPatternedGradientView* view = [[[OFPatternedGradientView alloc] initWithFrame:[OpenFeint getDashboardBounds] gradient:gradient patternImage:@"OFIntroPattern.png"] autorelease];	
	CFRelease(gradient);
	[view setGradientAngle:73.f * (M_PI / 180.f)];
	return view;
}

#pragma mark Boilerplate

- (id)initWithFrame:(CGRect)_frame
	gradient:(CGGradientRef)_gradient
	patternImage:(NSString*)_patternImageName
{
	self = [super initWithFrame:_frame];
	if (self != nil)
	{
        self.opaque = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		if (_gradient != nil)
		{
			mGradient = (CGGradientRef)CFRetain(_gradient);
		}
		
		if ([_patternImageName length] > 0)
		{
			mPattern = [[OFImageLoader loadImage:_patternImageName] retain];
		}
	}
	
	return self;
}

- (void)dealloc
{
	if (mGradient != nil)
	{
		CFRelease(mGradient);
		mGradient = nil;
	}
	
	OFSafeRelease(mPattern);
	
	[super dealloc];
}

#pragma mark Public  Methods

- (void)setGradientAngle:(CGFloat)angleRadians
{
	mDirection = CGPointMake(cosf(angleRadians), sinf(angleRadians));
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	
	CGContextSetBlendMode(ctx, kCGBlendModeNormal);
	
	if (mGradient != nil)
	{
		float projectionLen = (mDirection.x * rect.size.width) + (mDirection.y * rect.size.height);
		
		CGPoint start = rect.origin;
		CGPoint end = CGPointMake( 
			rect.origin.x + (projectionLen * mDirection.x),
			rect.origin.y + (projectionLen * mDirection.y)
		);

		CGContextDrawLinearGradient(ctx, mGradient, start, end, 0);
	}

	if (mPattern != nil)
	{
		[mPattern drawAsPatternInRect:rect];
	}

	CGContextRestoreGState(ctx);
}

@end

#pragma mark OFUnframedIntroPatternedGradientView

@implementation OFUnframedIntroPatternedGradientView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		self.opaque = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		mGradient = [OFPatternedGradientView createLightGradient];
		mPattern = [[OFImageLoader loadImage:@"OFIntroPattern.png"] retain];
		[self setGradientAngle:73.f * (M_PI / 180.f)];
	}
	return self;
}

@end

#pragma mark OFIntroPatternedGradientView

@implementation OFIntroPatternedGradientView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
        CGRect contentFrameRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        OFContentFrameView *contentFrame = [[[OFContentFrameView alloc] initWithFrame:contentFrameRect] autorelease];
        contentFrame.tag = 101;
        contentFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentFrame];
	}
	return self;
}

@end

#pragma mark OFProfilePatternedGradientView

@implementation OFProfilePatternedGradientView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		self.opaque = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		mGradient = nil;
		mPattern = [[OFImageLoader loadImage:@"OFProfileBackgroundPattern.png"] retain];
	}
	return self;
}

@end

#pragma mark OFButtonPanelPatternedGradientView

@implementation OFButtonPanelPatternedGradientView

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		self.opaque = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		mGradient = nil;
		mPattern = [[OFImageLoader loadImage:@"OFButtonPanelBackgroundPattern.png"] retain];
	}
	return self;
}

@end
