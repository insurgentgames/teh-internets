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
#import "OFTwitterAccountLoginController.h"
#import "OFViewDataMap.h"
#import "OFISerializer.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFProvider.h"
#import "OFShowMessageAndReturnController.h"
#import "OFControllerLoader.h"

@implementation OFTwitterAccountLoginController

@synthesize streamIntegrationSwitch, streamIntegrationLabel, submitButton, contentView, integrationInfoLabel;

- (void)setupForConnectTwitter
{
	self.addingAdditionalCredential = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.addingAdditionalCredential)
	{
		self.streamIntegrationSwitch.hidden = YES;
		self.streamIntegrationLabel.hidden = YES;
		if ([OpenFeint isInLandscapeMode])
		{
			CGRect objectRect = self.submitButton.frame;
			objectRect.origin.y = self.streamIntegrationLabel.frame.origin.y;
			self.submitButton.frame = objectRect;
		}
		else
		{
			CGRect objectRect = self.privacyDisclosure.frame;
			objectRect.origin.y = self.streamIntegrationLabel.frame.origin.y;
			self.privacyDisclosure.frame = objectRect;
			
			objectRect = self.submitButton.frame;
			objectRect.origin.y = self.privacyDisclosure.frame.origin.y + self.privacyDisclosure.frame.size.height - 5.f;
			self.submitButton.frame = objectRect;
		}
		
		integrationInfoLabel.text = @"Enter the Twitter credentials you used to secure your OpenFeint account.";
	}
	else
	{
		integrationInfoLabel.text = @"Connect Twitter to find friends with OpenFeint and import your profile picture.";
	}
	
	[super viewWillAppear:animated];
}

- (bool)shouldUseOAuth
{
	return self.addingAdditionalCredential;
}

- (void)populateViewDataMap:(OFViewDataMap*)dataMap
{
	dataMap->addFieldReference(@"username",	1);
	dataMap->addFieldReference(@"password", 2);
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	
	OFRetainedPtr <NSString> credentialsType = @"twitter"; 
	parameterStream->io("credential_type", credentialsType);
	
	if (self.addingAdditionalCredential)
	{
		bool enableStreamIntegration = streamIntegrationSwitch.on;
		parameterStream->io("enable_stream_integration", enableStreamIntegration);
	}
}

- (void)registerActionsNow
{
}

- (NSString*)singularResourceName
{
	return @"credential";
}

- (NSString*)getFormSubmissionUrl
{
	return self.addingAdditionalCredential ? @"users_credentials.xml" : @"session.xml";
}

- (NSString*)getLoadingScreenText
{
	return self.addingAdditionalCredential ? @"Connecting To Twitter" : @"Logging In To OpenFeint";
}

- (OFShowMessageAndReturnController*)controllerToPushOnCompletion
{
	// Can assume that twitter authorization was successful.
	[OpenFeint setLoggedInUserHasTwitterCredential:YES];  // Update the local option flag to reflect success.  [Joe]
	 
	if (self.addingAdditionalCredential)
	{
		OFShowMessageAndReturnController* nextController =  (OFShowMessageAndReturnController*)OFControllerLoader::load(@"ShowMessageAndReturn");
		nextController.messageTitleLabel.text = @"Connected to Twitter";
		nextController.messageLabel.text = @"Your OpenFeint and Twitter accounts are now connected! Everyone you're following who has an OpenFeint account will be added to your My Friends list.";
		nextController.title = @"Finding Friends";
		return nextController;
	}
	else
	{
		return [self getStandardLoggedInController];
	}	
}

- (void)dealloc
{
	self.streamIntegrationSwitch = nil;
	self.streamIntegrationLabel = nil;
	self.submitButton = nil;
	self.contentView = nil;
	self.integrationInfoLabel = nil;
	[super dealloc];
}

@end