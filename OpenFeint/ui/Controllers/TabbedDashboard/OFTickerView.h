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

@class OFTabbedDashboardController;

@protocol OFTickerViewDelegate <NSObject>

@optional
- (void)onXPressed;
- (void)textFinishedScrolling;
@end


@interface OFTickerView : UIView 
{
	OFTabbedDashboardController *parent;
	
	UIView  *cropView;
	UILabel *label;
	id<OFTickerViewDelegate> delegate;
}

@property (retain, nonatomic) NSString* text;
@property (assign, nonatomic) id<OFTickerViewDelegate> delegate;

- (id)initWithDelegate:(id<OFTickerViewDelegate>)aDelegate andFrame:(CGRect)frame;

@end
