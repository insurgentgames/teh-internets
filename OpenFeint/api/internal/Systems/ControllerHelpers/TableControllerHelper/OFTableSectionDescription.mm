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
#import "OFTableSectionDescription.h"
#import "OFTableSectionCellDescription.h"
#import "OFPaginatedSeries.h"
#import "OFResourceViewHelper.h"
#import "OFPaginatedSeriesHeader.h"

@implementation OFTableSectionDescription

@synthesize title;
@synthesize identifier;
@synthesize page;
@synthesize leadingCellName;
@synthesize trailingCellName;
@synthesize headerView;
@synthesize footerView;
@synthesize staticCells;

- (void)setHeaderView:(UIView*)newHeaderView
{
	OFSafeRelease(headerView);
	headerView = [newHeaderView retain];
}

- (void)setFooterView:(UIView*)newFooterView
{
	OFSafeRelease(footerView);
	footerView = [newFooterView retain];
}

+ (id)sectionWithTitle:(NSString*)title andPage:(OFPaginatedSeries*)page
{
	return [[[OFTableSectionDescription alloc] initWithTitle:title andPage:page] autorelease];
}

+ (id)sectionWithTitle:(NSString*)title andCell:(OFTableSectionCellDescription*)cellDescription
{
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeriesWithObject:cellDescription];
	return [[[OFTableSectionDescription alloc] initWithTitle:title andPage:page] autorelease];
}

+ (id)sectionWithTitle:(NSString*)title andStaticCells:(NSMutableArray*)cellHelpers
{
	OFTableSectionDescription* sectionDesc = [[[OFTableSectionDescription alloc] initWithTitle:title andPage:nil] autorelease];
	sectionDesc.staticCells = cellHelpers;
	return sectionDesc;
}

- (id)initWithTitle:(NSString*)_title andPage:(OFPaginatedSeries*)_page
{
	self = [super init];
	if (self != nil)
	{
		self.title = _title;
		self.page = _page;
	}
	return self;
	
}

- (void)dealloc
{
	self.title = nil;
	self.identifier = nil;
	self.page = nil;
	self.leadingCellName = nil;
	self.trailingCellName = nil;
	self.headerView = nil;
	self.footerView = nil;
	self.staticCells = nil;
	[super dealloc];
}

- (unsigned int)_countWithAssumption:(unsigned int)baseItemAssumption
{
	if(self.leadingCellName)
	{
		++baseItemAssumption;
	}
	
	if(self.trailingCellName)
	{
		++baseItemAssumption;
	}
	
	return baseItemAssumption;
}
	
- (unsigned int)countEntireItemSet
{
	return [self _countWithAssumption:self.page.header.totalObjects];
}

- (unsigned int)countPageItems
{
	return [self _countWithAssumption:[self.staticCells count] + [self.page count]];
}

- (BOOL)isRowFirstObject:(NSUInteger)row
{
	if (self.leadingCellName)
	{
		return row == 1;
	}
	return row == 0;
}

- (BOOL)isRowLastObject:(NSUInteger)row
{
	NSUInteger totalRows = [self countEntireItemSet];
	if (self.trailingCellName)
	{
		totalRows--;
	}
	return row == (totalRows - 1);
}

- (BOOL)isStaticCell:(NSUInteger)row
{
	if (self.leadingCellName && row == 0)
	{
		if (row == 0)
		{
			return NO;
		}
		else
		{
			row--;
		}
	}
	return row < [self.staticCells count] && row >= 0;
}

@end