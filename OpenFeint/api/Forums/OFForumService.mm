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

#import "OFForumService.h"
#import "OFHttpNestedQueryStringWriter.h"

#import "OFForumTopic.h"
#import "OFForumThread.h"
#import "OFForumPost.h"
#import "OFPaginatedSeries.h"
#import "OFTableSectionDescription.h"

#import "OFService+Private.h"
#import "OpenFeint+UserOptions.h"

@implementation OFForumService (Public)

+ (void)getTopicsForApplication:(NSString*)clientApplicationId onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	if ([clientApplicationId length] == 0)
	{
		clientApplicationId = [OpenFeint clientApplicationId];
	}
		
	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"client_applications/%@/forums.xml", clientApplicationId]
		withParameters:nil
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)getThreadsForTopic:(NSString*)topicId page:(NSInteger)pageNumber onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([topicId length] > 0, "Must have a topic id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageNumber);
	
	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"topics/%@/discussions.xml", topicId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)getPostsForThread:(NSString*)threadId page:(NSInteger)pageNumber onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([threadId length] > 0, "Must have a thread id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageNumber);

	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"discussions/%@/posts.xml", threadId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)postNewThreadInTopic:(NSString*)topicId subject:(NSString*)subject body:(NSString*)body onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([topicId length] > 0, "Must have a topic id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("discussion[subject]", subject);
	params->io("discussion[body]", body);
	
	[[self sharedInstance] 
		postAction:[NSString stringWithFormat:@"topics/%@/discussions.xml", topicId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)replyToThread:(NSString*)threadId body:(NSString*)body onSuccess:(OFDelegate const&)success onFailure:(OFDelegate const&)failure
{
	OFAssert([threadId length] > 0, "Must have a thread id");

	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("post[body]", body);

	[[self sharedInstance] 
		postAction:[NSString stringWithFormat:@"discussions/%@/posts.xml", threadId]
		withParameters:params
		withSuccess:success
		withFailure:failure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

@end
