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

#import "OFFramedContentWrapperView.h"

#import "OpenFeint+Private.h"

@implementation OFFramedContentWrapperView

@synthesize wrappedView, delegate;

- (id)initWithWrappedView:(UIView*)_wrappedView
{
	self = [super initWithFrame:_wrappedView.frame];
	if (self != nil)
	{
		wrappedView = [_wrappedView retain];
		contentInsets = UIEdgeInsetsZero;
		
		[self addSubview:wrappedView];
	}
	
	return self;
}

- (void)_updateWrappedView
{
	CGRect insetFrame = self.frame;
	insetFrame.origin = CGPointMake(contentInsets.left, contentInsets.top);
	insetFrame.size.height -= contentInsets.top + contentInsets.bottom;
	insetFrame.size.width -= contentInsets.left + contentInsets.right;

	[wrappedView setFrame:insetFrame];
	if ([wrappedView isKindOfClass:[UIScrollView class]])
	{
		UIScrollView* scrollView = (UIScrollView*)wrappedView;
		[scrollView setContentSize:CGSizeMake(insetFrame.size.width, scrollView.contentSize.height)];
	}
}

- (void)setContentInsets:(UIEdgeInsets)_contentInsets
{
	contentInsets = _contentInsets;
	[self _updateWrappedView];
}

- (void)setFrame:(CGRect)_frame
{
	[super setFrame:_frame];
	if (nil == delegate || ![delegate frameWasSet:self])
	{
		[self _updateWrappedView];
	}
}

- (void)dealloc
{
	OFSafeRelease(wrappedView);
	[super dealloc];
}

@end