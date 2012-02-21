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

#import "OFTwitterExtendedCredentialController.h"
#import "OFViewDataMap.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+Overridables.h"
#import "OFFormControllerHelper+Submit.h"
#import "OFControllerLoader.h"
#import "OFActionRequest.h"
#import "OFSocialNotification.h"
#import "OFImageView.h"
#import "OpenFeint+Private.h"

@implementation OFTwitterExtendedCredentialController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	mBackgroundWindow.contentMode = UIViewContentModeScaleToFill;
	mBackgroundWindow.image = [mBackgroundWindow.image stretchableImageWithLeftCapWidth:0.f topCapHeight:120.f];
}

- (NSString*)getFormSubmissionUrl 
{
	return @"extended_credentials.xml";
}

-(NSString*)singularResourceName
{
	return @"credential";
}

-(void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap -> addFieldReference(@"password", 1);
}

-(void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	OFRetainedPtr <NSString> credential_type = @"twitter";
	parameterStream->io("credential_type", credential_type);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (IBAction)dismiss
{
	[OpenFeint dismissDashboard];
}

- (IBAction)onSubmitForm:(UIView*)sender
{
	mLoadingView.hidden = NO;
	[super onSubmitForm:sender];
}

- (void)onPresentingErrorDialog
{
	mLoadingView.hidden = YES;
}

-(void)onFormSubmitted
{
	mLoadingView.hidden = YES;
	[self dismiss];

	if (mRequestToSubmit && !mNextController)
	{
		[mRequestToSubmit dispatch];
	}
	else if (mNextController)
	{
		[OpenFeint presentModalOverlay:mNextController];
	}
}

- (void)registerActionsNow
{
}

- (void)setNextController:(UIViewController<OFExtendedCredentialController>*)_next
{
	OFSafeRelease(mNextController);
	mNextController = [_next retain];
}

- (void)setRequestRequiringCredential:(OFActionRequest*)_request
{
	OFSafeRelease(mRequestToSubmit);
	mRequestToSubmit = [_request retain];
}

- (void)setSocialNotification:(OFSocialNotification*)_notification
{	
	mNotificationImage.imageUrl = _notification.imageUrl;
	mNotificationText.text = _notification.text;
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)dealloc 
{
	OFSafeRelease(mBackgroundWindow);
	OFSafeRelease(mRequestToSubmit);
	OFSafeRelease(mNextController);
	OFSafeRelease(mLoadingView);
	OFSafeRelease(mNotificationImage);
	OFSafeRelease(mNotificationText);
	[super dealloc];
}

@end