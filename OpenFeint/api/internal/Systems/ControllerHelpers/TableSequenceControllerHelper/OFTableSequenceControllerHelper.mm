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
#import "OFTableSequenceControllerHelper.h"
#import "OFService+Overridables.h"
#import "OFResourceControllerMap.h"
#import "OFXmlDocument.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFControllerLoader.h"
#import "OFTableSectionDescription+ResourceAdditions.h"
#import "OFTableSequenceControllerHelper+Pagination.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFTableCellHelper.h"

@implementation OFTableSequenceControllerHelper

- (void)dealloc
{
	OFSafeRelease(mMetaDataObjects);
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	mCountdownToStreamingRequest = nil;
	mIsLoadingNextPage = false;
	mNumLoadedPages = 0;
	mResourceMap.reset(new OFResourceControllerMap); 
	[self populateResourceMap:mResourceMap.get()];
}

- (NSMutableArray*)_sectionsFromResources:(OFPaginatedSeries*)resources
{
	OFSafeRelease(mMetaDataObjects);
	if (resources.tableMetaDataObjects)
	{
		mMetaDataObjects = [resources.tableMetaDataObjects retain];
		resources.tableMetaDataObjects = nil;
	}
	if ([resources count] > 0)
	{
		if ([[resources objectAtIndex:0] isKindOfClass:[OFTableSectionDescription class]])
		{
			NSMutableArray* sections = [NSMutableArray arrayWithCapacity:[resources count]];
			for (OFTableSectionDescription* section in resources.objects)
			{
				if ([section.page count] > 0 || [self getLeadingCellControllerNameForSection:section])
					[sections addObject:section];
			}
			
			if ([sections count] == 0)
				return nil;

			return sections;
		}
		else
		{
			OFTableSectionDescription* section = [[OFTableSectionDescription new] autorelease];
			section.page = [OFPaginatedSeries paginatedSeriesFromSeries:resources];
			
			return [NSMutableArray arrayWithObject:section];
		}
	}

	return nil;
}

-(void) _appendNumItems:(unsigned int)newResourcesCount toTableSectionIndex:(unsigned int)targetSectionIndex
{
	OFTableSectionDescription* targetSection = [mSections objectAtIndex:targetSectionIndex];
	const unsigned int numCurrentResourcesInSection = [targetSection.page count];
	const unsigned int indexToAppendARow = numCurrentResourcesInSection > 0 ? numCurrentResourcesInSection - 1 : 0;

	[self.tableView beginUpdates];	

	NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:newResourcesCount];
	for(unsigned int i = 0; i < newResourcesCount; ++i)
	{
		[indexPaths addObject:[NSIndexPath indexPathForRow:indexToAppendARow inSection:targetSectionIndex]];
	}
	
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	
	[self.tableView endUpdates];
}

- (void)_onDataLoaded:(OFPaginatedSeries*)resources isIncremental:(BOOL)isIncremental
{
	const bool isFirstTimeShowingData = (mSections == nil);
	const bool isScrolledToHead = [self _isScrolledToHead];
	
	[self onBeforeResourcesProcessed:resources];
	
	NSMutableArray* sections = [self _sectionsFromResources:resources];

	[self onSectionsCreated:sections];
	const bool usesHeaderResource = [self usesHeaderResource];
	if (usesHeaderResource && resources.header.currentPage == 1)
	{
		OFTableSectionDescription* section = [sections objectAtIndex:[self getHeaderResourceSectionIndex]];
		OFResource* headerResource = [[section.page.objects objectAtIndex:0] retain];
		[section.page.objects removeObjectAtIndex:0];
		[self onHeaderResourceDownloaded:headerResource];
		[headerResource release];
		
		if ([section.page.objects count] == 0)
		{
			[sections removeObjectAtIndex:[self getHeaderResourceSectionIndex]];
			if ([sections count] == 0)
			{
				sections = nil;
			}
		}
	}

	bool didLoadNewData = false;
	if(!isFirstTimeShowingData)
	{
		const bool allowStreamingPagination = [self allowPagination] && [mSections count] == [sections count] && [self hasStreamingSections];
	
		if(!allowStreamingPagination && isIncremental)
		{
			OFTableSectionDescription* newResources = [sections lastObject];
			OFTableSectionDescription* existingResources = [mSections lastObject];					
			const bool shouldPrependContents = ([self _isDataPaginated] == false);
			const unsigned int numNewResourcesAdded = [existingResources addContentsOfSectionWhereUnique:newResources areSortedDescending:YES shouldPrependContents:shouldPrependContents];

			// Animating in multiple rows when the current view is not full causes a fade in animation to be played on top of a
			// from bottom animation and the app crashes. We've found no work arounds in the animations so the solution is to
			// only append rows to a full screen. The cost of reloading is small without a full screen of data anyways.
			// HOWEVER! There are some issue with the contentsize calculation on the SIMULATOR so if more cells than
			// an arbitrary number do the same.
			// ALSO Pagination crashes on page sizes of 10 in OS 3.0 if we try to append so lets not do it.
			const bool currentContentFillsScreen = [self.tableView contentSize].height > self.tableView.frame.size.height; 
			if (![self _isDataPaginated] && (currentContentFillsScreen || [existingResources.page count] > 15))
			{
				const unsigned int lastSectionIndex = [mSections count] - 1;	
				[self _appendNumItems:numNewResourcesAdded toTableSectionIndex:lastSectionIndex];
			}
			else
			{
				[self _reloadTableData]; 
			}
				
			didLoadNewData = true;			
		}
		else if(allowStreamingPagination)
		{
			[mSections release];
			mSections = [sections retain];

			OFPaginatedSeries* loadedPage = ((OFTableSectionDescription*)[mSections lastObject]).page;
			const unsigned int numLoadedObjects = [loadedPage.objects count];
			const unsigned int numLoadedSections = [mSections count];

			for(unsigned int i = 0; i < numLoadedObjects; ++i)
			{
				const unsigned int rowIndex = i + loadedPage.header.currentOffset;
				
				UITableViewCell* resourceCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:numLoadedSections - 1]];
				[self _changeResource:[loadedPage.objects objectAtIndex:i] forCell:(OFTableCellHelper*)resourceCell withIndex:rowIndex];
			}
			
			didLoadNewData = true;
		}
	}	

	if(!didLoadNewData)
	{
		[mSections release];
		mSections = [sections retain];
		
		if([sections count])
		{
			[self _reloadTableData];
		}
	}
	
	if(isScrolledToHead)
	{
		[self _scrollToTableHead:!isFirstTimeShowingData];
	}
	else
	{
		[self.tableView flashScrollIndicators];
	}
	
	[self onResourcesDownloaded:resources];
}

- (NSMutableArray*)getMetaDataOfType:(Class)metaDataType
{
	NSMutableArray* objects = [[NSMutableArray new] autorelease];
	for (NSObject* curItem in mMetaDataObjects)
	{
		if ([curItem isKindOfClass:metaDataType])
		{
			[objects addObject:curItem];
		}
	}
	return objects;
}

- (void)_reloadTableData
{
	[self _createAndDisplayPaginationControls];
	[super _reloadTableData];
}


@end