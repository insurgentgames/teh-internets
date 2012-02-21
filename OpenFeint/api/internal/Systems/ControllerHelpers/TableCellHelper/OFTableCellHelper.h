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

@class OFResource;

enum OFTableCellRoundedEdge
{
	kRoundedEdge_Top,
	kRoundedEdge_Bottom,
	kRoundedEdge_TopAndBottom,

	kRoundedEdge_None
};

@class OFTableControllerHelper;

@interface OFTableCellHelper : UITableViewCell
{
@package
	OFTableControllerHelper* owningTable;	// weak reference
	
	OFResource* mResource;
	
//	// custom swipe
//	BOOL swiped;
//	CGPoint touchStartPosition;
}

@property (assign) OFTableControllerHelper* owningTable;
@property (nonatomic, readonly) OFResource* resource;

- (void)setEdgeStyle:(OFTableCellRoundedEdge)_edgeStyle;

- (void)changeResource:(OFResource*)resource;
- (void)changeResource:(OFResource*)resource withCellIndex:(NSUInteger)index;

// Make sure to override this instead of overriding initWithFrame: or initWithStyle:.
// The weak linking check is done in here.
- (id)initOFTableCellHelper:(NSString*)reuseIdentifier;

@end
