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

#import "OFAnnouncementBrowser.h"

#import "OFAnnouncement.h"
#import "OFAnnouncementService+Private.h"
#import "OFAnnouncementDetailController.h"

#import "OFResourceControllerMap.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OFFramedContentWrapperView.h"
#import "OFGameProfilePageInfo.h"

#import "OpenFeint+UserOptions.h"

@implementation OFAnnouncementBrowserController

#pragma mark Boilerplate

+ (id)announcementBrowser
{
	OFAnnouncementBrowserController* announcementBrowser = (OFAnnouncementBrowserController*)OFControllerLoader::load(@"AnnouncementBrowser");
	return announcementBrowser;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark OFViewController

- (void)viewWillAppear:(BOOL)animated
{
	self.title = @"Announcements";
	[super viewWillAppear:animated];
}

#pragma mark OFTableSequenceControllerHelper

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFAnnouncement class], @"ForumThread");
}

- (OFService*)getService
{
	return [OFAnnouncementService sharedInstance];
}

- (bool)shouldAlwaysRefreshWhenShown
{
	return true;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	if ([cellResource isKindOfClass:[OFAnnouncement class]])
	{
		OFAnnouncementDetailController* detail = [OFAnnouncementDetailController announcementDetail:(OFAnnouncement*)cellResource];
		[self.navigationController pushViewController:detail animated:YES];
	}
}

- (void)onResourcesDownloaded:(OFPaginatedSeries*)resources
{
	OFGameProfilePageInfo* context = [self getPageContextGame];
	if (!context || [context.resourceId isEqualToString:[OpenFeint clientApplicationId]])
	{
		if ([resources count] > 0)
		{
			OFAnnouncement* newest = (OFAnnouncement*)[resources objectAtIndex:0];
			for (OFAnnouncement* announcement in [resources objects])
			{
				if ([announcement.date laterDate:newest.date] == announcement.date)
				{
					newest = announcement;
				}
			}

			[OpenFeint setLastAnnouncementDateForLocalUser:newest.date];
		}
		
		[OFAnnouncementService markAllAnnouncementsAsRead];
	}
}

- (NSString*)getNoDataFoundMessage
{
	return @"There are no announcements";
}

- (NSString*)getTableHeaderViewName
{
	return nil;
}

- (void)onTableHeaderCreated:(UIViewController*)tableHeader
{
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	OFGameProfilePageInfo* context = [self getPageContextGame];
	if (!context || [context.resourceId isEqualToString:[OpenFeint clientApplicationId]])
	{
		[OFAnnouncementService getIndexOnSuccess:success onFailure:failure];
	}
	else
	{
		[OFAnnouncementService recentAnnouncementsForApplication:context.resourceId onSuccess:success onFailure:failure];
	}
}

@end
