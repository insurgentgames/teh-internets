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
#import "OFFacebookAccountLoginController.h"
#import "OFViewDataMap.h"
#import "OFProvider.h"
#import "OFISerializer.h"
#import "OFProvider.h"
#import "OFControllerLoader.h"
#import "OFShowMessageAndReturnController.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"

@implementation OFFacebookAccountLoginController

@synthesize streamIntegrationSwitch, streamIntegrationLabel, findFriendsLabel;

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.addingAdditionalCredential)
	{
		self.streamIntegrationSwitch.hidden = YES;
		self.streamIntegrationLabel.hidden = YES;
		CGRect disclosureRect = self.privacyDisclosure.frame;
		disclosureRect.origin.y = self.findFriendsLabel.frame.origin.y;
		self.privacyDisclosure.frame = disclosureRect;
		findFriendsLabel.hidden = YES;
	}
	
	[super viewWillAppear:animated];
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{	
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	
	OFRetainedPtr<NSString> facebookUId = [NSString stringWithFormat:@"%lld", self.fbuid];
	OFRetainedPtr<NSString> facebookSessionKey = [self.fbSession sessionKey];
	if(self.fbSession == nil)
	{
		facebookSessionKey = @"";
	}
	
	parameterStream->io("credential[fbuid]",	   facebookUId);
	parameterStream->io("credential[session_key]", facebookSessionKey);
	
	if (self.addingAdditionalCredential)
	{
		bool enableStreamIntegration = streamIntegrationSwitch.on;
		parameterStream->io("enable_stream_integration", enableStreamIntegration);
	}
}

- (NSString*)singularResourceName
{
	return self.addingAdditionalCredential ? @"users_credential" : @"credential";
}

- (NSString*)getFormSubmissionUrl
{
	return self.addingAdditionalCredential ? @"users_credentials.xml" : @"session.xml";
}

- (NSString*)getLoadingScreenText
{
	return self.addingAdditionalCredential ? @"Connecting To Facebook" : @"Logging In To OpenFeint";
}

- (OFShowMessageAndReturnController*)controllerToPushOnCompletion
{
	// Can assume that facebook authorization was successful.
	[OpenFeint setLoggedInUserHasFbconnectCredential:YES];  // Update the local option flag to reflect success.  [Joe]
	
	if (self.addingAdditionalCredential)
	{
		OFShowMessageAndReturnController* nextController =  (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
		nextController.messageTitleLabel.text = @"Connected to Facebook";
		nextController.messageLabel.text = @"Your OpenFeint account is now connected to Facebook. Any of your Facebook friends with OpenFeint will be added to your My Friends list.";
		nextController.title = @"Finding Friends";
		return nextController;
	}
	else
	{
		return [super getStandardLoggedInController];
	}	
}

- (void)dealloc
{
	self.streamIntegrationLabel = nil;
	self.streamIntegrationSwitch = nil;
	self.findFriendsLabel = nil;
	[super dealloc];
}
@end
