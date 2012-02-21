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

#pragma once

#import <UIKit/UIKit.h>
#import "UIButton+OpenFeint.h"

@interface OFDefaultButton : UIButton
{
	IBOutlet UIImageView* iconImageView;
}

+ (id)redBorderedButton:(CGRect)_frame;
+ (id)greenBoderedButton:(CGRect)_frame;
+ (id)greenButton:(CGRect)_frame;
+ (id)textButton:(CGRect)_frame;

- (id)initWithFrame:(CGRect)frame normalImage:(NSString*)normalImageName hitImage:(NSString*)hitImageName;

+ (void)setupButton:(OFDefaultButton*)button;

@end

// Auxiliary class for InterfaceBuilder creation of red buttons with borders
@interface OFRedBorderedButton : OFDefaultButton
@end

// Auxiliary class for InterfaceBuilder creation of green buttons with borders
@interface OFGreenBorderedButton : OFDefaultButton
@end

// Auxiliary class for InterfaceBuilder creation of gray buttons with borders
@interface OFGreyBorderedButton : OFDefaultButton
@end

// Auxiliary class for InterfaceBuilder creation of green buttons without borders
@interface OFGreenButton : OFDefaultButton
@end

// Auxiliary class for InterfaceBuilder creation of buttons without backgrounds
@interface OFTextButton : OFDefaultButton
@end

// Auxiliary class for InterfaceBuilder creation of buttons with simple bevels
@interface OFBevelButton : OFDefaultButton
@end
