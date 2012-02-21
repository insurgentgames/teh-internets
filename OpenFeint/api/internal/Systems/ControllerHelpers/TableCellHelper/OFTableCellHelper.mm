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
#import "OFTableCellHelper.h"
#import "OFTableCellHelper+Overridables.h"
#import "OFTableCellBackgroundView.h"
#import "OFTableControllerHelper+Overridables.h"
#import "IPhoneOSIntrospection.h"

@implementation OFTableCellHelper

@synthesize owningTable;


#if 0 // JoeTest
	// This is just a test hook to demonstrate that highlighting is not
	// the cause of the dark band at the top of the cell on selection.
	- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
		[super setHighlighted:highlighted animated:animated];
	}
#endif


- (OFResource*)resource
{
	return mResource;
}

- (void)setEdgeStyle:(OFTableCellRoundedEdge)_edgeStyle
{
	[(OFTableCellBackgroundView*)self.backgroundView setEdgeStyle:_edgeStyle];
	[(OFTableCellBackgroundView*)self.selectedBackgroundView setEdgeStyle:_edgeStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc 
{
	[mResource release];
	[super dealloc];
}

- (void)changeResource:(OFResource*)resource withCellIndex:(NSUInteger)index
{
	[mResource release];
	mResource = [resource retain];
	[self onResourceChanged:mResource withCellIndex:index];
}

- (void)changeResource:(OFResource*)resource
{
	[mResource release];
	mResource = [resource retain];
	[self onResourceChanged:mResource];
}

- (id)initOFTableCellHelper:(NSString*)reuseIdentifier
{
#ifdef __IPHONE_3_0
	// 3.0 weak linking compatability
	if (is3PointOhSystemVersion())
	{
		self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	else
#endif
	{
		// The id cast is a hack to get rid of a deprecated function warning
		self = [(id)self initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier];
	}
	return self;
}

//#pragma mark Swipe Support
//
//- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
//{
//	touchStartPosition = [[touches anyObject] locationInView:self];
//	swiped = NO;
//
//	[super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
//{
//	if (!swiped)
//	{
//		CGPoint touchPosition = [[touches anyObject] locationInView:self];
//		
//		CGPoint delta = CGPointMake(
//			fabsf(touchPosition.x - touchStartPosition.x), 
//			fabsf(touchPosition.y - touchStartPosition.y));
//			
//		if (delta.x >= 12.f && delta.y <= 6.f)
//		{
//			swiped = YES;
//			[owningTable clearSwipedCell];
//			[owningTable didSwipeCell:self];
//			[super touchesCancelled:touches withEvent:event];
//		}
//	}
//
//	if (!swiped)
//	{
//		[super touchesMoved:touches withEvent:event];
//	}
//}
//
//- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
//{
//	[super touchesEnded:touches withEvent:event];
//	swiped = NO;
//}
//
//- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
//{
//	[super touchesCancelled:touches withEvent:event];
//	swiped = NO;
//}

@end