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
#import "OFPaginatedSeries.h"

@class OFTableSectionCellDescription;
@class OFResource;
@class OFResourceViewHelper;

@interface OFTableSectionDescription : NSObject
{
	NSString* title;
	NSString* identifier;
	OFPaginatedSeries* page;
	NSString* leadingCellName;
	NSString* trailingCellName;
	UIView* headerView;
	UIView* footerView;
	NSMutableArray* staticCells;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) OFPaginatedSeries* page;
@property (nonatomic, retain) NSString* leadingCellName;
@property (nonatomic, retain) NSString* trailingCellName;
@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UIView* footerView;
@property (nonatomic, retain) NSMutableArray* staticCells;

+ (id)sectionWithTitle:(NSString*)title andPage:(OFPaginatedSeries*)page;
+ (id)sectionWithTitle:(NSString*)title andCell:(OFTableSectionCellDescription*)cellDescription;
+ (id)sectionWithTitle:(NSString*)title andStaticCells:(NSMutableArray*)cellHelpers;

- (id)initWithTitle:(NSString*)title andPage:(OFPaginatedSeries*)page;
- (unsigned int)countPageItems;
- (unsigned int)countEntireItemSet;

- (BOOL)isRowFirstObject:(NSUInteger)row;
- (BOOL)isRowLastObject:(NSUInteger)row;
- (BOOL)isStaticCell:(NSUInteger)row;
@end
