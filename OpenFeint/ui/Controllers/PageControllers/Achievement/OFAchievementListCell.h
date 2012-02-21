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

#import "OFTableCellHelper.h"
@class OFImageView;

@interface OFAchievementListCell : OFTableCellHelper
{
	UILabel* titleLabel;
	UILabel* descriptionLabel;
	UIView* firstIconContainer;
	UIView* secondIconContainer;
	OFImageView* firstUnlockedIcon;
	OFImageView* secondUnlockedIcon;
	UIView* gamerScoreContainer;
	UILabel* gamerScoreLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, retain) IBOutlet UIView* firstIconContainer;
@property (nonatomic, retain) IBOutlet UIView* secondIconContainer;
@property (nonatomic, retain) IBOutlet OFImageView* firstUnlockedIcon;
@property (nonatomic, retain) IBOutlet OFImageView* secondUnlockedIcon;
@property (nonatomic, retain) IBOutlet UIView* gamerScoreContainer;
@property (nonatomic, retain) IBOutlet UILabel* gamerScoreLabel;

- (void)onResourceChanged:(OFResource*)resource;

@end
