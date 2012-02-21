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

#import "OFTabBarItem.h"
#import "OFBadgeView.h"
#import "OpenFeint+UserOptions.h"

namespace
{
	// move the icons up a bit
	static float const kIconYOffset = 5.f;
}

@implementation OFTabBarItem

@synthesize button, imageView, nameLabel, badgeView, borderImageView, backgroundView, hitImageView;
@synthesize active;
@synthesize viewController, viewControllerName, openFeintDisabledViewControllerName, name, activeImage, inactiveImage;
@synthesize disabled, disabledImage;

- (id)initWithParent:(OFTabBar*)aTabBarController
      viewController:(NSString*)aViewController
               named:(NSString*)aName
         activeImage:(UIImage*)anActiveImage
       inactiveImage:(UIImage*)anInactiveImage
       disabledImage:(UIImage*)aDisabledImage
{
	self = [self initWithFrame:CGRectMake(0, 0, aTabBarController.frame.size.width, aTabBarController.frame.size.height)];
	if (self != nil)
	{
		parent = aTabBarController;

		self.viewControllerName = aViewController;
		self.viewController = nil;
		self.name = aName;
		self.activeImage = anActiveImage;
		self.inactiveImage = anInactiveImage;
		self.disabled = NO;
		self.disabledImage = aDisabledImage;

		if (parent.style != OFTabBarStyleDashboard)
		{
			backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width + parent.overlap, self.frame.size.height)];
			backgroundView.contentMode = UIViewContentModeScaleToFill;
			backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			backgroundView.image = parent.inactiveItemBackgroundImage;
			[self addSubview:backgroundView];
				
			button = [[UIButton alloc] initWithFrame:self.frame];
			[button addTarget:self action:@selector(didTapTabItem) forControlEvents:UIControlEventTouchUpInside];
			[button addTarget:self action:@selector(didHit) forControlEvents:UIControlEventTouchDown];
			[button addTarget:self action:@selector(didCancelHit) forControlEvents:UIControlEventTouchUpOutside];
			[button addTarget:self action:@selector(didCancelHit) forControlEvents:UIControlEventTouchDragExit];
			button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self addSubview:button];

			hitImageView = [[UIImageView alloc] initWithImage:parent.hitOverlayImage];
			hitImageView.hidden = YES;
			[self addSubview:hitImageView];

			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 12)];
			imageView.image = inactiveImage;
			imageView.contentMode = UIViewContentModeCenter;
			imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			imageView.userInteractionEnabled = NO;
			[self addSubview:imageView];

			nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
			nameLabel.text = name;
			nameLabel.textAlignment = parent.textAlignment;
			
			if (parent.style == OFTabBarStyleTraditional)
				nameLabel.font = [UIFont boldSystemFontOfSize:10];
			else if (parent.style == OFTabBarStyleSegments)
				nameLabel.font = [UIFont boldSystemFontOfSize:14];

			nameLabel.textColor = parent.inactiveTextColor;
			nameLabel.shadowColor = parent.inactiveShadowColor;
			
			if (parent.inactiveShadowColor)
			{
				nameLabel.shadowOffset = CGSizeMake(0, 1);
			}
			
			nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
			nameLabel.backgroundColor = [UIColor clearColor];
			[self addSubview:nameLabel];
		}
		else
		{
			backgroundView = [[UIImageView alloc] initWithFrame:self.frame];
			backgroundView.contentMode = UIViewContentModeCenter;
			backgroundView.image = inactiveImage;
			[self addSubview:backgroundView];
			
			button = [[UIButton alloc] initWithFrame:self.frame];
			[button addTarget:self action:@selector(didTapTabItem) forControlEvents:UIControlEventTouchUpInside];
			[button addTarget:self action:@selector(didHit) forControlEvents:UIControlEventTouchDown];
			[button addTarget:self action:@selector(didCancelHit) forControlEvents:UIControlEventTouchUpOutside];
			[button addTarget:self action:@selector(didCancelHit) forControlEvents:UIControlEventTouchDragExit];
			button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self addSubview:button];
			
			imageView = [[UIImageView alloc] initWithFrame:self.frame];
			imageView.image = activeImage;
			imageView.contentMode = UIViewContentModeCenter;
			imageView.userInteractionEnabled = NO;
			imageView.alpha = 0.0;
			[self addSubview:imageView];
		}

			
		if (parent.style == OFTabBarStyleSegments)
		{
			self.nameLabel.frame = CGRectMake(parent.labelPadding.origin.x,
				parent.labelPadding.origin.y,
				self.frame.size.width  - parent.labelPadding.size.width + parent.overlap,
				self.frame.size.height - parent.labelPadding.size.height);			
		}

		// citron note: border should be below the badge
		borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, 0, parent.dividerImage.size.width, self.frame.size.height)];
		borderImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
		borderImageView.image = parent.dividerImage;
		[self addSubview:borderImageView];

		{
			self.badgeView = [OFBadgeView redBadge];
			[self addSubview:badgeView];
		}
	}
	return self;
}

- (IBAction)didTapTabItem
{
	if (!disabled) {
		[parent showTab:self];
	}
}

- (IBAction)didHit
{
	if( !disabled ) {
		hitImageView.hidden = NO;
		hitImageView.alpha = 1.0;
	}
}

- (IBAction)didCancelHit
{
	[UIView beginAnimations:@"fadeTabBarHit" context:nil];
	hitImageView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)setActive:(BOOL)activeValue
{
	if( !disabled )
	{
		BOOL wasActive = active;
		active = activeValue;
		
		if (active)
		{
			if (viewControllerName)
			{
				if (self.viewController == nil)
				{
					NSString* controllerToLoad = self.viewControllerName;
					if (self.openFeintDisabledViewControllerName && ![OpenFeint hasUserApprovedFeint])
					{
						controllerToLoad = self.openFeintDisabledViewControllerName;
					}
					self.viewController = [parent _loadTabItemViewController:controllerToLoad forTab:self];
				}
				
				[viewController viewWillAppear:NO];
				viewController.view.hidden = NO;
				[viewController viewDidAppear:NO];
				
				if (viewController.view.superview == nil)
				{
					[parent.superview insertSubview:viewController.view belowSubview:parent];
				}
			}
			
			viewController.view.frame = CGRectMake(
												   0.f, 0.f,
												   parent.superview.bounds.size.width, parent.superview.bounds.size.height - parent.bounds.size.height);
			
			if (parent.style == OFTabBarStyleDashboard)
			{
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.1];
				[UIView setAnimationBeginsFromCurrentState:YES];
				imageView.alpha = 1.0;
				[UIView commitAnimations];
			}
			else
			{
				backgroundView.image = parent.activeItemBackgroundImage;
				imageView.image = activeImage;
				nameLabel.textColor = parent.activeTextColor;
				nameLabel.shadowColor = parent.activeShadowColor;

				if (parent.pulse && wasActive != active)
					[self animatePulse];
			}
		}
		else
		{
			if (parent.style == OFTabBarStyleDashboard)
			{
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.1];
				[UIView setAnimationBeginsFromCurrentState:YES];
				imageView.alpha = 0.0;
				[UIView commitAnimations];
			}
			else
			{
				backgroundView.image = parent.inactiveItemBackgroundImage;
				imageView.image = inactiveImage;
				nameLabel.textColor = parent.inactiveTextColor;
				nameLabel.shadowColor = parent.inactiveShadowColor;

				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:0.1];
				[UIView setAnimationBeginsFromCurrentState:YES];
				imageView.alpha = 1.0;
				[UIView commitAnimations];
			}
			
			[viewController viewWillDisappear:NO];
			viewController.view.hidden = YES;
			[viewController viewDidDisappear:NO];
		}
		
		[self didCancelHit];
	}
}

- (void)_removeDisabledOverlay
{
	imageView.hidden = NO;
	
	[overlayView removeFromSuperview];
	OFSafeRelease(overlayView);
}

- (void)_addDisabledOverlay
{
	[self _removeDisabledOverlay];

	overlayView = [[UIView alloc] initWithFrame:backgroundView.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:(47.f / 255.f) alpha:(91.f / 255.f)];
	overlayView.opaque = NO;
	overlayView.autoresizesSubviews = NO;

	if (parent.disabledOverlayIconImage)
	{
		UIImageView* disabledIcon = [[[UIImageView alloc] initWithImage:parent.disabledOverlayIconImage] autorelease];
		disabledIcon.frame = CGRectMake(
			(overlayView.frame.size.width - disabledIcon.frame.size.width) * 0.5f, 
			5.f, 
			overlayView.frame.size.width, 
			disabledIcon.frame.size.height
		);
		disabledIcon.contentMode = UIViewContentModeCenter;
		[overlayView addSubview:disabledIcon];
		
		imageView.hidden = YES;
	}
	
	[self addSubview:overlayView];
}

- (void)setDisabled:(BOOL)disabledValue
{
	disabled = disabledValue;
	if (disabled) 
	{
		if (parent.style == OFTabBarStyleDashboard)
		{
			backgroundView.image = self.disabledImage ? self.disabledImage : self.inactiveImage;
		}
		else
		{
			backgroundView.image = parent.disabledItemBackgroundImage;
			nameLabel.textColor = parent.disabledTextColor;
			nameLabel.shadowColor = parent.disabledShadowColor;
			
			if (disabledImage)
			{
				imageView.image = disabledImage;
			}
			else
			{
				imageView.image = inactiveImage;
				[self _addDisabledOverlay];
			}
		}
	}
	else
	{

		if (parent.style == OFTabBarStyleDashboard)
		{
			backgroundView.image = self.inactiveImage;
		}
		else
		{
			[self _removeDisabledOverlay];
			
			if (active)
			{
				backgroundView.image = parent.activeItemBackgroundImage;
				imageView.image = activeImage;
				nameLabel.textColor = parent.activeTextColor;
				nameLabel.shadowColor = parent.activeShadowColor;
			}
			else
			{
				backgroundView.image = parent.inactiveItemBackgroundImage;
				imageView.image = inactiveImage;
				nameLabel.textColor = parent.inactiveTextColor;
				nameLabel.shadowColor = parent.inactiveShadowColor;
			}
		}
	}
}

- (void)layoutSubviews
{
	float width = 0.f;
	float xOffset = 0.f;

	unsigned int totalItems = [parent.items count];
	unsigned int itemIndex  = [parent.items indexOfObject:self];

	if (parent.style == OFTabBarStyleDashboard)
	{
		width = self.activeImage.size.width;
		
		xOffset = parent.leftPadding;

		unsigned int i;
		for (i=0; i<itemIndex; ++i)
		{
			xOffset += [(OFTabBarItem*)[parent.items objectAtIndex:i] frame].size.width;
		}
	}
	else
	{
		width    = (parent.frame.size.width - parent.leftPadding - parent.rightPadding - parent.overlap) / totalItems;
		xOffset  = width * itemIndex + parent.leftPadding;
	}
	
	self.frame = CGRectMake(round(xOffset), 0, round(width), self.frame.size.height);
	
	overlayView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
	for (UIView* subview in overlayView.subviews)
	{
		subview.frame = CGRectMake(
			(overlayView.frame.size.width - subview.frame.size.width) * 0.5f, 
			-5.f, 
			overlayView.frame.size.width, 
			subview.frame.size.height
		);
	}
	[self bringSubviewToFront:overlayView];
	
	hitImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - kIconYOffset);
	
	if (parent.style == OFTabBarStyleTraditional)
	{
		imageView.frame = CGRectMake(round(self.frame.size.width/2 - imageView.image.size.width/2),
																 round((self.frame.size.height - imageView.image.size.height - 4) / 2) - kIconYOffset,
																 imageView.image.size.width,
																 imageView.image.size.height);
	}
	else if (parent.style == OFTabBarStyleSegments)
	{
		imageView.frame = CGRectMake(round(self.frame.size.width/2 - imageView.image.size.width/2),
																 round((self.frame.size.height - imageView.image.size.height - 12) / 2),
																 imageView.image.size.width,
																 imageView.image.size.height);
	}
	else if (parent.style == OFTabBarStyleDashboard)
	{
		backgroundView.frame = imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	}	
	
	CGPoint center;
	if (parent.placeBadgeTopRight)
	{
		center = CGPointMake(self.frame.size.width - badgeView.frame.size.width * 0.5f + parent.badgeOffset.x, badgeView.frame.size.height * 0.5f + parent.badgeOffset.y);
	}
	else
	{
		center = CGPointMake(self.frame.size.width/2 + parent.badgeOffset.x, self.frame.size.height/2 + parent.badgeOffset.y);
	}
	
	if (UITextAlignmentCenter == parent.textAlignment)
	{
		// expand to the full cell to center correctly.
		nameLabel.frame = CGRectMake(0, nameLabel.frame.origin.y, self.frame.size.width, nameLabel.frame.size.height);
	}
	
	// adill note: kind of a cheap hack, but we know the badge is 29x29 so it's center needs to be on a half-pixel boundary in order to not scale
	center.x = floorf(center.x) + 0.5f;
	center.y = floorf(center.y) + 0.5f;
	[badgeView setCenter:center];
}

- (void)animatePulse
{
	float peroid = 1.75f;
	
	if (imageView.alpha == 1.0)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:peroid];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationBeginsFromCurrentState:YES];
		imageView.alpha = 0.5;
		[UIView commitAnimations];		
	}
	else
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:peroid];
		[UIView setAnimationDelegate:self];
		imageView.alpha = 1.0;
		[UIView commitAnimations];
	}
}

- (void)setBadgeValue:(NSString*)value
{
	[badgeView setValue:[value intValue]];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (active)
		[self animatePulse];
}

- (void)dealloc 
{
	self.button = nil;
	self.imageView = nil;
	self.nameLabel = nil;
	self.badgeView = nil;
	self.borderImageView = nil;
	self.backgroundView = nil;
	self.hitImageView = nil;

	self.viewController = nil;
	self.viewControllerName = nil;
	OFSafeRelease(name);
	self.activeImage = nil;
	self.inactiveImage = nil;

	self.disabledImage = nil;

	[super dealloc];
}

@end
