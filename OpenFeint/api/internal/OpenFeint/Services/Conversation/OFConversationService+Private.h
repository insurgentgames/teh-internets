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

#pragma once

#import "OFService.h"

@interface OFConversationService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFConversationService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources;

+ (void)startConversationWithUser:(NSString*)userId onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure;
+ (void)postMessage:(NSString*)message toConversation:(NSString*)conversationId onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure;
+ (void)getConversationHistory:(NSString*)conversationId page:(NSUInteger)oneBasedPageNumber onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure;

@end
