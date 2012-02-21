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
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFControllerHelpersCommon.h"
#import "OFService+Overridables.h"
#import "OFTableSequenceControllerLoadMoreCell.h"
#import "OFTableCellBackgroundView.h"
#import "OFTableSequenceControllerHelper+Pagination.h"

@implementation OFTableSequenceControllerHelper ( Overridables )

- (void)populateResourceMap:(OFResourceControllerMap*)mapToPopulate
{
	ASSERT_OVERRIDE_MISSING;
}

- (void)populateSectionHeaderFooterResourceMap:(OFResourceControllerMap*)mapToPopulate
{
	// Optional
}

- (void)onBeforeResourcesProcessed:(OFPaginatedSeries*)resources
{
	// optional
}

- (void)onResourcesDownloaded:(OFPaginatedSeries*)resources
{
	//Optional
}

- (void)onSectionsCreated:(NSMutableArray*)sections
{
	// Optional
}

- (void)onRefreshingData
{
	mNumLoadedPages = 1;
}

- (bool)allowPagination
{
	return true;
}

- (void)doIndexActionWithOffset:(unsigned int)zeroBasedRowIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	ASSERT_OVERRIDE_MISSING;
}

- (NSString*)getCellControllerNameForStreamingCells
{
	ASSERT_OVERRIDE_MISSING;
	return @"";
}

- (bool)usePlainTableSectionHeaders
{
	return [self isAlphabeticalList];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	OFService* service = [self getService];
	[[service class] getIndexOnSuccess:success onFailure:failure];
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	ASSERT_OVERRIDE_MISSING;
}

- (bool)hasStreamingSections
{
	return false;
}

- (bool)usesHeaderResource
{
	return false;
}

- (NSInteger)getHeaderResourceSectionIndex
{
	return -1;
}

- (void)onHeaderResourceDownloaded:(OFResource*)headerResource
{
}

- (void)configureCell:(OFTableCellHelper*)_cell asLeading:(BOOL)_isLeading asTrailing:(BOOL)_isTrailing asOdd:(BOOL)_isOdd
{
	if (_isTrailing && [_cell isKindOfClass:[OFTableSequenceControllerLoadMoreCell class]])
	{
		// don't do anything
	}
	else
	{
		[super configureCell:_cell asLeading:_isLeading asTrailing:_isTrailing asOdd:_isOdd];
	}
}

@end

