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

@interface OFPatternedGradientView : UIView
{
	CGGradientRef mGradient;
	UIImage* mPattern;
	CGPoint mDirection;
}

@property (nonatomic, readonly) UIImage* patternImage;

+ (CGGradientRef)createDefaultGradient;
+ (id)defaultView:(CGRect)frame;
+ (id)introView;

- (id)initWithFrame:(CGRect)_frame
	gradient:(CGGradientRef)_gradient
	patternImage:(NSString*)_patternImageName;
	
- (void)setGradientAngle:(CGFloat)angleRadians;

@end

@interface OFUnframedIntroPatternedGradientView : OFPatternedGradientView
@end

@interface OFIntroPatternedGradientView : OFUnframedIntroPatternedGradientView
@end

@interface OFProfilePatternedGradientView : OFPatternedGradientView
@end

@interface OFButtonPanelPatternedGradientView : OFPatternedGradientView
@end
