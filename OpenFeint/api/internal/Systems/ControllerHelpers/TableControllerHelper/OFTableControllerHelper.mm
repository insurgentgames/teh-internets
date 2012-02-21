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
#import "OFTableControllerHelper.h"
#import "OFTableControllerHelper+Overridables.h"
#import "OFLoadingController.h"
#import "OFViewHelper.h"
#import "OFDeadEndErrorController.h"
#import "OFControllerLoader.h"
#import <objc/runtime.h>
#import "OFTableSectionDescription.h"
#import "OFPoller.h"
#import "OFNavigationController.h"
#import "OFTableControllerHeader.h"
#import "OFFramedContentWrapperView.h"
#import "OpenFeint+Private.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFTableCellHelper.h"
#import "OFFramedNavigationController.h"

@interface OFTableControllerHelper ()
- (void)_displayEmptyDataSetView:(UIViewController*)optionalViewController andMessage:(NSString*)message;
- (void)_removeEmptyDataSetView;
- (void)_refreshDataIncrementally:(NSNotification*)notification;
- (void)_createSectionLeadingAndTrailingCells;
@end

@implementation OFTableControllerHelper

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self != nil)
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	
	return self;
}

- (OFDelegate)getOnSuccessDelegate
{
	return OFDelegate(self, @selector(_onDataLoadedWrapper:));
}

- (OFDelegate)getOnFailureDelegate
{
	return OFDelegate(self, @selector(_onDataFailedLoading));
}

- (bool)isInHiddenTab
{
	OFNavigationController* navController = (OFNavigationController*)self.navigationController;
	OFAssert([navController isKindOfClass:[OFNavigationController class]], @"only use OFNavigationControllers");
	return navController.isInHiddenTab;
}

- (void) hideLoadingScreen
{
	OFNavigationController* navController = (OFNavigationController*)self.navigationController;
	if(navController)
	{
		OFAssert([navController isKindOfClass:[OFNavigationController class]], @"only use OFNavigationControllers");
		[navController hideLoadingIndicator];
	}
}

- (void)showLoadingScreen
{
	OFNavigationController* navController = (OFNavigationController*)self.navigationController;
	if(navController)
	{
		OFAssert([navController isKindOfClass:[OFNavigationController class]], @"only use OFNavigationControllers");
		[navController showLoadingIndicator];
	}
}

- (void)_refreshDataIncrementally:(NSNotification*)notification
{
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeries];
	
	NSArray* resourceArray = [notification.userInfo objectForKey:OFPollerNotificationKeyForResources];
	for (OFResource* resource in resourceArray)
	{
		if ([self isNotificationResourceValid:resource])
			[page addObject:resource];
	}
	
	[self _onDataLoadedWrapper:page isIncremental:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.dataSource = self;

	mHelperCellsForHeight = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
	
	self.view.backgroundColor = [UIColor clearColor];
	self.view.opaque = NO;

	OFSafeRelease(mContainerView);
	mContainerView = [[self getBackgroundView] retain];
	if (mContainerView != nil)
	{
		mContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		mContainerView.autoresizesSubviews = YES;
		
		CGRect viewFrame = self.view.frame;
		viewFrame.origin = CGPointZero;
		self.view.frame = viewFrame;
		
		[mContainerView addSubview:self.tableView];
		
		self.view = mContainerView;
	}
}

- (UITableView*)tableView
{
	UITableView* table = [super tableView];
	if(!table)
	{
		return mMyTableView;
	}
	
	return table;
}

- (void)setView:(UIView*)view
{
	if (![view isKindOfClass:[UITableView class]] && mMyTableView == nil)
	{
		mMyTableView = self.tableView;
	}
	
	[super setView:view];
}

- (void)reloadDataFromServer
{
	[self _refreshData];
}

- (void)insertSection:(OFTableSectionDescription*)section atIndex:(NSInteger)index
{
	[mSections insertObject:section atIndex:index];
}

- (bool)_shouldRefresh
{
	return mSections == nil || [self shouldAlwaysRefreshWhenShown];
}

- (void)viewWillAppear:(BOOL)animated
{
// -----
//	adill: don't invoke the super here because we DO NOT want the keyboard notifications to be registered.
//		   instead we're just going to do what the header file says UITableViewController does.
//	[super viewWillAppear:animated];
	if ([self.tableView numberOfSections] == 0)
	{
		[self.tableView reloadData];
	}
	else
	{
		NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
		if (selection)
		{
			[self.tableView deselectRowAtIndexPath:selection animated:animated];
		}
	}
// -----

	if([self shouldRefreshAfterNotification])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshDataIncrementally:) name:[self getNotificationToRefreshAfter] object:nil];
	}
	
	// We load data in viewDidAppear do prevent problems with data failing to load, but if we don't need to load data we 
	// can populate here so it looks better
	if (![self autoLoadData] && [self _shouldRefresh])
	{
		[self _createAndDisplayTableHeader];
		[self _displayEmptyDataSetView:nil andMessage:[self getDataNotLoadedYetMessage]];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];	

	// We load data in viewDidAppear do prevent problems with data failing to load
	if([self autoLoadData] && [self _shouldRefresh])
	{
		[self _refreshData];
	}	 
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	OFViewHelper::resignFirstResponder(self.view);
	[self hideLoadingScreen];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[self getNotificationToRefreshAfter] object:nil];
}

- (void) _refreshData
{
    [self showLoadingScreen];
	[self onRefreshingData];
	[self doIndexActionOnSuccess:[self getOnSuccessDelegate] onFailure:[self getOnFailureDelegate]];    
}

- (void)_displayEmptyDataSetView:(UIViewController*)optionalViewController andMessage:(NSString*)message
{
	OFSafeRelease(mEmptyTableController);
	mEmptyTableController = [optionalViewController retain];
	if (mEmptyTableController == nil)
	{
		mEmptyTableController = (OFDeadEndErrorController*)[OFControllerLoader::load(@"EmptyDataSet") retain];
		mEmptyTableController.message = message;
	}
	
	[mEmptyTableController viewWillAppear:NO];
	CGRect noDataRect = mEmptyTableController.view.frame;
	noDataRect.size.width = self.tableView.frame.size.width;
	noDataRect.size.height = self.tableView.frame.size.height;
	if (mTableHeaderController)
	{
		// [adill] i don't believe in this line of code
//		noDataRect.size.height -= mTableHeaderController.view.frame.size.height;
	}
	mEmptyTableController.view.frame = noDataRect;
	self.tableView.tableFooterView = mEmptyTableController.view;
	[self onTableFooterCreated:mEmptyTableController];
	[self.tableView reloadData];
}

- (void)_removeEmptyDataSetView
{
	if (mEmptyTableController)
	{
		OFSafeRelease(mEmptyTableController);
		self.tableView.tableFooterView = nil;
	}
}

- (void)_onDataLoadedWrapper:(OFPaginatedSeries*)resources
{
	[self _onDataLoadedWrapper:resources isIncremental:NO];
}

- (void)_onDataLoadedWrapper:(OFPaginatedSeries*)resources isIncremental:(BOOL)isIncremental
{
	[self hideLoadingScreen];
	
	[self _onDataLoaded:resources isIncremental:isIncremental];

	[self _createAndDisplayTableHeader];
	
	if([mSections count] > 0)
	{
		[self _removeEmptyDataSetView];
	}
	else
	{
		[self _displayEmptyDataSetView:[self getNoDataFoundViewController] andMessage:[self getNoDataFoundMessage]];
		[self _reloadTableData];
	}
}

- (void) _reloadTableData
{
	[self _createSectionLeadingAndTrailingCells];
	[self.tableView reloadData];
}

- (bool)canReceiveCallbacksNow
{
	return [self navigationController] != nil;
}

- (void)_createAndDisplayTableHeader
{	
	NSString* tableHeaderControllerName = [self getTableHeaderControllerName];
	NSString* tableHeaderViewName = [self getTableHeaderViewName];
	if(tableHeaderControllerName)
	{
		if(!mTableHeaderController)
		{
			OFSafeRelease(mTableHeaderView);
			mTableHeaderController = [OFControllerLoader::load(tableHeaderControllerName, self) retain];
			[self onTableHeaderCreated:mTableHeaderController];
			
			if ([mTableHeaderController conformsToProtocol:@protocol(OFTableControllerHeader)])
			{
				UIViewController<OFTableControllerHeader>* headerController = mTableHeaderController;
				UIView* contentView = self.view;
				if ([self.view isKindOfClass:[OFFramedContentWrapperView class]])
				{
					OFFramedContentWrapperView* wrapperView = (OFFramedContentWrapperView*)self.view;
					contentView = wrapperView.wrappedView;
				}
				[headerController resizeView:contentView];
			}
			
			self.tableView.tableHeaderView = mTableHeaderController.view;
		}
	}
	else if (tableHeaderViewName)
	{
		if (!mTableHeaderView)
		{
			OFSafeRelease(mTableHeaderController);
			mTableHeaderView = [OFControllerLoader::loadView(tableHeaderViewName, self) retain];
			[self onTableHeaderCreated:nil];
			
			self.tableView.tableHeaderView = mTableHeaderView;
		}
	}
	
	// citron note: Setting a tableHeaderView to nil may cause the table to fill in blank space as if it
	//				had a full screen empty header. We have no idea why, but this seems to fix the issue. 
	else if(self.tableView.tableHeaderView != nil) 
	{
		self.tableView.tableHeaderView = nil;
	}
}

- (void)_createSectionLeadingAndTrailingCells
{	
	for(OFTableSectionDescription* section in mSections)
	{
		if(section.leadingCellName == nil)
		{
			section.leadingCellName = [self getLeadingCellControllerNameForSection:section];
		}
		
		if(section.trailingCellName == nil)
		{
			section.trailingCellName = [self getTrailingCellControllerNameForSection:section];
		}
	}
}

- (bool)_isScrolledToHead
{
	NSIndexPath* lastIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
	
	const unsigned int section = lastIndexPath.section;
	const unsigned int row = lastIndexPath.row;
	
	if(mSections == nil)
	{
		return true;
	}
	
	if([self isNewContentShownAtBottom])
	{
		const unsigned int numCellsInSection = [self getNumCellsInSection:lastIndexPath.section];
		return (section == [mSections count] - 1 && row == numCellsInSection - 1);
	}

	return (section == 0 && row == 0);
}

- (void)_scrollToTableHead:(BOOL)animate
{	
	if(mSections == nil)
	{
		return;
	} 
	
	NSIndexPath* firstCell = nil;
	CGRect targetRect = CGRectZero;
	
	if([self isNewContentShownAtBottom])
	{
		if(self.tableView.tableFooterView)
		{
			targetRect = self.tableView.tableFooterView.frame;
		}
		else
		{
			int lastSectionIndex = [mSections count] - 1;
			int numCellsInSection = [self getNumCellsInSection:lastSectionIndex];
			if (numCellsInSection > 0)
			{
				firstCell = [NSIndexPath indexPathForRow:numCellsInSection - 1 inSection:lastSectionIndex];
			}
			if (firstCell)
			{
				targetRect = [self.tableView rectForRowAtIndexPath:firstCell];
			}
		}
	}
	else
	{
		if(self.tableView.tableHeaderView)
		{
			targetRect = self.tableView.tableHeaderView.frame;
		}
		else
		{
			if ([self getNumCellsInSection:0] > 0)
			{
				firstCell = [NSIndexPath indexPathForRow:0 inSection:0];
			}
			if (firstCell)
			{
				targetRect = [self.tableView rectForRowAtIndexPath:firstCell];
			}
		}
	}	
	
	if(!CGRectEqualToRect(CGRectZero, targetRect))
	{
		[self.tableView scrollRectToVisible:targetRect animated:animate];
	}
}

- (void)_onDataFailedLoading
{
	[self hideLoadingScreen];
}

- (void)dealloc
{
	[self.tableView setDelegate:nil];
	[self.tableView setDataSource:nil];
	[self.tableView setTableHeaderView:nil];
	
	OFSafeRelease(mEmptyTableController);
	[mTableHeaderController.view removeFromSuperview];
	[mTableHeaderController release];
	mTableHeaderController = nil;
	
	[mTableHeaderView removeFromSuperview];
	OFSafeRelease(mTableHeaderView);
	
	[mHelperCellsForHeight release];
	mHelperCellsForHeight = nil;
	
	[mSections release];
	mSections = nil;
	
	OFSafeRelease(mContainerView);
	
	[self setTableView:nil];

	[super dealloc];
}

- (void)setOwningTabBarItem:(OFTabBarItem*)aTabBarItem
{
	owningTabBarItem = aTabBarItem;
}

- (OFTabBarItem*)owningTabBarItem
{
	return owningTabBarItem;
}

- (void)setBadgeValue:(NSString *)aBadgeValue
{
	if (self.navigationController)
		[self.navigationController setBadgeValue:aBadgeValue];
	else
		[super setBadgeValue:aBadgeValue];
}

- (OFResource*)getCellAtIndexPath:(NSIndexPath*)indexPath
{
	// citron note: need to handle if the player is clicking on a cell that has not yet been streamed in
	
	int row = indexPath.row;
	NSArray* cellsInSection = [self getSectionForIndexPath:indexPath].page.objects;
	int numCellsInSection = (int)[cellsInSection count];
	int resourceIndex = [self hasStreamingSections] ? row - [self _getLoadedBaseRowIndex] : row;
	return (numCellsInSection > resourceIndex) ? [cellsInSection objectAtIndex:resourceIndex] : nil;
}

- (OFTableSectionDescription*)getSectionForIndexPath:(NSIndexPath*)indexPath
{
	if (mSections)
	{
		NSAssert2(indexPath.section < [mSections count], @"invalid section index %d in class %s", indexPath.section, class_getName([self class]));
		
		if (indexPath.section < [mSections count])
		{
			return [mSections objectAtIndex:indexPath.section];
		}
		else
		{
			return nil;
		}
	}
	else
	{
		return nil;
	}
}

- (OFTableSectionDescription*)getSectionWithIdentifier:(NSString*)identifier
{
	if (mSections)
	{
		for (OFTableSectionDescription* section in mSections)
		{
			if ([section.identifier isEqualToString:identifier])
			{
				return section;
			}
		}
	}
	return nil;
}

- (NSInteger)getNumCellsInTable
{
	int numResources = 0;
	for (OFTableSectionDescription* section in mSections)
	{
		numResources += [section countPageItems];
	}
	return numResources;
}

- (NSInteger)getNumCellsInSection:(NSInteger)sectionIndex
{
	if (mSections)
	{
		int numSections = (int)[mSections count];
		
		// If the following assert traps the 0<0 case, server data may be wrong.
		NSAssert2(sectionIndex < numSections, @"invalid section index %d in class %s", sectionIndex, class_getName([self class]));
		
		if (sectionIndex < numSections)
		{
			OFTableSectionDescription* section = [mSections objectAtIndex:sectionIndex];
			
			if([self hasStreamingSections])
			{
				return [section countEntireItemSet];
			}
			
			return [section countPageItems];
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == [OpenFeint getDashboardOrientation];
}

- (unsigned int)_getLoadedBaseRowIndex
{
	OFTableSectionDescription* section = (OFTableSectionDescription*)[mSections objectAtIndex:0];
	return section.page.header.currentOffset;
}

- (unsigned int)_getNumItemsLoaded
{
	return [((OFTableSectionDescription*)[mSections objectAtIndex:0]).page count];
}

- (void)_changeResource:(OFResource*)resource forCell:(OFTableCellHelper*)cellHelper withIndex:(NSUInteger)row
{		
	if(![self hasStreamingSections])
	{
		[cellHelper changeResource:resource];
	}
	else
	{
		[cellHelper changeResource:resource withCellIndex:row];
	}
}

- (OFGameProfilePageInfo*)getPageContextGame
{
	if ([self.navigationController isKindOfClass:[OFFramedNavigationController class]])
	{
		OFFramedNavigationController* framedNavController = (OFFramedNavigationController*)self.navigationController;
		return framedNavController.currentGameContext;
	}
	else
	{
		return nil;
	}
}

- (OFUser*)getPageContextUser
{
	if ([self.navigationController isKindOfClass:[OFFramedNavigationController class]])
	{
		OFFramedNavigationController* framedNavController = (OFFramedNavigationController*)self.navigationController;
		return framedNavController.currentUser;
	}
	else
	{
		return nil;
	}
}

- (OFUser*)getPageComparisonUser
{
	if ([self.navigationController isKindOfClass:[OFFramedNavigationController class]])
	{
		OFFramedNavigationController* framedNavController = (OFFramedNavigationController*)self.navigationController;
		return framedNavController.comparisonUser;
	}
	else
	{
		return nil;
	}
}

- (void)didReceiveMemoryWarning
{
	// @BUG: We currently don't support view controllers unloading their views (due to the
	// surgery that goes on in OFFramedNavigationController).  Most of our views won't unload
	// because they're loaded from xibs, but table controllers are frequently instantiated
	// directly from code, so putting this here will prevent them from being unloaded.
}

@end
