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
#import "OFBannerFrame.h"
#import "OFBannerProvider.h"
#import "OFContentFrameView.h"
#import "OFFramedContentWrapperView.h"
#import "OFBannerCell.h"

@implementation OFBannerFrame

- (void)dealloc
{
	OFSafeRelease(bannerSubview);
	OFSafeRelease(wrapperView);
	[super dealloc];
}

- (OFBannerCell*)bannerSubview
{
	return bannerSubview;
}

- (void)setBannerSubview:(OFBannerCell *)_bannerSubview
{
	if (bannerSubview)
	{
		[bannerSubview removeFromSuperview];
		OFSafeRelease(bannerSubview);
	}
	
	if (wrapperView)
	{
		[wrapperView removeFromSuperview];
		OFSafeRelease(wrapperView);
	}

	bannerSubview = [_bannerSubview retain];

	if (bannerSubview)
	{
		if (![bannerSubview isKindOfClass:[OFFramedContentWrapperView class]])
		{
			// Because of the super crazy OFPlayerBannerCell that requires it to have a grandparent
			// view to layout properly - make sure to add wrapper (with contained subview) before
			// setting content insets.
			wrapperView = [[OFFramedContentWrapperView alloc] initWithWrappedView:bannerSubview];
			wrapperView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
			[self addSubview:wrapperView];
			[self sendSubviewToBack:wrapperView];
			[wrapperView setContentInsets:[OFContentFrameView getContentInsets]];
		}
		else
		{
			[self addSubview:bannerSubview];
			[self sendSubviewToBack:bannerSubview];
		}
	}
}

- (void) setFrame:(CGRect)_frame
{
	[super setFrame:_frame];
	[wrapperView setFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
}

@end
