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

#import "OFResumeView.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"

namespace 
{
	const float kGameIconSize = 20.f;
	const float kGameIconSizeLandscape = 15.f;
	const float kGameIconRightInset = 20.f;
	const float kStandardRightNavBarItemRightInset = 5.f;
	// Our nav bar has a drop shadow making it non standard size
	const float kNavBarHeightPortrait = 44.f;
	const float kNavBarHeightLandscape = 39.f;
}
@implementation OFResumeView

- (id)initWithAction:(SEL)action andTarget:(id)target
{
	self = [super initWithFrame:CGRectZero];
	if (self)
	{
		mAction = action;
		mTarget = target;
		const float navBarHeight = [OpenFeint isInLandscapeMode] ? kNavBarHeightLandscape : kNavBarHeightPortrait;
		mBackgroundView = [[UIImageView alloc] initWithImage:[OFImageLoader loadImage:@"OpenFeintResumeButtonBackground.png"]];
		mBackgroundView.autoresizingMask = UIViewAutoresizingNone;
		self.frame = mBackgroundView.frame;
		mBackgroundView.frame = CGRectMake(mBackgroundView.frame.origin.x + kStandardRightNavBarItemRightInset, 
										  navBarHeight - mBackgroundView.frame.size.height,
										  mBackgroundView.frame.size.width,
										  mBackgroundView.frame.size.height);
		
		self.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:mBackgroundView];
	}
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[mTarget performSelector:mAction];
}

- (void)dealloc
{
	OFSafeRelease(mBackgroundView);
	[super dealloc];
}

@end
