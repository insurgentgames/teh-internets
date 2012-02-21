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

@interface OFClientApplicationService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFClientApplicationService);

////////////////////////////////////////////////////////////
///
/// getPlayedGamesForUser
/// 
/// @param userId			The id of the user who's games to retrieve. OFUsers resourceId
/// @param withPage			1 based index of the page to retrieve
/// @param andCountPerPage	How many games to include in each page
/// @param onSuccess		Delegate is passed an OFPaginatedSeries with OFPlayedGames.
/// @param onFailure		Delegate is called without parameters
///
/// @note					The returned OFPlayedGames will contain stats for the passed in user. 
///							If the passed in user is not the local user the OFPlayedGames will also contain stats for the local user.
///
////////////////////////////////////////////////////////////
+ (void) getPlayedGamesForUser:(NSString*)userId withPage:(NSInteger)pageIndex andCountPerPage:(NSInteger)perPage onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getFavoriteGamesForUser
/// 
/// @param userId			The id of the user who's favorite games to retrieve. OFUsers resourceId
/// @param withPage			1 based index of the page to retrieve
/// @param andCountPerPage	How many games to include in each page
/// @param onSuccess		Delegate is passed an OFPaginatedSeries with OFPlayedGames.
/// @param onFailure		Delegate is called without parameters
///
/// @note					The returned OFPlayedGames will contain stats for the passed in user. 
///							If the passed in user is not the local user the OFPlayedGames will also contain stats for the local user.
///							Only games the passed in user has marked as favorite will be returned
///
////////////////////////////////////////////////////////////
+ (void) getFavoriteGamesForUser:(NSString*)userId withPage:(NSInteger)pageIndex andCountPerPage:(NSInteger)perPage onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getPlayedGamesForLocalUsersFriends
/// 
/// @param pageIndex		1 based index of the page to retrieve
/// @param onSuccess		Delegate is passed an OFPaginatedSeries with OFPlayedGames.
/// @param onFailure		Delegate is called without parameters
///
/// @note					Returns a paginated list of OFPlayedGames with all the games owned by the local users friends. 
///
////////////////////////////////////////////////////////////
+ (void) getPlayedGamesForLocalUsersFriends:(NSInteger)pageIndex onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getGameProfilePageInfo
/// 
/// @param clientApplicationId	The id of the client application to retrieve. Nil retrieves current application.
/// @param onSuccess		Delegate is passed an OFPaginatedSeries with an OFGameProfilePageInfo.
/// @param onFailure		Delegate is called without parameters
///
/// @note					Returns a paginates list with a OFGameProfilePageInfo that describes the features of a game.
///
////////////////////////////////////////////////////////////
+ (void) getGameProfilePageInfo:(NSString*)clientApplicationId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getGameProfilePageComparisonInfo
/// 
/// @param clientApplicationId	The id of the client application to retrieve. Nil retrieves current application.
/// @param comparedToUserId		The id of the user you're comparing against if any. If provided a OFGameProfilePageComparisonInfo is
///								returned instead of a OFGameProfilePageInfo
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with an OFGameProfilePageInfo.
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a paginates list with a OFGameProfilePageInfo or a OFGameProfilePageComparisonInfo
///								(depending on comparedToUserId) that describes the features of a game.
///
////////////////////////////////////////////////////////////
+ (void) getGameProfilePageComparisonInfo:(NSString*)clientApplicationId 
						 comparedToUserId:(NSString*)comparedToUserId 
								onSuccess:(OFDelegate const&)onSuccess 
								onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getPlayerReviewForGame
/// 
/// @param clientApplicationId	The id of the client application for which to retrieve a review. Nil retrieves current application.
/// @param userId				The id of the user who's review to retrieve
/// @param onSuccess			Delegate is passed an OFPaginatedSeries with a single OFPlayerReview (or none if the player hasn't written any).
/// @param onFailure			Delegate is called without parameters
///
/// @note						Returns a single review by the given player for the give application. The returned review may contain a rating without any text.
///
////////////////////////////////////////////////////////////
+ (void) getPlayerReviewForGame:(NSString*)clientApplicationId byUser:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;


@end