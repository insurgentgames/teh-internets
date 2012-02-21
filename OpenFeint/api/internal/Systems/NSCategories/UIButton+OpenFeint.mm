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

#import "UIButton+OpenFeint.h"
#import "IPhoneOSIntrospection.h"

@implementation UIButton (OpenFeint)

- (void)setTitleForAllStates:(NSString*)title
{
	[self setTitle:title forState:UIControlStateNormal];
	[self setTitle:title forState:UIControlStateHighlighted];
	[self setTitle:title forState:UIControlStateDisabled];
	[self setTitle:title forState:UIControlStateSelected];
}

- (void)setTitleColorForAllStates:(UIColor*)color
{
	[self setTitleColor:color forState:UIControlStateNormal];
	[self setTitleColor:color forState:UIControlStateHighlighted];
	[self setTitleColor:color forState:UIControlStateDisabled];
	[self setTitleColor:color forState:UIControlStateSelected];
}

- (void)setTitleShadowColorForAllStates:(UIColor*)shadowColor
{
	[self setTitleShadowColor:shadowColor forState:UIControlStateNormal];
	[self setTitleShadowColor:shadowColor forState:UIControlStateDisabled];
	[self setTitleShadowColor:shadowColor forState:UIControlStateSelected];
	[self setTitleShadowColor:shadowColor forState:UIControlStateHighlighted];
}

- (void)setTitleShadowOffsetSafe:(CGSize)shadowOffset
{
#ifndef __IPHONE_3_0	
	[(id)self setTitleShadowOffset:shadowOffset];
#else
	if (is2PointOhSystemVersion())
		[(id)self setTitleShadowOffset:shadowOffset];
	else if (is3PointOhSystemVersion())
		[self.titleLabel setShadowOffset:shadowOffset];
#endif
}

- (void)setBackgroundImageForAllStates:(UIImage*)image
{
	[self setBackgroundImage:image forState:UIControlStateNormal];
	[self setBackgroundImage:image forState:UIControlStateDisabled];
	[self setBackgroundImage:image forState:UIControlStateSelected];
	[self setBackgroundImage:image forState:UIControlStateHighlighted];
}

@end
