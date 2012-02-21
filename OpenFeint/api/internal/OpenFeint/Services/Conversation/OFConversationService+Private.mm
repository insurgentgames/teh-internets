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

#import "OFConversationService+Private.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"

#import "OFForumPost.h"
#import "OFConversation.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFConversationService);

@implementation OFConversationService

OPENFEINT_DEFINE_SERVICE(OFConversationService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFConversation getResourceName], [OFConversation class]);
	namedResources->addResource([OFForumPost getResourceName], [OFForumPost class]);
}

+ (void)startConversationWithUser:(NSString*)userId onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([userId length] > 0, "Must have a user id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("discussion[other_user_id]", userId);

	[[self sharedInstance] 
		postAction:@"discussions.xml"
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)postMessage:(NSString*)message toConversation:(NSString*)conversationId onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([conversationId length] > 0, "Must have a conversation id");
	OFAssert([message length] > 0, "Must have a message");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("post[body]", message);

	[[self sharedInstance] 
		postAction:[NSString stringWithFormat:@"discussions/%@/posts.xml", conversationId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)getConversationHistory:(NSString*)conversationId page:(NSUInteger)oneBasedPageNumber onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([conversationId length] > 0, "Must have a conversation id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", oneBasedPageNumber);

	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"discussions/%@/posts.xml", conversationId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

@end
