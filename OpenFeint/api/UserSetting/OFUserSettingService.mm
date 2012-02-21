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
#import "OFUserSettingService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFUserSetting.h"
#import "OFUserSettingPushController.h"
#import "OFLeaderboard.h"
#import "OpenFeint+UserOptions.h"
#import "OFNewsletterSubscription.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFUserSettingService);

@implementation OFUserSettingService

OPENFEINT_DEFINE_SERVICE(OFUserSettingService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFUserSetting getResourceName], [OFUserSetting class]);
	namedResources->addResource(@"setting", [OFUserSetting class]); // @HACK to get getUserSettingWithKey to work.
	namedResources->addResource([OFUserSettingPushController getResourceName], [OFUserSettingPushController class]);
	namedResources->addResource([OFNewsletterSubscription getResourceName], [OFNewsletterSubscription class]);
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("udid", [[UIDevice currentDevice] uniqueIdentifier]);

	[[self sharedInstance]
		getAction:@"users/@me/settings.xml"
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestForeground
		withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Settings"]];
}

+ (void) getUserSettingWithKey:(NSString*)settingKey onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[[self sharedInstance]
	 getAction:[NSString stringWithFormat:@"users/@me/settings/%@.xml", settingKey]
	 withParameters:nil
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Settings"]];
}

+ (void) setUserSettingWithId:(NSString*)settingId toBoolValue:(bool)value onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;

	{
		OFISerializer::Scope high_score(params, "user_setting");
		OFRetainedPtr<NSString> idString = settingId;
		params->io("id", idString);
		params->io("value", value);		
	}

	[[self sharedInstance]
		postAction:@"users/@me/settings.xml"
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestForeground
		withNotice:[OFNotificationData foreGroundDataWithText:@"Updated Setting"]];
}

+ (void) setUserSettingWithKey:(NSString*)settingKey toBoolValue:(bool)value onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	{
		OFISerializer::Scope high_score(params, "user_setting");
		OFRetainedPtr<NSString> keyString = settingKey;
		params->io("key", keyString);
		params->io("value", value);		
	}
	
	[[self sharedInstance]
	 postAction:@"users/@me/settings.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Updated Setting"]];
}

+ (void) setSubscribeToDeveloperNewsLetter:(BOOL)subscribe clientApplicationId:(NSString*)clientApplicationId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	clientApplicationId = clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId];
	if (subscribe)
	{
		[[self sharedInstance]
		 postAction:[NSString stringWithFormat:@"client_applications/%@/news_letter_subscription.xml", clientApplicationId]
		 withParameters:nil
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestForeground
		 withNotice:[OFNotificationData foreGroundDataWithText:@"Subscribing"]];
	}
	else
	{
		[[self sharedInstance]
		 deleteAction:[NSString stringWithFormat:@"client_applications/%@/news_letter_subscription.xml", clientApplicationId]
		 withParameters:nil
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestForeground
		 withNotice:[OFNotificationData foreGroundDataWithText:@"Unsubscribing"]];
	}
}

+ (void) getSubscribingToDeveloperNewsLetter:(NSString*)clientApplicationId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	clientApplicationId = clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId];
	[[self sharedInstance]
	 getAction:[NSString stringWithFormat:@"client_applications/%@/news_letter_subscription.xml", clientApplicationId]
	 withParameters:nil
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Retrieving Data"]];
}

@end
