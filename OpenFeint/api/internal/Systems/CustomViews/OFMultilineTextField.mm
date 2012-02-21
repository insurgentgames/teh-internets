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

#import "OFMultilineTextField.h"

@implementation OFMultilineTextField

#pragma mark Boilerplate

- (void)dealloc
{
	[backgroundTextField removeFromSuperview];
	OFSafeRelease(backgroundTextField);
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	CGRect backgroundFrame = self.frame;
	backgroundFrame.origin = CGPointZero;
	backgroundTextField = [[UITextField alloc] initWithFrame:backgroundFrame];
	backgroundTextField.borderStyle = UITextBorderStyleRoundedRect;
	backgroundTextField.userInteractionEnabled = NO;
	backgroundTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
	[self addSubview:backgroundTextField];
	[self sendSubviewToBack:backgroundTextField];
}

#pragma mark UIScrollView

- (void)setContentOffset:(CGPoint)offset
{
	[super setContentOffset:offset];
	
	CGRect backgroundFrame = backgroundTextField.frame;
	backgroundFrame.origin = CGPointMake(floorf(offset.x), floorf(offset.y));
	backgroundTextField.frame = backgroundFrame;
}

- (void)setContentInset:(UIEdgeInsets)insets
{
	insets.top = 4.f;
	[super setContentInset:insets];
}

@end
