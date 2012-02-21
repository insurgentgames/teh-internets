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
#import "OFPushNotificationService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFPushNotificationService);

@implementation OFPushNotificationService

OPENFEINT_DEFINE_SERVICE(OFPushNotificationService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
}


+ (void)setDeviceToken:(NSData*)deviceToken onSuccess:(OFDelegate)onSuccess onFailure:(OFDelegate)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
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
		OFRetainedPtr<NSString> udid = [UIDevice currentDevice].uniqueIdentifier;
		params->io("udid", udid);
		
		NSString *tokenString = [[NSString alloc] initWithFormat:@"%@", deviceToken];
		tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
		tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSString *tokenEncoded = [tokenString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		params->io("device_token", tokenEncoded);
		
		[[self sharedInstance]
		 postAction:@"push_notification_device_tokens.xml"
		 withParameters:params
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestSilent
		 withNotice:nil];
	}
	else
	{
		OFLog(@"Nil device token passed to OFPushNotificationService setDeviceToken");
		onFailure.invoke();
	}
}


@end