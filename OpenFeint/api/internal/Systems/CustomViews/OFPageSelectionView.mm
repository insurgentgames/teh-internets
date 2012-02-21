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

#import "OFPageSelectionView.h"

@implementation OFPageSelectionView

#pragma mark Boilerplate

- (void)dealloc
{
	OFSafeRelease(pageScroller);
	[super dealloc];
}

- (id)initWithFrame:(CGRect)_frame maxPages:(NSInteger)_maxPages
{
	self = [super initWithFrame:_frame];
	if (self != nil)
	{
		CGRect scrollerFrame = _frame;
		scrollerFrame.origin = CGPointZero;

		float elementWidth = 30.f;
		
		pageScroller = [[UIScrollView alloc] initWithFrame:scrollerFrame];
		pageScroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		pageScroller.contentSize = CGSizeMake(_maxPages * elementWidth, _frame.size.height);	// XXX paging
//		pageScroller.contentSize = CGSizeMake((_maxPages * elementWidth) + _frame.size.width - elementWidth, _frame.size.height);
		pageScroller.showsHorizontalScrollIndicator = NO;
		pageScroller.showsVerticalScrollIndicator = NO;
		pageScroller.scrollsToTop = NO;
		pageScroller.pagingEnabled = YES;
		pageScroller.delegate = self;
		
		float x = 0.f;	// XXX paging
//		float x = (_frame.size.width * 0.5f) - (elementWidth * 0.5f);

		UILabel* pageElement = nil;
		
		for (NSInteger i = 0; i < _maxPages; ++i)
		{
			CGRect elementFrame = CGRectMake(x, 0.f, elementWidth, _frame.size.height);
			x += elementWidth;
			pageElement = [[[UILabel alloc] initWithFrame:elementFrame] autorelease];
			[pageElement setBackgroundColor:[UIColor clearColor]];
			[pageElement setTextAlignment:UITextAlignmentCenter];
			[pageElement setFont:[UIFont boldSystemFontOfSize:10.f]];
			[pageElement setText:[NSString stringWithFormat:@"%d", i+1]];			
			[pageScroller addSubview:pageElement];
		}
		
		maxPages = _maxPages;
		
		[self addSubview:pageScroller];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView*)sender
{
    float pageWidth = pageScroller.frame.size.height;
    int page = floorf((pageScroller.contentOffset.x - pageWidth * 0.5f) / pageWidth) + 1;
	
	if (page != iDontGetItYet)
	{
		currentPage = page;
		iDontGetItYet = -1;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView 
{
    iDontGetItYet = -1;
}

@end
