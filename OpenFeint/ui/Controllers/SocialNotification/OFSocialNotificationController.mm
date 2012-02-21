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

#import "OFSocialNotificationController.h"
#import "OFSocialNotificationService.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"
#import "OFSocialNotificationService+Private.h"
#import "OFImageView.h"
#import "OFImageUrl.h"
#import "OFPaginatedSeries.h"

@implementation OFSocialNotificationController

@synthesize socialNotification = mSocialNotification;
@synthesize notificationText = mNotificationText;
@synthesize applicationLabel = mApplicationLabel;
@synthesize notificationImage = mNotificationImage;
@synthesize rememberSwitch = mRememberSwitch;
@synthesize networkIcon1 = mNetworkIcon1;
@synthesize networkIcon2 = mNetworkIcon2;

-(void)addSocialNetworkIcon:(UIImage*)networkIcon
{
	if (mNetworkIcon1.hidden)
	{
		mNetworkIcon1.image = networkIcon;
		mNetworkIcon1.hidden = NO;
	}
	else if (mNetworkIcon2.hidden)
	{
		mNetworkIcon2.image = networkIcon;
		mNetworkIcon2.hidden = NO;
	}
	else
	{
		OFAssert(false, "Too many networks!");
	}
}

- (void)_imageUrlDownloaded:(OFPaginatedSeries*)resources
{
	OFImageUrl* url = [resources.objects objectAtIndex:0];
	mNotificationImage.imageUrl = url.url;
	mSocialNotification.imageUrl = url.url;
}

- (void)_imageUrlFailed
{
	// TODO: do we need some default image?
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

	mNotificationImage.unframed = NO;
	
	if (mSocialNotification.imageUrl != nil)
	{
		mNotificationImage.imageUrl = mSocialNotification.imageUrl;
	}
	else
	{
		[mNotificationImage showLoadingIndicator];
		[OFSocialNotificationService 
			getImageUrlForNotificationImageNamed:mSocialNotification.imageIdentifier 
			onSuccess:OFDelegate(self, @selector(_imageUrlDownloaded:))
			onFailure:OFDelegate(self, @selector(_imageUrlFailed))];
	}

	mNotificationText.text = mSocialNotification.text;
}

-(void)_rememberChoice:(BOOL)choice
{
	if(mRememberSwitch.on)
	{
		[OpenFeint setUserHasRememberedChoiceForNotifications:YES];
		[OpenFeint setUserAllowsNotifications:choice];
	}
}

-(void)dismiss
{
	[OpenFeint dismissDashboard];
}

-(void)yesButtonClicked:(UIButton*)sender
{
	[OFSocialNotificationService sendWithoutRequestingPermissionWithSocialNotification:mSocialNotification];
	[self _rememberChoice:YES];
	[self dismiss];
}

-(void)noButtonClicked:(UIButton*)sender
{
	[self _rememberChoice:NO];
	[self dismiss];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc 
{
	self.socialNotification = nil;
	self.notificationText = nil;
	self.notificationImage = nil;
	self.applicationLabel = nil;
	self.rememberSwitch = nil;
	self.networkIcon1 = nil;
	self.networkIcon2 = nil;
    [super dealloc];
}


@end
