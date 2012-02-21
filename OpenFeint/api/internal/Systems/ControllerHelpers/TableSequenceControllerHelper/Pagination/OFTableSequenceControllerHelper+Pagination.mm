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

#import "OFTableSequenceControllerHelper+Pagination.h"
#import "OFTableSequenceControllerHelper+Overridables.h"
#import "OFTableSectionDescription.h"
#import "OFTableSequenceControllerLoadMoreCell.h"
#import "OFDelegateChained.h"
#import "OFPaginatedSeriesHeader.h"

@implementation OFTableSequenceControllerHelper (Pagination)

- (bool)_isDataPaginated
{
	if ([self allowPagination])
	{
		OFTableSectionDescription* lastSection = [mSections lastObject];
		return lastSection.page.header != nil;
	}
	else
	{
		return false;
	}	
}

- (void)_createAndDisplayPaginationControls
{
	if([self _isDataPaginated] && ![self hasStreamingSections])
	{
		OFTableSectionDescription* lastSection = [mSections lastObject];
		
		NSString* cellControllerName = @"TableSequenceControllerLoadMore";			
		
		NSAssert(lastSection.trailingCellName == nil || [lastSection.trailingCellName isEqualToString:cellControllerName], @"Pagination requires the trailing cell of the desired section be empty");
		if(lastSection.trailingCellName == nil)
		{
			lastSection.trailingCellName = cellControllerName;
		}
	}
}

- (NSIndexPath*)_getPaginationCellIndexPath
{
	const unsigned int lastSectionIndex = [mSections count] - 1;
	const unsigned int paginationCellRowNumber = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
	return [NSIndexPath indexPathForRow:paginationCellRowNumber inSection:lastSectionIndex];
}

- (void)_setPaginationCellIsLoading:(BOOL)isLoading
{	
	NSIndexPath* loadMoreButtonIndexPath = [self _getPaginationCellIndexPath];
	if (isLoading)
	{
		[self.tableView deselectRowAtIndexPath:loadMoreButtonIndexPath animated:YES];
	}
	UITableViewCell* lastcell = [self.tableView cellForRowAtIndexPath:loadMoreButtonIndexPath];
	OFTableSequenceControllerLoadMoreCell* paginationCell = (OFTableSequenceControllerLoadMoreCell*)lastcell;
	paginationCell.isLoading = isLoading;
	mIsLoadingNextPage = isLoading;
}

- (void)_paginationRequestSucceeded:(OFPaginatedSeries*)page chainedDelegate:(OFDelegateChained*)chainedDelegate
{
	NSIndexPath* cellToRefresh = [self _getPaginationCellIndexPath];
	
	[self _setPaginationCellIsLoading:false];
	[self _onDataLoadedWrapper:page isIncremental:YES];
	
	// This causes the old pagination cell to be refreshed by the view
	[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellToRefresh] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:cellToRefresh] withRowAnimation:UITableViewRowAnimationFade];	
	[self.tableView endUpdates];

	[chainedDelegate invoke];
}

- (void)_paginationRequestFailed:(NSArray*)resources chainedDelegate:(OFDelegateChained*)chainedDelegate
{
	[self _setPaginationCellIsLoading:false];
		
	[[[[UIAlertView alloc] 
		initWithTitle:nil
		message:@"OpenFeint was unable to load more items. Please try again"
		delegate:nil
		cancelButtonTitle:@"Ok"
		otherButtonTitles:nil] autorelease] show];
		
	[self getOnFailureDelegate].invoke(resources);

	[chainedDelegate invoke];
}

- (void)onTrailingCellWasClickedForSection:(OFTableSectionDescription*)section onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	if (section != [mSections lastObject])
	{
		return;
	}

	if(mIsLoadingNextPage || [section.page.header isLastPageLoaded])
	{
		return;
	}
	
	mNumLoadedPages += 1;
	
	[self _setPaginationCellIsLoading:true];
	
	OFDelegate paginationSucceeded(self, @selector(_paginationRequestSucceeded:chainedDelegate:), success);
	OFDelegate paginationFailed(self, @selector(_paginationRequestFailed:chainedDelegate:), failure);
		
	[self doIndexActionWithPage:mNumLoadedPages onSuccess:paginationSucceeded onFailure:paginationFailed];
}

- (void)onTrailingCellWasClickedForSection:(OFTableSectionDescription*)section
{
	[self onTrailingCellWasClickedForSection:section onSuccess:OFDelegate() onFailure:OFDelegate()];
}

- (void)doLoadMoreOnSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFTableSectionDescription* section = [mSections lastObject];
	[self onTrailingCellWasClickedForSection:section onSuccess:success onFailure:failure];
}

- (void)_streamingPaginationSucceeded:(OFPaginatedSeries*)page
{
	[self _onDataLoadedWrapper:page isIncremental:YES];
}
	
- (void)_downloadCurrentStreamingPage
{
	// citron todo: make sure if we have an oustanding request, we cancel it before sending the new request
	// also make sure that this errors "intelligently" instead of throwing up a huge ugly pop-up

	// citron note: need to know not to make a request if we already have the data loaded
	
	// citron note: perhaps we should store data until we get a low-memory request, then purge? that would give us the most
	//				flexibility. Could be fragile though...
		
	unsigned int offsetToLoad = ((NSIndexPath*)[[self.tableView indexPathsForVisibleRows] objectAtIndex:0]).row;	

	if(offsetToLoad > 0)
	{
		offsetToLoad -= 5; // need to move back some sensible amount so we have some "scrollback"
		
		if(offsetToLoad < 0)
		{
			offsetToLoad = 0;
		}
	}
	
	OFDelegate paginationSucceeded(self, @selector(_streamingPaginationSucceeded:));
	OFDelegate paginationFailed;		
	[self doIndexActionWithOffset:offsetToLoad onSuccess:paginationSucceeded onFailure:paginationFailed];

	[mCountdownToStreamingRequest invalidate];
	OFSafeRelease(mCountdownToStreamingRequest);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// citron note: this code needs to be moved somewhere else.
	
	if([self hasStreamingSections])
	{
		const float timeToWaitBeforeRequestingData = 0.1f;
		if(mCountdownToStreamingRequest)
		{
			[mCountdownToStreamingRequest setFireDate:[NSDate dateWithTimeIntervalSinceNow:timeToWaitBeforeRequestingData]];
		}
		else
		{
			mCountdownToStreamingRequest = [[NSTimer scheduledTimerWithTimeInterval:timeToWaitBeforeRequestingData
					 target:self
					 selector:@selector(_downloadCurrentStreamingPage)
					 userInfo:nil
					 repeats:NO] retain];
		}
	}
}

@end
