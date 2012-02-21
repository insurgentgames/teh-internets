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

#import "OFBadgeButton.h"
#import "OFBadgeView.h"

@interface OFBadgeButton (Internal)
- (void)_positionBadge;
- (void)_calcContentInset;
@end

@implementation OFBadgeButton

- (void)dealloc
{
	OFSafeRelease(badgeView);
	[super dealloc];
}

- (void)awakeFromNib
{
	CGRect parentRect = self.frame;
	badgeOffset = CGPointMake(badgeView.frame.origin.x - parentRect.origin.x, 
                              badgeView.frame.origin.y - parentRect.origin.y);
	
	awaken = true;
	
	[self _positionBadge];
	[super awakeFromNib];
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];
	[[self superview] insertSubview:badgeView aboveSubview:self];
}

- (void)_positionBadge
{
	if (awaken)
	{
		CGRect bgRect = CGRectMake(self.frame.origin.x + badgeOffset.x, 
								   self.frame.origin.y + badgeOffset.y, 
								   badgeView.frame.size.width, 
								   badgeView.frame.size.height);
		badgeView.frame = bgRect;
	}
}

- (void)layoutSubviews
{
	[self _positionBadge];
	[super layoutSubviews];
}

- (void)setFrame:(CGRect)_frame
{
	[super setFrame:_frame];
	[self _positionBadge];
}

- (void)setCenter:(CGPoint)_center
{
	[super setCenter:_center];
	[self _positionBadge];
}

- (NSInteger)badgeNumber
{
	return badgeView.value;
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber
{
	badgeView.value = badgeNumber;
}

@end