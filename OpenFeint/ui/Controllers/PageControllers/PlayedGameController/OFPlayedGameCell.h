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

#import "OFTableCellHelper.h"
@class OFImageView;

@interface OFPlayedGameCell : OFTableCellHelper
{
	UILabel* nameLabel;
	UILabel* friendsWithAppLabel;
	OFImageView* iconView;
	UIView* firstStatView;
	UIView* secondStatView;
	UILabel* firstGamerScoreLabel;
	UILabel* secondGamerScoreLabel;
	UIButton* shoppingCartButton;
	UIViewController* owner;
	NSString* clientApplicationId;
	UIImageView* firstGamerScoreIcon;
	UIImageView* secondGamerScoreIcon;
	UIImageView* firstFavoritedIcon;
	UIImageView* secondFavoritedIcon;
	UIImageView* comparisonDividerIcon;

	OFImageView* miniScreenshotOneView;
	OFImageView* miniScreenshotTwoView;
}

@property (nonatomic, retain) IBOutlet OFImageView* iconView;
@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* friendsWithAppLabel;
@property (nonatomic, retain) IBOutlet UIView* secondStatView;
@property (nonatomic, retain) IBOutlet UIView* firstStatView;
@property (nonatomic, retain) IBOutlet UILabel* firstGamerScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel* secondGamerScoreLabel;
@property (nonatomic, retain) IBOutlet UIButton* shoppingCartButton;
@property (nonatomic, assign) UIViewController* owner;
@property (nonatomic, retain) IBOutlet UIImageView* firstGamerScoreIcon;
@property (nonatomic, retain) IBOutlet UIImageView* secondGamerScoreIcon;
@property (nonatomic, retain) IBOutlet OFImageView* miniScreenshotOneView;
@property (nonatomic, retain) IBOutlet OFImageView* miniScreenshotTwoView;
@property (nonatomic, retain) IBOutlet UIImageView* firstFavoritedIcon;
@property (nonatomic, retain) IBOutlet UIImageView* secondFavoritedIcon;
@property (nonatomic, retain) IBOutlet UIImageView* comparisonDividerIcon;

- (void)onResourceChanged:(OFResource*)resource;

- (IBAction)showIPurchasePage;
- (IBAction)showAppStorePage;
@end