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

#import "OFSubscriptionService+Private.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"

#import "OFSubscription.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFSubscriptionService);

@implementation OFSubscriptionService

OPENFEINT_DEFINE_SERVICE(OFSubscriptionService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFSubscription getResourceName], [OFSubscription class]);
}

+ (void)getSubscriptionsPage:(NSUInteger)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", oneBasedPageNumber);

	[[self sharedInstance] 
		getAction:@"subscriptions.xml"
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

@end
