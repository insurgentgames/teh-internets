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

#import "OFDefaultButton.h"
#import "OFImageLoader.h"
#import "UIButton+OpenFeint.h"
#import "NSObject+WeakLinking.h"

namespace
{
	static float const kBorderWidth = 6.f;
	static float const kIconPad = 4.f;
}

#pragma mark Internal Interface

@interface OFDefaultButton (Internal)
- (void)_setupBackgroundImage:(NSString*)bgImageName hitImage:(NSString*)bgHitImageName;
- (void)_setupStandardButtonAttributes;
- (void)_handleInitialIconPlacement;
- (void)_adjustTitleForIcon;
@end

#pragma mark OFDefaultButton

@implementation OFDefaultButton

#pragma mark Boilerplate Initialize / Dealloc

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[[self class] setupButton:self];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame normalImage:(NSString*)normalImageName hitImage:(NSString*)hitImageName;
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self _setupBackgroundImage:normalImageName hitImage:hitImageName];
		[self _setupStandardButtonAttributes];
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(iconImageView);
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];	
	[self _handleInitialIconPlacement];
}

#pragma mark Creators

+ (id)redBorderedButton:(CGRect)_frame
{
	return [[[OFDefaultButton alloc] initWithFrame:_frame normalImage:@"OFButtonRed.png" hitImage:@"OFButtonRedHit.png"] autorelease];
}

+ (id)greenBoderedButton:(CGRect)_frame
{
	return [[[OFDefaultButton alloc] initWithFrame:_frame normalImage:@"OFButtonGreen.png" hitImage:@"OFButtonGreenHit.png"] autorelease];
}

+ (id)greenButton:(CGRect)_frame
{
	return [[[OFDefaultButton alloc] initWithFrame:_frame normalImage:@"OFButtonSmallGreen.png" hitImage:@"OFButtonSmallGreenHit.png"] autorelease];	
}

+ (id)textButton:(CGRect)_frame
{
	return [[[OFDefaultButton alloc] initWithFrame:_frame normalImage:nil hitImage:nil] autorelease];
}

#pragma mark Icon Support

- (void)_handleInitialIconPlacement
{
	[self setNeedsLayout];
	[self _adjustTitleForIcon];
}

- (void)_adjustTitleForIcon
{
	if (iconImageView != nil)
	{
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.contentEdgeInsets = UIEdgeInsetsMake(0.f, iconImageView.image.size.width + kIconPad, 0.f, 0.f);
	}
}

#pragma mark UIView

- (void)layoutSubviews
{
	[super layoutSubviews];

	if (iconImageView != nil)
	{
		CGPoint centerPoint = CGPointMake(
			kBorderWidth + kIconPad + floorf(iconImageView.image.size.width * 0.5f),
			floorf(self.frame.size.height * 0.5f)
		);
		centerPoint.x += self.frame.origin.x;
		centerPoint.y += self.frame.origin.y;
		iconImageView.center = centerPoint;
	}
}

- (void)setFrame:(CGRect)_frame
{
	[super setFrame:_frame];
	[self _adjustTitleForIcon];
}

- (void)setHidden:(BOOL)_hidden
{
	[super setHidden:_hidden];
	iconImageView.hidden = _hidden;
}

#pragma mark OFDefaultButton

- (void)setTitleForAllStates:(NSString*)buttonTitle
{
	[super setTitleForAllStates:buttonTitle];
	[self _adjustTitleForIcon];
}

+ (void)setupButton:(OFDefaultButton*)button
{
	[OFGreenBorderedButton setupButton:button];
}

#pragma mark Internal Methods

- (void)_setupBackgroundImage:(NSString*)bgImageName hitImage:(NSString*)bgHitImageName
{
	UIImage* normalImage = nil;
	UIImage* selectedImage = nil;
	
	if (bgImageName)
	{
		normalImage = [OFImageLoader loadImage:bgImageName];
		normalImage = [normalImage stretchableImageWithLeftCapWidth:floorf(normalImage.size.width * 0.5f) topCapHeight:0];
		
		CGRect frame = self.frame;
		frame.size.height = normalImage.size.height;
		self.frame = frame;
	}

	if (bgHitImageName)
	{
		selectedImage = [OFImageLoader loadImage:bgHitImageName];
		selectedImage = [selectedImage stretchableImageWithLeftCapWidth:floorf(selectedImage.size.width * 0.5f) topCapHeight:0];
	}
	else
	{
		selectedImage = normalImage;
	}

	[self setBackgroundImage:normalImage forState:UIControlStateNormal];
	[self setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
}

- (void)_setupStandardButtonAttributes
{
	[self setTitleShadowOffsetSafe:CGSizeMake(0.f, -1.f)];

	UIColor* magicColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f];
	UIColor* magicColor2 = [UIColor colorWithWhite:0.f alpha:1.f];
	UIColor* magicColor3 = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1.f];
	if (CGColorEqualToColor(self.currentTitleColor.CGColor, magicColor.CGColor) ||
		CGColorEqualToColor(self.currentTitleColor.CGColor, magicColor2.CGColor) ||
		CGColorEqualToColor(self.currentTitleColor.CGColor, magicColor3.CGColor))
	{
		[self setTitleColorForAllStates:[UIColor whiteColor]];
		[self setTitleShadowColorForAllStates:[UIColor darkGrayColor]];
	}
}

@end

#pragma mark Grey Bordered Button

@implementation OFGreyBorderedButton

+ (void)setupButton:(OFDefaultButton*)button
{
	[button _setupBackgroundImage:@"OFButtonGrey.png" hitImage:@"OFButtonGrey.png"];
	[button _setupStandardButtonAttributes];
}

@end

#pragma mark Red Bordered Button

@implementation OFRedBorderedButton

+ (void)setupButton:(OFDefaultButton*)button
{
	[button _setupBackgroundImage:@"OFButtonRed.png" hitImage:@"OFButtonRedHit.png"];
	[button _setupStandardButtonAttributes];
}

@end

#pragma mark Green Bordered Button

@implementation OFGreenBorderedButton

+ (void)setupButton:(OFDefaultButton*)button
{
	[button _setupBackgroundImage:@"OFButtonGreen.png" hitImage:@"OFButtonGreenHit.png"];
	[button _setupStandardButtonAttributes];
}

@end

#pragma mark Green Button

@implementation OFGreenButton

+ (void)setupButton:(OFDefaultButton*)button
{
	[button _setupBackgroundImage:@"OFButtonSmallGreen.png" hitImage:@"OFButtonSmallGreenHit.png"];
	[button _setupStandardButtonAttributes];
}

@end

#pragma mark Text Button

@implementation OFTextButton

+ (void)setupButton:(OFDefaultButton*)button
{
	[button _setupBackgroundImage:nil hitImage:nil];
	[button _setupStandardButtonAttributes];
}

@end

#pragma mark Bevel Button

@implementation OFBevelButton

+ (void)setupButton:(OFDefaultButton*)button
{
	UIImage* normalImage = [[OFImageLoader loadImage:@"OFButtonBevel.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];
	UIImage* selectedImage = [[OFImageLoader loadImage:@"OFButtonBevelHit.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1];

	[button setBackgroundImage:normalImage forState:UIControlStateNormal];
	[button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];

	[button setTitleShadowOffsetSafe:CGSizeMake(0.f, -1.f)];

	UIColor* magicColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.f];
	UIColor* magicColor2 = [UIColor colorWithWhite:0.f alpha:1.f];
	UIColor* magicColor3 = [UIColor colorWithRed:50.f/255.f green:79.f/255.f blue:133.f/255.f alpha:1.f];
	if (CGColorEqualToColor(button.currentTitleColor.CGColor, magicColor.CGColor) ||
		CGColorEqualToColor(button.currentTitleColor.CGColor, magicColor2.CGColor) ||
		CGColorEqualToColor(button.currentTitleColor.CGColor, magicColor3.CGColor))
	{
		[button setTitleColorForAllStates:[UIColor whiteColor]];
		[button setTitleShadowColorForAllStates:[UIColor colorWithWhite:0.f alpha:0.5f]];
	}
}

@end
