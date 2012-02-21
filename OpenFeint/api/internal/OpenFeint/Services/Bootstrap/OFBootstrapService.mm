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
#import "OFBootstrapService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFBootstrap.h"
#import "OFPoller.h"
#import "OpenFeint+Private.h"
#import "OFDelegateChained.h"
#import "OFResourceNameMap.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+UserStats.h"
#import "OFXmlDocument.h"
#import "OFProvider.h"
#import "OFOfflineService.h"
#import "OFGameProfilePageInfo.h"
#import "OFPresenceService.h"
#import "IPhoneOSIntrospection.h"
#import "OFSettings.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFBootstrapService);

@implementation OFBootstrapService

OPENFEINT_DEFINE_SERVICE(OFBootstrapService);

- (id) init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)registerPolledResources:(OFPoller*)poller
{
}

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFBootstrap getResourceName], [OFBootstrap class]);
	[OFOfflineService shareKnownResources:namedResources];
}

+ (void) doBootstrapWithDeviceToken:(NSData*)deviceToken onSucceededLoggingIn:(const OFDelegate&)onSuccess onFailedLoggingIn:(const OFDelegate&)onFailure
{
	[OFBootstrapService doBootstrapWithDeviceToken:deviceToken forceCreateNewAccount:NO onSucceededLoggingIn:onSuccess onFailedLoggingIn:onFailure];
}

+ (void) doBootstrapWithDeviceToken:(NSData*)deviceToken forceCreateNewAccount:(bool)forceCreateNewAccount onSucceededLoggingIn:(const OFDelegate&)onSuccess onFailedLoggingIn:(const OFDelegate&)onFailure
{
	[OFBootstrapService doBootstrapWithDeviceToken:deviceToken forceCreateNewAccount:NO userId:nil onSucceededLoggingIn:onSuccess onFailedLoggingIn:onFailure];
}

+ (void) doBootstrapWithDeviceToken:(NSData*)deviceToken forceCreateNewAccount:(bool)forceCreateNewAccount userId:(NSString*)userId onSucceededLoggingIn:(const OFDelegate&)onSuccess onFailedLoggingIn:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> udid = [UIDevice currentDevice].uniqueIdentifier;
	params->io("udid", udid);
	if (userId && ![userId isEqualToString:@"0"])
	{
		params->io("user_id", userId);
	}
	if (forceCreateNewAccount)
	{
		params->io("create_new_account", forceCreateNewAccount);
	}

	OFRetainedPtr<NSString> hardwareVersion = getHardwareVersion();
	OFRetainedPtr<NSString> osVersion = OFSettings::Instance()->getClientDeviceSystemVersion();
	
	params->io("device_hardware_version", hardwareVersion);
	params->io("device_os_version", osVersion);
	
	//Get any params needed for offline
	[OFOfflineService getBootstrapCallParams:params userId:userId];
	//Send up the latest user stats
	[OpenFeint getUserStatsParams:params];
	
	//
	if (deviceToken)
	{
#ifdef _DISTRIBUTION
#ifdef _DEBUG
	#error "_DISTRIBUTION should only be defined when making distribution builds. OpenFeint relies on it to choose push notification environment"
#endif
		params->io("apns_environment", @"production");
#else
		params->io("apns_environment", @"sandbox");
#endif
		NSString *tokenString = [[NSString alloc] initWithFormat:@"%@", deviceToken];
		tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
		tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSString *tokenEncoded = [tokenString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		params->io("device_token", tokenEncoded);
	}
	
	[[self sharedInstance]
	 _performAction:@"bootstrap.xml"
	 withParameters:params
	 withHttpMethod:@"POST"
	 withSuccess:OFDelegate([self sharedInstance], @selector(_onReceivedConfiguration:nextCall:), onSuccess)
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil 
	 requiringAuthentication:false];
}


- (void)_onReceivedConfiguration:(NSArray*)resources nextCall:(OFDelegateChained*)chainedDelegate
{
	if([resources count] == 0)
	{
		return;
	}
	
	//OFLog(@"Bootstrap stage 1");
	
	OFBootstrap* bootstrap = (OFBootstrap*)[resources objectAtIndex:0];
	[OpenFeint storePollingFrequencyDefault:bootstrap.pollingFrequencyDefault];
	[OpenFeint storePollingFrequencyInChat:bootstrap.pollingFrequencyInChat];
	[[OpenFeint provider] setAccessToken:bootstrap.accessToken andSecret:bootstrap.accessTokenSecret];
	[OpenFeint setLoggedInUserHasSetName:bootstrap.loggedInUserHasSetName];
	[OpenFeint setLoggedInUserHasChatEnabled:bootstrap.loggedInUserHasChatEnabled];
	[OpenFeint setLoggedInUserHadFriendsOnBootup:bootstrap.loggedInUserHadFriendsOnBootup];
	
	[OpenFeint setLoggedInUserHasHttpBasicCredential:bootstrap.loggedInUserHasHttpBasicCredential];
	[OpenFeint setLoggedInUserHasFbconnectCredential:bootstrap.loggedInUserHasFbconnectCredential];
	[OpenFeint setLoggedInUserHasTwitterCredential:bootstrap.loggedInUserHasTwitterCredential];
	
	[OpenFeint setLoggedInUserHasNonDeviceCredential: bootstrap.loggedInUserHasHttpBasicCredential 
													  || bootstrap.loggedInUserHasFbconnectCredential 
													  || bootstrap.loggedInUserHasTwitterCredential];
	
	[OpenFeint setLoggedInUserIsNewUser:bootstrap.loggedInUserIsNewUser];
	[OpenFeint setClientApplicationId:bootstrap.clientApplicationId];
	[OpenFeint setClientApplicationIconUrl:bootstrap.clientApplicationIconUrl];
	[OpenFeint setUnviewedChallengesCount:bootstrap.unviewedChallengesCount];
	[OpenFeint setPendingFriendsCount:bootstrap.pendingFriendsCount];
	[OpenFeint setLocalGameProfileInfo:bootstrap.gameProfilePageInfo];
	[OpenFeint setLocalUser:bootstrap.user];
	[OpenFeint setSuggestionsForumId:bootstrap.suggestionsForumId];
	[OpenFeint setInitialDashboardScreen:bootstrap.initialDashboardScreen];
	[OpenFeint setLoggedInUserSharesOnlineStatus:bootstrap.initializePresenceService];

	[OpenFeint setUnreadInboxCount:bootstrap.subscriptionsUnreadCount];
	[OpenFeint setUserDistanceUnit: (bootstrap.loggedInUserHasShareLocationEnabled ? kDistanceUnitMiles : kDistanceUnitNotAllowed)];
	
	[[OFPresenceService sharedInstance] connectToPresenceQueue:bootstrap.presenceQueue withOAuthAccessToken:bootstrap.accessToken andHttpPipeEnabled:bootstrap.pipeHttpOverPresenceService andBroadcastStatus:bootstrap.initializePresenceService];

	//OFLog(@"Bootstrap stage 2");
	
	if([resources count] > 1)
	{
		//sync data from host
		OFOffline* offline = (OFOffline*)[resources objectAtIndex:1];
		[OFOfflineService syncOfflineData:offline bootStrap:bootstrap];
	}
	
	[chainedDelegate invoke];
	

}



@end
