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

#import "OFContentFrameView.h"
#import "OFImageLoader.h"

#import "OpenFeint+Private.h"


@implementation OFContentFrameView

+ (UIEdgeInsets)getContentInsets
{
	return UIEdgeInsetsMake(8, 6, 8, 6);
}

- (void)_commonInit
{
    if (!self.image) self.image = [OFImageLoader loadImage:@"OFContentFrameBorder.png"];
    self.image = [self.image stretchableImageWithLeftCapWidth:25 topCapHeight:25];
	self.contentMode = UIViewContentModeScaleToFill;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

@end
