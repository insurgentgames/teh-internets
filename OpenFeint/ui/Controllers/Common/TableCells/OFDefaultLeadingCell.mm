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
#import "OFDefaultLeadingCell.h"
#import "OFImageView.h"
#import "OFImageLoader.h"
#import "OFUser.h"
#import "OFProfileController.h"
#import "OpenFeint+UserOptions.h"

namespace 
{
	const float kIconPadding = 10.f;
}

@implementation OFDefaultLeadingCell

@synthesize headerLabel, headerContainerView, leftIconView, rightIconView, secondFromRightIconView;

- (void)dealloc
{
	self.headerLabel = nil;
	self.headerContainerView = nil;
	self.rightIconView = nil;
	self.secondFromRightIconView = nil;
	self.leftIconView = nil;
	[super dealloc];
}

- (IBAction)onClickedLeftIcon
{
	if (mCallbackTarget && mLeftIconSelector)
	{
		[mCallbackTarget performSelector:mLeftIconSelector];
	}
}

- (IBAction)onClickedRightIcon
{
}

- (IBAction)onClickedSecondFromRightIcon
{

}

- (void)setCallbackTarget:(id)target
{
	mCallbackTarget = target;
}

- (void)setLeftIconSelector:(SEL)leftIconSelector
{
	mLeftIconSelector = leftIconSelector;
}

- (void)_setImageViewImage:(OFImageView*)imageView imageUrl:(NSString*)imageUrl defaultImageName:(NSString*)defaultImageName
{
	[imageView setDefaultImage:[OFImageLoader loadImage:defaultImageName]];
	[imageView setImageUrl:imageUrl];
}

- (void)enableLeftIconView
{
	self.leftIconView.hidden = NO;
	CGRect leftIconRect = self.leftIconView.frame;
	CGRect containerRect = self.headerContainerView.frame;
	const float containerStartX = leftIconRect.origin.x + leftIconRect.size.width + kIconPadding;
	if (containerRect.origin.x < containerStartX)
	{
		const float widthToShrink = containerStartX - containerRect.origin.x;
		containerRect.origin.x = containerStartX;
		containerRect.size.width -= widthToShrink;
		self.headerContainerView.frame = containerRect;
	}
}

- (void)enableLeftIconViewWithImageUrl:(NSString*)imageUrl andDefaultImage:(NSString*)defaultImageName
{
	[self enableLeftIconView];
	[self _setImageViewImage:self.leftIconView imageUrl:imageUrl defaultImageName:defaultImageName];
}

- (void)_disableRightAlignedView:(UIView*)rightAlignedView
{
	rightAlignedView.hidden = YES;
	UIView* leftmostHiddenView = (rightIconView.hidden && secondFromRightIconView.hidden) ? rightIconView : secondFromRightIconView;
	CGRect iconRect = leftmostHiddenView.frame;
	CGRect containerRect = self.headerContainerView.frame;
	const float containerEndX = iconRect.origin.x + iconRect.size.width;
	if (containerRect.origin.x + containerRect.size.width < containerEndX)
	{
		containerRect.size.width = containerEndX - containerRect.origin.x;
		self.headerContainerView.frame = containerRect;
	}
}

- (void)_enableRightAlignedView:(UIView*)rightAlignedView
{
	rightAlignedView.hidden = NO;
	CGRect iconRect = rightAlignedView.frame;
	CGRect containerRect = self.headerContainerView.frame;
	const float containerEndX = iconRect.origin.x - kIconPadding;
	if (containerRect.origin.x + containerRect.size.width > containerEndX)
	{
		containerRect.size.width = containerEndX - containerRect.origin.x;
		self.headerContainerView.frame = containerRect;
	}
}

- (void)enableRightIconView
{
	[self _enableRightAlignedView:self.rightIconView];
}

- (void)enableSecondFromRightIconView
{
	[self _enableRightAlignedView:self.secondFromRightIconView];
}

- (void)disableRightIconView
{
	[self _disableRightAlignedView:self.rightIconView];
}

- (void)disableSecondFromRightIconView
{
	[self _disableRightAlignedView:self.secondFromRightIconView];
}

- (void)disableBothRightIconViews
{
	self.rightIconView.hidden = YES;
	self.secondFromRightIconView.hidden = YES;
	CGRect containerRect = self.headerContainerView.frame;
	containerRect.size.width = self.frame.size.width - containerRect.origin.x * 2.f;
	self.headerContainerView.frame = containerRect;
}

- (void)enableBothRightIconViews
{
	[self enableSecondFromRightIconView];
	[self enableRightIconView];
}

- (void)populateRightIconsAsComparison:(OFUser*)pageOwner
{
	[self enableRightIconView];
	
	bool myPage = !pageOwner || [pageOwner isLocalUser];
	if (myPage)
	{
		[self.rightIconView useLocalPlayerProfilePictureDefault];
		self.rightIconView.imageUrl = [OpenFeint lastLoggedInUserProfilePictureUrl];
		self.rightIconView.useFacebookOverlay = [OpenFeint lastLoggedInUserUsesFacebookProfilePicture];
		[self disableSecondFromRightIconView];
	}
	else
	{
		[self enableSecondFromRightIconView];
		[self.secondFromRightIconView useLocalPlayerProfilePictureDefault];
		self.secondFromRightIconView.imageUrl = [OpenFeint lastLoggedInUserProfilePictureUrl];
		self.secondFromRightIconView.useFacebookOverlay = [OpenFeint lastLoggedInUserUsesFacebookProfilePicture];
		
		[self.rightIconView useProfilePictureFromUser:pageOwner];
	}
}

@end
