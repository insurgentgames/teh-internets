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

#import "OFAnnouncementService+Private.h"
#import "OFService+Private.h"
#import "OFDelegateChained.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFPaginatedSeries.h"
#import "OFNavigationController.h"
#import "OFTableSectionDescription.h"

#import "OFAnnouncement.h"
#import "OFForumPost.h"
#import "OFAnnouncementDetailController.h"

#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+NSNotification.h"

#import "NSDateFormatter+OpenFeint.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFAnnouncementService);

@implementation OFAnnouncementService

OPENFEINT_DEFINE_SERVICE(OFAnnouncementService);

- (void)dealloc
{
	OFSafeRelease(announcements);
	[super dealloc];
}

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFAnnouncement getResourceName], [OFAnnouncement class]);
	namedResources->addResource([OFForumPost getResourceName], [OFForumPost class]);
}

- (void)_combineSectionsAndSort:(OFPaginatedSeries*)page nextCall:(OFDelegateChained*)next
{
	OFPaginatedSeries* sorted = [OFPaginatedSeries paginatedSeries];
	
	if ([page count] > 0)
	{
		if ([[page objectAtIndex:0] isKindOfClass:[OFTableSectionDescription class]])
		{
			for (OFTableSectionDescription* section in page)
			{
				[sorted.objects addObjectsFromArray:section.page.objects];
			}
		}
		else
		{
			[sorted.objects addObjectsFromArray:page.objects];
		}
	}

	[sorted.objects sortUsingSelector:@selector(compareByDate:)];
	
	[next invokeWith:sorted];
}

- (void)_onAnnouncementsDownloaded:(OFPaginatedSeries*)page
{
	OFSafeRelease(announcements);
	announcements = [page retain];
	unseenAnnouncementCount = 0;
	
	BOOL showedFullscreen = NO;
	for (OFAnnouncement* announcement in announcements)
	{
		unseenAnnouncementCount += announcement.isUnread ? 1 : 0;

		// XXX TODO cut for field-runners 2.4 release
		if (false)//announcement.isImportant && announcement.isUnread && !showedFullscreen)	// full-screen
		{
			announcement.isUnread = NO;
			[OpenFeint setLastAnnouncementDateForLocalUser:announcement.date];
			--unseenAnnouncementCount;

			// developer is overriding the announcement screen
			if (![OpenFeint isDashboardHubOpen] &&	// cannot override announcement screen if we're prompting from within dashboard
				[[OpenFeint getDelegate] respondsToSelector:@selector(showCustomScreenForAnnouncement:)] &&
				[[OpenFeint getDelegate] showCustomScreenForAnnouncement:announcement])
			{
				showedFullscreen = YES;
			}
			else
			{
				OFAnnouncementDetailController* modal = [OFAnnouncementDetailController announcementDetail:announcement];
                modal.showCloseButton = YES;
				modal.title = @"Announcement";
				OFNavigationController* navController = [[[OFNavigationController alloc] initWithRootViewController:modal] autorelease];
				
				[OFNavigationController addCloseButtonToViewController:modal target:[OpenFeint class] action:@selector(dismissRootControllerOrItsModal) leftSide:NO systemItem:UIBarButtonSystemItemDone];

				if ([OpenFeint isDashboardHubOpen])
				{
					[[OpenFeint getRootController] presentModalViewController:navController animated:YES];
				}
				else
				{
					[OpenFeint presentRootControllerWithModal:navController];
				}

				showedFullscreen = YES;
			}
		}
	}

	[OpenFeint postUnreadAnnouncementCountChangedTo:unseenAnnouncementCount];
}

+ (void)downloadAnnouncements
{
	NSString* clientApplicationId = [OpenFeint clientApplicationId];
	NSDate* lastAnnouncementDate = [OpenFeint lastAnnouncementDateForLocalUser];

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("since", [[NSDateFormatter httpFormatter] stringFromDate:lastAnnouncementDate]);
	
	OFDelegate chainedSuccess([OFAnnouncementService sharedInstance], @selector(_onAnnouncementsDownloaded:));
	OFDelegate success([OFAnnouncementService sharedInstance], @selector(_combineSectionsAndSort:nextCall:), chainedSuccess);

	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"client_applications/%@/forums/announcements.xml", clientApplicationId]
		withParameters:params
		withSuccess:success
		withFailure:OFDelegate()
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)getIndexOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	success.invoke([OFAnnouncementService sharedInstance]->announcements);
}

+ (void)recentAnnouncementsForApplication:(NSString*)applicationId onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	OFDelegate chainedSuccess([OFAnnouncementService sharedInstance], @selector(_combineSectionsAndSort:nextCall:), success);

	[[self sharedInstance]
		getAction:[NSString stringWithFormat:@"client_applications/%@/forums/announcements.xml", applicationId] 
		withParameters:nil 
		withSuccess:chainedSuccess 
		withFailure:failure 
		withRequestType:OFActionRequestSilent 
		withNotice:nil];
}

+ (void)markAllAnnouncementsAsRead
{
	[self sharedInstance]->unseenAnnouncementCount = 0;
	[OpenFeint postUnreadAnnouncementCountChangedTo:[self sharedInstance]->unseenAnnouncementCount];
}

+ (void)clearLocalAnnouncements
{
	[OFAnnouncementService markAllAnnouncementsAsRead];
	OFSafeRelease([OFAnnouncementService sharedInstance]->announcements);
}

@end
