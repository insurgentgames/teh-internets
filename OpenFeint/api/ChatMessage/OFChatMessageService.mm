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
#import "OFChatMessageService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFChatMessage.h"
#import "OFPoller.h"
#import "OpenFeint+Private.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFChatMessageService);

@implementation OFChatMessageService

OPENFEINT_DEFINE_SERVICE(OFChatMessageService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFChatMessage getResourceName], [OFChatMessage class]);
}

- (void)registerPolledResources:(OFPoller*)poller
{
	[poller registerResourceClass:[OFChatMessage class]];
}

- (void) _onChatMessagesDiscovered:(NSNotification*)notification
{
	// citron note: Do Nothing. The table controller handles this on its own now
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	// citron note: The table controller will automagically get updates from the poller for the resource.
	//				This is redundent.
	onSuccess.invoke(nil);
}

+ (void) clearCacheAndPollNow
{
	[OpenFeint clearPollingCacheForClassType:[OFChatMessage class]];
	[OpenFeint forceImmediatePoll];
}

@end
