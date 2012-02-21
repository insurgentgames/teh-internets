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

#import "OFPlainTableHeaderController.h"

@implementation OFPlainTableHeaderController

@synthesize headerLabel;

- (void)awakeFromNib
{
	[super awakeFromNib];
	bgView.image = [bgView.image stretchableImageWithLeftCapWidth:11 topCapHeight:22];
}

- (void)resizeView:(UIView*)parentView
{
	CGRect frame = parentView.frame;
	frame.origin = CGPointZero;
	frame.size.height = 60.f;
	self.view.frame = frame;
}

- (void)dealloc
{
	self.headerLabel = nil;
	OFSafeRelease(bgView);
	[super dealloc];
}

@end