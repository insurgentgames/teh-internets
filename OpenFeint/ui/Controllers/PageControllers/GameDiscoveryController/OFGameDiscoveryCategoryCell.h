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

@interface OFGameDiscoveryCategoryCell : OFTableCellHelper
{
	OFImageView* iconView;
    UIImageView* iconFrame;
    UIView* textContentView;
	UILabel* nameLabel;
	UILabel* subtextLabel;
	UILabel* secondaryTextLabel;
	UIView* topDividerView;
	UIView* bottomDividerView;
}

@property (nonatomic, retain) IBOutlet OFImageView* iconView;
@property (nonatomic, retain) IBOutlet UIImageView* iconFrame;
@property (nonatomic, retain) IBOutlet UIView* textContentView;
@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* subtextLabel;
@property (nonatomic, retain) IBOutlet UILabel* secondaryTextLabel;
@property (nonatomic, retain) IBOutlet UIView* topDividerView;
@property (nonatomic, retain) IBOutlet UIView* bottomDividerView;

- (void)onResourceChanged:(OFResource*)resource;

@end
