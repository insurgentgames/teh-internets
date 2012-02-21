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

@interface OFButtonPanel : UIView
{
	int maxButtonCount;
	CGSize buttonSize;
	CGSize buttonSpacing;
	UIImage* emptyButtonSlotImage;

	NSMutableArray* buttons;
	
	IBOutlet UIView* headerView;
}

+ (id)panelWithFrame:(CGRect)_frame maxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage;

- (id)initWithFrame:(CGRect)_frame maxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage;

- (void)configureMaxButtonCount:(int)_maxButtonCount buttonSize:(CGSize)_buttonSize buttonSpacing:(CGSize)_buttonSpacing emptyImage:(UIImage*)_emptyImage;

- (void)setHeaderView:(UIView*)_headerView;
- (void)setMaxButtons:(int)buttonCount;

- (void)setButton:(UIButton*)_button atPosition:(int)index;
- (void)disableButton:(UIButton*)_button withDecorationImage:(UIImage*)decoration;
- (void)removeAllButtons;
- (void)addPlaceholderButtons;

@end