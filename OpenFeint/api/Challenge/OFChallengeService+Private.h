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

#import "OFChallengeService.h"

@interface OFChallengeService (Private)


////////////////////////////////////////////////////////////
///
/// getChallengeToUserAndShowNotification
/// 
/// @param challengeToUserId	the id of the OFChallengeToUser to retrieve
///
/// @note						Gets the OFChallengeToUser with challengeToUserId and displays an OFNotification
///
////////////////////////////////////////////////////////////
+(void)getChallengeToUserAndShowNotification:(NSString*)challengeToUserId;

////////////////////////////////////////////////////////////
///
/// getChallengeToUserAndShowDetailView
/// 
/// @param challengeToUserId	the id of the OFChallengeToUser to retrieve
///
/// @note						Gets the OFChallengeToUser with challengeToUserId and displays a detail view. 
///								This gets called when a challenge is started through a push notification.
///
////////////////////////////////////////////////////////////
+(void)getChallengeToUserAndShowDetailView:(NSString*)challengeToUserId;

////////////////////////////////////////////////////////////
///
/// getSentChallengesForLocalUserAndLocalApplication
/// 
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a list of sent OFChallengeToUsers send by the local user for the current application.
///
////////////////////////////////////////////////////////////
+(void)getSentChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
											  onSuccess:(OFDelegate const&)onSuccess 
											  onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getCompletedChallengesForLocalUserAndLocalApplication
/// 
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a list of completed OFChallengeToUsers by the local user for the current application.
///
////////////////////////////////////////////////////////////
+(void)getCompletedChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
												   onSuccess:(OFDelegate const&)onSuccess 
												   onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getPendingChallengesForLocalUserAndApplication
/// 
/// @param clientApplicationId	The resource id for which to retrieve any pending challenges
/// @param pageIndex			1 based page index
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a list of pending OFChallengeToUsers for the local user and the passed in application
///
////////////////////////////////////////////////////////////
+(void)getPendingChallengesForLocalUserAndApplication:(NSString*)clientApplicationId
											pageIndex:(NSUInteger)pageIndex
											onSuccess:(OFDelegate const&)onSuccess 
											onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getPendingChallengesForLocalUserAndLocalApplication
/// 
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a list of pending OFChallengeToUsers for the local user and application
///
////////////////////////////////////////////////////////////
+(void)getPendingChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
												 onSuccess:(OFDelegate const&)onSuccess 
												 onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getPendingChallengesForLocalUserAndLocalApplication
/// 
/// @param clientApplicationId	The resource id for which to retrieve any pending challenges. Nil for the current client application.
/// @param pageIndex			1 based page index
/// @param comparedToUserId		The resource id of a user who you are comparing with. Only pending challenges between 
///								the local user and this user will be returned.
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a list of pending OFChallengeToUsers for the local user and application
///
////////////////////////////////////////////////////////////
+(void)getPendingChallengesForLocalUserAndApplication:(NSString*)clientApplicationId
											pageIndex:(NSUInteger)pageIndex
										  comparedToUserId:(NSString*)comparedToUserId
												 onSuccess:(OFDelegate const&)onSuccess 
												 onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getUsersWhoReceivedChallengeWithId
/// 
/// @param challengeId			The resource id of the OFChallenge which recipients will be retrieved
/// @param clientApplicationId	The resourceId of the client application the challenge belongs to. Nil for local application
/// @param pageIndex			1 based page index
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with OFChallengeToUsers.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a paginated list of OFChallengeToUsers for a given challenge
///
////////////////////////////////////////////////////////////
+(void)getUsersWhoReceivedChallengeWithId:(NSString*)challengeId
					  clientApplicationId:(NSString*)clientApplicationId
								pageIndex:(NSUInteger)pageIndex
								onSuccess:(OFDelegate const&)onSuccess
								onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getUsersToChallenge
/// 
/// @param instigatingChallengerId	The resource id of the OFChallengeToUSer which the call is in response to. The sender of this challenge
///									will be separated out in his own section
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns the local users friends (OFUsers) with the instigating challenger separated out in his own section if there is one
///
////////////////////////////////////////////////////////////
+ (void)getUsersToChallenge:(NSString*)instigatingChallengerId 
				  pageIndex:(NSUInteger)pageIndex
				  onSuccess:(OFDelegate const&)onSuccess 
				  onFailure:(OFDelegate const&)onFailure;

@end
