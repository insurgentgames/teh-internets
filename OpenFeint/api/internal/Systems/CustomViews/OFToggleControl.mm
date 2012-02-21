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

#import "OFToggleControl.h"

@implementation OFToggleControl

@synthesize isLeftSelected = mIsLeftSelected;

- (void)_commonInit
{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	
	mIsLeftSelected = YES;
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
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(mImageLeftSelected);
	OFSafeRelease(mImageRightSelected);
	
	[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	
	if ([touch tapCount] == 1)
	{
		mIsLeftSelected = !mIsLeftSelected;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}

	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGPoint pos = CGPointMake(0.0f, 0.0f);
	
	if (mIsLeftSelected)
		[mImageLeftSelected drawAtPoint:pos];
	else
		[mImageRightSelected drawAtPoint:pos];
}

- (void)setLeftSelected:(BOOL)isLeftSelected
{
	mIsLeftSelected = isLeftSelected;
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[self setNeedsDisplay];
}

- (void)setImageForLeftSelected:(UIImage*)selected
{
	OFSafeRelease(mImageLeftSelected);
	mImageLeftSelected = [selected retain];
}

- (void)setImageForRightSelected:(UIImage*)selected
{
	OFSafeRelease(mImageRightSelected);
	mImageRightSelected = [selected retain];
}

@end