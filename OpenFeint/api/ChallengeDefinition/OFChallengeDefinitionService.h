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

#import "OFService.h"

@interface OFChallengeDefinitionService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFChallengeDefinitionService);

////////////////////////////////////////////////////////////
///
/// getIndexOnSuccess
/// 
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFChallengeDefinitions.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a paginated list of OFChallengeDefinitions. 
///
////////////////////////////////////////////////////////////
+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeDefinitionWithId
/// 
/// @param challengeDefinitionId	The resource id of the OFChallengeDefinition to return
/// @param onSuccess				Delegate is passed an OFPaginatedSeries with the requested OFChallengeDefinition.
/// @param onFailure				Delegate is called without parameters
///
/// @note							Returns the OFChallengeDefinition with the passed in resource id. 
///
////////////////////////////////////////////////////////////
+ (void)getChallengeDefinitionWithId:(NSString*)challengeDefinitionId 
						   onSuccess:(const OFDelegate&)onSuccess
						   onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeDefinitionStatsForLocalUser
/// 
/// @param pageIndex			1 based page index
/// @param clientApplicationId	ResourceId of the client application which challenge definitions to return. Nil means local application
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with OFChallengeDefinitionStats.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a paginated list of OFChallengeDefinitionStats filled out with stats for the local user. 
///
////////////////////////////////////////////////////////////
+ (void)getChallengeDefinitionStatsForLocalUser:(NSUInteger)pageIndex
							clientApplicationId:(NSString*)clientApplicationId
									  onSuccess:(OFDelegate const&)onSuccess 
									  onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeDefinitionStatsForLocalUser
/// 
/// @param pageIndex			1 based page index
/// @param clientApplicationId	ResourceId of the client application which challenge definitions to return. Nil means local application
/// @param comparedToUserId		If provided all the OFChallengeDefinitionStats will also contain stats for this user. 
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with OFChallengeDefinitionStats.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a paginated list of OFChallengeDefinitionStats filled out with stats for the local user. 
///
////////////////////////////////////////////////////////////
+ (void)getChallengeDefinitionStatsForLocalUser:(NSUInteger)pageIndex
							clientApplicationId:(NSString*)clientApplicationId
							   comparedToUserId:(NSString*)comparedToUserId
									  onSuccess:(OFDelegate const&)onSuccess 
									  onFailure:(OFDelegate const&)onFailure;

@end