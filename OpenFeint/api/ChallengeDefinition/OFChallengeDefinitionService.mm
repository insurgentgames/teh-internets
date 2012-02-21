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
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionStats.h"
#import "OFChallengeDefinitionService.h"
#import "OpenFeint+UserOptions.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFChallengeDefinitionService)

@implementation OFChallengeDefinitionService

OPENFEINT_DEFINE_SERVICE(OFChallengeDefinitionService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFChallengeDefinition getResourceName], [OFChallengeDefinition class]);
	namedResources->addResource([OFChallengeDefinitionStats getResourceName], [OFChallengeDefinitionStats class]);
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[[self sharedInstance] 
			getAction:@"challenge_definitions.xml"
			withParameters:nil
			withSuccess:onSuccess
			withFailure:onFailure
			withRequestType:OFActionRequestSilent
			withNotice:nil];
}

+ (void)getChallengeDefinitionWithId:(NSString*)challengeDefinitionId 
						   onSuccess:(const OFDelegate&)onSuccess
						   onFailure:(const OFDelegate&)onFailure
{
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenge_definitions/%@.xml",challengeDefinitionId]
	 withParameters:nil
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)getChallengeDefinitionStatsForLocalUser:(NSUInteger)pageIndex
							clientApplicationId:(NSString*)clientApplicationId
									  onSuccess:(OFDelegate const&)onSuccess 
									  onFailure:(OFDelegate const&)onFailure
{
	[OFChallengeDefinitionService getChallengeDefinitionStatsForLocalUser:pageIndex
													  clientApplicationId:clientApplicationId
														 comparedToUserId:nil
																onSuccess:onSuccess
																onFailure:onFailure];
}

+ (void)getChallengeDefinitionStatsForLocalUser:(NSUInteger)pageIndex
							clientApplicationId:(NSString*)clientApplicationId
							   comparedToUserId:(NSString*)comparedToUserId
									  onSuccess:(OFDelegate const&)onSuccess 
									  onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool challenge_definition_stats = true;
	params->io("challenge_definition_stats", challenge_definition_stats);
	int per_page = 20;
	params->io("per_page", per_page);
	params->io("page", pageIndex);
	
	params->io("client_application_id", clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId]);
	
	if (comparedToUserId && [comparedToUserId length] > 0)
	{
		params->io("compared_user_id", comparedToUserId);
	}
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenge_definitions.xml"]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloading Challenge Information"]];
}

@end