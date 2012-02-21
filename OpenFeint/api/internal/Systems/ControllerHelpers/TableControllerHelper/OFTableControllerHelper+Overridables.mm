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
#import "OFTableControllerHelper+Overridables.h"
#import "OFService.h"
#import "OFControllerHelpersCommon.h"
#import "OFPatternedGradientView.h"
#import "OFTableCellBackgroundView.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"
#import "OFTableCellHelper+Overridables.h"

@implementation OFTableControllerHelper (Overridables)

- (NSString*)getTextToShowWhileLoading
{
	return @"Downloading";
}

- (UIViewController*)getNoDataFoundViewController
{
	// Optional
	return nil;
}

- (NSString*)getNoDataFoundMessage
{
	ASSERT_OVERRIDE_MISSING;
	return @"No data results were found";
}

- (NSString*)getTableHeaderViewName
{
	return nil;
}

- (NSString*)getTableHeaderControllerName
{
	return nil;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
	// Do Nothing
}

- (void)onTableFooterCreated:(UIViewController*)tableFooter
{
	// Do Nothing
}

- (OFService*) getService
{
	ASSERT_OVERRIDE_MISSING;
	return nil;
}

- (void)onLeadingCellWasClickedForSection:(OFTableSectionDescription*)section
{
	// Do Nothing
}

- (void)onTrailingCellWasClickedForSection:(OFTableSectionDescription*)section
{
	// Do Nothing
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	// Do Nothing
}

- (void)onRefreshingData
{
	// Do Nothing
}

- (bool)shouldAlwaysRefreshWhenShown
{
	return NO;
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	ASSERT_OVERRIDE_MISSING;
}

- (void)_onDataLoaded:(OFPaginatedSeries*)resources isIncremental:(BOOL)isIncremental
{
	ASSERT_OVERRIDE_MISSING;
}

- (bool)isNewContentShownAtBottom
{
	return false;
}

- (OFResource*) getResourceFromSection:(NSArray*)sectionCells atRow:(NSUInteger)row
{
	ASSERT_OVERRIDE_MISSING;
	return nil;
}

- (NSString*) getCellControllerNameFromSection:(NSArray*)sectionCells atRow:(NSUInteger)row
{
	ASSERT_OVERRIDE_MISSING;
	return @"";
}

- (bool)shouldRefreshAfterNotification
{
	return false;
}

- (NSString*)getNotificationToRefreshAfter
{
	return @"";
}

- (bool)isNotificationResourceValid:(OFResource*)resource
{
	return true;
}

- (NSString*)getLeadingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	return nil;
}

- (NSString*)getTrailingCellControllerNameForSection:(OFTableSectionDescription*)section
{
	return nil;
}

- (void)onLeadingCellWasLoaded:(OFTableCellHelper*)leadingCell forSection:(OFTableSectionDescription*)section
{
	
}

- (void)onTrailingCellWasLoaded:(OFTableCellHelper*)trailingCell forSection:(OFTableSectionDescription*)section
{
	
}

- (bool)autoLoadData
{
	return true;
}

- (NSString*)getDataNotLoadedYetMessage
{
	return @"";
}

- (UIView*)getBackgroundView
{
	return nil;
}

- (void)configureCell:(OFTableCellHelper*)_cell asLeading:(BOOL)_isLeading asTrailing:(BOOL)_isTrailing asOdd:(BOOL)_isOdd
{
	if (!_cell)
		return;

	if([_cell wantsToConfigureSelf])
	{
		[_cell configureSelfAsLeading:_isLeading asTrailing:_isTrailing asOdd:_isOdd];
	}
	else
	{
		OFTableCellBackgroundView* background = (OFTableCellBackgroundView*)_cell.backgroundView;
		OFTableCellBackgroundView* selectedBackground = (OFTableCellBackgroundView*)_cell.selectedBackgroundView;
		if (![background isKindOfClass:[OFTableCellBackgroundView class]])
		{
			_cell.backgroundView = background = [OFTableCellBackgroundView defaultBackgroundView];
			_cell.selectedBackgroundView = selectedBackground = [OFTableCellBackgroundView defaultBackgroundView];
			//TODO: customize accessory view?
		}

		if (_isLeading)
		{
			UIImage* bgImage = [OFImageLoader loadImage:@"OFLeadingCellBackground.png"];
			background.image = bgImage;
			selectedBackground.image = bgImage;
		}
		else if (_isTrailing)
		{
			UIImage* bgImage = [OFImageLoader loadImage:@"OFTableCellDefaultBackground.png"];
			background.image = bgImage;
			selectedBackground.image = bgImage;
		}
		else if (_isOdd)
		{
			background.image = [OFImageLoader loadImage:@"OFTableCellDefaultBackgroundOdd.png"];
			selectedBackground.image = [OFImageLoader loadImage:@"OFTableCellDefaultBackgroundOddSelected.png"];
		}
		else
		{
			background.image = [OFImageLoader loadImage:@"OFTableCellDefaultBackground.png"];
			selectedBackground.image = [OFImageLoader loadImage:@"OFTableCellDefaultBackgroundSelected.png"];
		}		
	}
}

//- (void)didSwipeCell:(OFTableCellHelper*)_cell
//{
//}
//
//- (void)clearSwipedCell
//{
//}

- (bool)hasStreamingSections
{
	return false;
}

- (bool)isAlphabeticalList
{
	return false;
}

- (bool)allowEditing
{
	return false;
}

- (bool)shouldConfirmResourceDeletion
{
	return false;
}

- (NSString*)getResourceDeletePromptText:(OFResource*)resource
{
	return @"Are you sure?";
}

- (NSString*)getResourceDeleteCancelText
{
	return @"Cancel";
}

- (NSString*)getResourceDeleteConfirmText
{
	return @"Confirm";
}

- (void)onResourceWasDeleted:(OFResource*)cellResource
{
}

@end