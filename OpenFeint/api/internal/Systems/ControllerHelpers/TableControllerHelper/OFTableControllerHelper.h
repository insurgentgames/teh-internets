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

#import "OFPointer.h"
#import "OFCallbackable.h"
#import "OFDelegate.h"
#import "UIViewController+TabBar.h"
#import "OFTabBarItem.h"

@class OFTableSectionCellDescription;
@class OFTableSectionDescription;
@class OFDeadEndErrorController;
@class OFResource;
@class OFPaginatedSeries;
@class OFLoadingController;
@class OFTableCellHelper;
@class OFUser;
@class OFGameProfilePageInfo;

@interface OFTableControllerHelper : UITableViewController<OFCallbackable, UIActionSheetDelegate>
{
@package
	OFLoadingController* mLoadingScreen;
	UIViewController* mTableHeaderController;
	UIView* mTableHeaderView;
	OFDeadEndErrorController* mEmptyTableController;
	NSMutableDictionary* mHelperCellsForHeight;
	NSMutableArray* mSections;
	UITableView* mMyTableView;
	UIView* mContainerView;
	OFTabBarItem* owningTabBarItem;
	
	NSIndexPath* deletingIndexPath;
}

- (id)initWithStyle:(UITableViewStyle)style;
- (id)initWithCoder:(NSCoder*)aDecoder;

- (bool)canReceiveCallbacksNow;
- (void)showLoadingScreen;
- (void)hideLoadingScreen;
- (OFDelegate)getOnSuccessDelegate;
- (OFDelegate)getOnFailureDelegate;

- (OFResource*)getCellAtIndexPath:(NSIndexPath*)indexPath;
- (OFTableSectionDescription*)getSectionForIndexPath:(NSIndexPath*)indexPath;
- (OFTableSectionDescription*)getSectionWithIdentifier:(NSString*)identifier;
- (NSInteger)getNumCellsInTable;
- (NSInteger)getNumCellsInSection:(NSInteger)sectionIndex;
- (bool)isInHiddenTab;


- (UITableView*)tableView;


- (void)setView:(UIView*)view;
- (void)reloadDataFromServer;
- (void)insertSection:(OFTableSectionDescription*)section atIndex:(NSInteger)index;

// private
- (void)_createAndDisplayTableHeader;
- (void)_onDataLoadedWrapper:(OFPaginatedSeries*)resources isIncremental:(BOOL)isIncremental;
- (void)_displayEmptyDataSetView:(UIViewController*)optionalViewController andMessage:(NSString*)message;
- (bool)_shouldRefresh;

- (void)_refreshData;
- (void)_reloadTableData;
- (bool)_isScrolledToHead;
- (void)_scrollToTableHead:(BOOL)animate;

- (unsigned int)_getLoadedBaseRowIndex;
- (unsigned int)_getNumItemsLoaded;

- (void)_changeResource:(OFResource*)resource forCell:(OFTableCellHelper*)cellHelper withIndex:(NSUInteger)row;

- (OFGameProfilePageInfo*)getPageContextGame;
- (OFUser*)getPageContextUser;
- (OFUser*)getPageComparisonUser;

@end
