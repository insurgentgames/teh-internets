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
#import "OFGameDiscoveryCategoryCell.h"
#import "OFGameDiscoveryCategory.h"
#import "OFImageView.h"
#import "OpenFeint+Private.h"
#import "OFImageLoader.h"
#import "OFTableCellBackgroundView.h"

#define kOFGameDiscoveryIconWidthLandscape 150.f
#define kOFGameDiscoveryIconWidthPortrait  104.f

@implementation OFGameDiscoveryCategoryCell

@synthesize iconView, iconFrame, textContentView, nameLabel, subtextLabel, secondaryTextLabel, topDividerView, bottomDividerView;

- (void)onResourceChanged:(OFResource*)resource
{
	OFGameDiscoveryCategory* category = (OFGameDiscoveryCategory*)resource;
    
    self.iconFrame.image = [self.iconFrame.image stretchableImageWithLeftCapWidth:21.f topCapHeight:19.f];
    
	self.iconView.unframed = YES;
	self.iconView.imageUrl = category.iconUrl;
	self.iconView.shouldScaleImageToFillRect = NO;
	self.nameLabel.text = category.name;
	self.subtextLabel.text = category.subtext;
	self.secondaryTextLabel.text = category.secondaryText;
}

- (void)dealloc
{
	self.iconView = nil;
    self.iconFrame = nil;
    self.textContentView = nil;
	self.nameLabel = nil;
	self.subtextLabel = nil;
	self.secondaryTextLabel = nil;
	self.bottomDividerView = nil;
	self.topDividerView = nil;
	
	[super dealloc];
}

- (BOOL)wantsToConfigureSelf
{
	return YES;
}

- (void)configureSelfAsLeading:(BOOL)_isLeading asTrailing:(BOOL)_isTrailing asOdd:(BOOL)_isOdd
{
    // Force 2.x to do it's autoresizing before we start messing with stuff
    [self layoutSubviews];
    
	if ([OpenFeint isInLandscapeMode])
	{
        self.iconFrame.frame        = CGRectMake(self.iconFrame.frame.origin.x, self.iconFrame.frame.origin.y,
                                                 kOFGameDiscoveryIconWidthLandscape + 14.f, self.iconFrame.frame.size.height);
        self.iconView.frame         = CGRectMake(self.iconView.frame.origin.x, self.iconView.frame.origin.y,
                                                 kOFGameDiscoveryIconWidthLandscape, self.iconView.frame.size.height);
    }
    else
    {
        self.iconFrame.frame        = CGRectMake(self.iconFrame.frame.origin.x, self.iconFrame.frame.origin.y,
                                                 kOFGameDiscoveryIconWidthPortrait + 14.f, self.iconFrame.frame.size.height);
        self.iconView.frame         = CGRectMake(self.iconView.frame.origin.x, self.iconView.frame.origin.y,
                                                 kOFGameDiscoveryIconWidthPortrait, self.iconView.frame.size.height);
        
        CGRect textContentViewFrame = CGRectZero;
        textContentViewFrame.origin = CGPointMake(kOFGameDiscoveryIconWidthPortrait + 33.f, 0);
        textContentViewFrame.size   = CGSizeMake(143.f, self.frame.size.height);
        self.textContentView.frame = textContentViewFrame;
    }

	OFTableCellBackgroundView* background = (OFTableCellBackgroundView*)self.backgroundView;
	OFTableCellBackgroundView* selectedBackground = (OFTableCellBackgroundView*)self.selectedBackgroundView;
	if (![background isKindOfClass:[OFTableCellBackgroundView class]])
	{
		self.backgroundView = background = [OFTableCellBackgroundView defaultBackgroundView];
		self.selectedBackgroundView = selectedBackground = [OFTableCellBackgroundView defaultBackgroundView];
	}

	background.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryGreyBG.png"]];
	selectedBackground.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryGreyBGSelected.png"]];
				
	self.topDividerView.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryDividerTop.png"]];
	self.bottomDividerView.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryDividerBottom.png"]];
}

@end
