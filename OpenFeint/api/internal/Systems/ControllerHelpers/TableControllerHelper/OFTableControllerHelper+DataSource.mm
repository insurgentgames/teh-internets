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
#import "OFTableControllerHelper+DataSource.h"
#import "OFTableControllerHelper+Overridables.h"
#import "OFTableControllerHelper+ViewDelegate.h"
#import "OFTableSectionDescription.h"
#import "OpenFeint+Private.h"

@implementation OFTableControllerHelper (DataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return mSections ? [mSections count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self getNumCellsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	int numSections = [mSections count];
	if (section < numSections)
	{
		OFTableSectionDescription* ofSection = [mSections objectAtIndex:section];
		return ofSection.title;
	}
	else
	{
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self getCellForIndex:indexPath inTable:tableView useHelperCell:NO];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if ([self isAlphabeticalList] && [self getNumCellsInTable] > 0)
	{
		NSMutableArray* nameArray = [[NSMutableArray new] autorelease];

		for (unichar i = 'A'; i <= 'Z'; i++)
		{
			[nameArray addObject:[NSString stringWithCharacters:&i length:1]];
		}

		unichar pound = '#';
		[nameArray addObject:[NSString stringWithCharacters:&pound length:1]];

		return nameArray;
	}
	else
	{
		return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if ([self isAlphabeticalList] && [mSections count] > 0)
	{
		for (unsigned int i = 0; i < [mSections count]; i++)
		{
			OFTableSectionDescription* curSection = [mSections objectAtIndex:i];
			if ([title length] == 0 ||
				[curSection.title isEqualToString:title] ||
				([title characterAtIndex:0] != '#' && [title characterAtIndex:0] < [curSection.title characterAtIndex:0]))
			{
				return i;
			}
		}
		return [mSections count] - 1;
	}
	else 
	{
		return 0;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (![self allowEditing] || [self hasStreamingSections])
		return NO;
		
	BOOL isLeadingCell = NO;
	BOOL isTrailingCell = NO;
	[self isCellAtPath:indexPath leadingCell:isLeadingCell trailingCell:isTrailingCell];
	
	return !(isLeadingCell || isTrailingCell);
}

- (void)_confirmDelete
{
	if (deletingIndexPath)
	{
		OFTableSectionDescription* section = [self getSectionForIndexPath:deletingIndexPath];
		OFResource* cellResource = [[section.page.objects objectAtIndex:deletingIndexPath.row] retain];
		[section.page.objects removeObjectAtIndex:deletingIndexPath.row];
		[[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:deletingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self onResourceWasDeleted:[cellResource autorelease]];		
		OFSafeRelease(deletingIndexPath);
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex)
	{
		// do nothing
	}
	else if (buttonIndex == actionSheet.destructiveButtonIndex)
	{
		[self _confirmDelete];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	deletingIndexPath = [indexPath retain];

	BOOL shouldConfirm = [self shouldConfirmResourceDeletion];
	if (shouldConfirm)
	{
		OFTableSectionDescription* section = [self getSectionForIndexPath:deletingIndexPath];
		OFResource* cellResource = [[section.page.objects objectAtIndex:deletingIndexPath.row] retain];

		[[[[UIActionSheet alloc] 
			initWithTitle:[self getResourceDeletePromptText:cellResource]
			delegate:self 
			cancelButtonTitle:[self getResourceDeleteCancelText]
			destructiveButtonTitle:[self getResourceDeleteConfirmText]
			otherButtonTitles:nil] autorelease]
		 showInView: self.view];
		//showInView:[OpenFeint getTopLevelView]]; // this sometimes shows the action sheet in the wrong orientation
	}
	else
	{
		[self _confirmDelete];
	}
}

@end
