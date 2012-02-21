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

#import "OFButtonPanel.h"

#pragma mark OFButtonPanelEntry Interface

@interface OFButtonPanelEntry : UIView
{
	UIView* button;
	UIView* decoration;
}

+ (id)entryWithButton:(UIButton*)_button;

@property (nonatomic, readonly) UIView* button;
@property (nonatomic, readonly) UIView* decoration;

- (void)replaceDecoration:(UIImage*)newDecoration;

@end

#pragma mark OFButtonPanelEntry Implementation

@implementation OFButtonPanelEntry

@synthesize button, decoration;

+ (id)entryWithButton:(UIButton*)_button
{
	_button.enabled = YES;
	_button.hidden = NO;

	OFButtonPanelEntry* entry = [[[OFButtonPanelEntry alloc] initWithFrame:_button.frame] autorelease];
	entry->button = [_button retain];
	[_button setFrame:CGRectMake(0.f, 0.f, _button.frame.size.width, _button.frame.size.height)];
	[entry addSubview:_button];
	return entry;
}

- (void)dealloc
{
	OFSafeRelease(button);
	OFSafeRelease(decoration);
	[super dealloc];
}

- (void)replaceDecoration:(UIImage*)newDecoration;
{
	[decoration removeFromSuperview];
	OFSafeRelease(decoration);
	
	if (newDecoration != nil)
	{
		decoration = [[UIImageView alloc] initWithImage:newDecoration];
		[decoration setContentMode:UIViewContentModeCenter];
		[decoration setFrame:button.frame];
		[self addSubview:decoration];
		[self bringSubviewToFront:decoration];
	}
}

@end

#pragma mark OFButtonPanel Implementation

@implementation OFButtonPanel

+ (id)panelWithFrame:(CGRect)_frame maxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage
{
	OFButtonPanel* panel = [[[OFButtonPanel alloc] 
		initWithFrame:_frame 
		maxButtonCount:_maxButtonCount 
		buttonSize:_buttonSize
		buttonSpacing:_buttonSpacing
		emptyImage:_emptyImage] autorelease];
	return panel;
}

- (id)initWithFrame:(CGRect)_frame maxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage
{
	self = [super initWithFrame:_frame];
	if (self != nil)
	{
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		maxButtonCount = _maxButtonCount;
		buttonSize = _buttonSize;
		buttonSpacing = _buttonSpacing;
		emptyButtonSlotImage = [_emptyImage retain];
		
		buttons = [[NSMutableArray arrayWithCapacity:_maxButtonCount] retain];
		[self removeAllButtons];
	}
	
	return self;
}

- (void)dealloc
{
	OFSafeRelease(buttons);
	OFSafeRelease(emptyButtonSlotImage);
	[super dealloc];
}

- (void)configureMaxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage
{
	maxButtonCount = _maxButtonCount;
	buttonSize = _buttonSize;
	buttonSpacing = _buttonSpacing;
	emptyButtonSlotImage = [_emptyImage retain];

	OFSafeRelease(buttons);
	buttons = [[NSMutableArray arrayWithCapacity:_maxButtonCount] retain];
	[self removeAllButtons];
	
}

- (void)setHeaderView:(UIView*)_headerView
{
	if (headerView)
	{
		[headerView removeFromSuperview];
		OFSafeRelease(headerView);
	}
	
	headerView = [_headerView retain];
	
	if (headerView)
	{
		[self addSubview:headerView];
	}
}

- (void)setMaxButtons:(int)buttonCount
{
	int oldButtonCount = maxButtonCount;
	maxButtonCount = buttonCount;
	
	if (maxButtonCount > oldButtonCount)
	{
		[self addPlaceholderButtons];
	}
	else
	{
		for (int i = maxButtonCount; i < buttonCount; ++i)
		{
			[(UIView*)[buttons objectAtIndex:i] removeFromSuperview];
			[buttons removeLastObject];
		}
	}
}

- (void)setButton:(UIButton*)_button atPosition:(int)index;
{
	OFAssert(CGSizeEqualToSize(buttonSize, _button.frame.size), "You cannot add buttons of different sizes to an OFButtonPanel!");
	
	UIView* oldButton = (UIView*)[buttons objectAtIndex:index];
	[oldButton removeFromSuperview];

	OFButtonPanelEntry* entry = [OFButtonPanelEntry entryWithButton:_button];
	[self addSubview:entry];

	[buttons replaceObjectAtIndex:index withObject:entry];
}

- (void)disableButton:(UIButton*)_button withDecorationImage:(UIImage*)decoration
{
	for (OFButtonPanelEntry* entry in buttons)
	{
		if ([entry isKindOfClass:[OFButtonPanelEntry class]] && entry.button == _button)
		{
			[_button setEnabled:NO];
			[entry replaceDecoration:decoration];
		}
	}
}

- (void)removeAllButtons
{
	for (UIView* button in buttons)
		[button removeFromSuperview];
		
	[buttons removeAllObjects];
	[self addPlaceholderButtons];
}

- (void)addPlaceholderButtons
{
	if (emptyButtonSlotImage != nil)
	{
		for (int i = [buttons count]; i < maxButtonCount; ++i)
		{
			UIImageView* placeholder = [[[UIImageView alloc] initWithImage:emptyButtonSlotImage] autorelease];
			[placeholder setContentMode:UIViewContentModeCenter];
			[placeholder setFrame:CGRectMake(0.f, 0.f, buttonSize.width, buttonSize.height)];
			[buttons addObject:placeholder];
			[self addSubview:placeholder];
		}
	}
	else
	{
		for (int i = [buttons count]; i < maxButtonCount; ++i)
		{
			UIView* placeholder = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, buttonSize.width, buttonSize.height)] autorelease];
			[buttons addObject:placeholder];
			[self addSubview:placeholder];
		}
	}
}

- (void)setFrame:(CGRect)_frame
{
	[super setFrame:_frame];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	if (!headerView && [buttons count] == 0)
		return;

	CGRect headerFrame = CGRectZero;
	if (headerView)
	{
		headerFrame = headerView.frame;
		headerFrame.origin.x = roundf((self.bounds.size.width - headerFrame.size.width) * 0.5f);
		headerFrame.origin.y = 0.f;
		headerView.frame = headerFrame;
	}
	
	float const availableHeight = self.frame.size.height - headerFrame.size.height;
	
	float cols = floorf((self.frame.size.width + buttonSpacing.width) / (buttonSize.width + buttonSpacing.width));
	float rows = floorf((availableHeight + buttonSpacing.height) / (buttonSize.height + buttonSpacing.height));
	
	CGPoint initialPos = CGPointMake(
		(self.frame.size.width - ((cols * buttonSize.width) + ((cols-1) * buttonSpacing.width))) * 0.5f,
		/*(availableHeight - ((rows * buttonSize.height) + ((rows-1) * buttonSpacing.height))) * 0.5f +*/ headerFrame.size.height);
	initialPos.x = roundf(initialPos.x);
	initialPos.y = roundf(initialPos.y);
	
	// So, this is a hack, but if we only have a single column, we're going for a
	// list-of-cells like appearance, and we actually want it to be aligned to the top.
	if (cols == 1.0f)
	{
		initialPos.y = 0.f;
	}
		
	CGPoint pos = initialPos;
	
	NSEnumerator* buttonEnumerator = [buttons objectEnumerator];

	UIView* button = nil;
	CGRect buttonRect;
	for (int y = 0; y < rows; ++y)
	{
		for (int x = 0; x < cols; ++x)
		{
			button = (UIView*)[buttonEnumerator nextObject];
			buttonRect = button.frame;
			buttonRect.origin = pos;
			[button setFrame:buttonRect];
			[button setHidden:NO];
			pos.x += buttonSize.width + buttonSpacing.width;
		}
		
		pos.x = initialPos.x;
		pos.y += buttonSize.height + buttonSpacing.height;
	}
	
	button = (UIView*)[buttonEnumerator nextObject];
	while (button != nil)
	{
		if (![button isKindOfClass:[UIImageView class]])
		{
			OFLog(@"Not enough room to place button (%@)", button);
		}

		[button setHidden:YES];
		button = (UIView*)[buttonEnumerator nextObject];
	}
}

@end