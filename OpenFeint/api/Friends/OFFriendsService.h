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

@interface OFFriendsService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFFriendsService);

////////////////////////////////////////////////////////////
///
/// getUsersFollowedByUser
/// 
/// @param userId		The id of the user who's "friends" to retrieve. OFUsers resourceId
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Users followed by a users are essentially his "friends".
///
////////////////////////////////////////////////////////////
+ (void)getUsersFollowedByUser:(NSString*)userId pageIndex:(NSInteger)pageIndex onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

// Same as getUsersFollowedByUser but uses the local user instead of passing one in. Essentially returns the local users friends.
+ (void)getUsersFollowedByLocalUser:(NSInteger)pageIndex onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// getAllUsersFollowedByLocalUserAlphabetical
/// 
/// @param userId		The id of the user who's "friends" to retrieve. OFUsers resourceId
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFUsers.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a list of ALL people followed by a user sorted into an alphabetical list
///						of resource sections, one for each letter that has at least one resource in it (no empty sections).
///						This may be an expensive call if the user follows many people
///
////////////////////////////////////////////////////////////
+ (void)getAllUsersFollowedByUserAlphabetical:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
// Same as getAllUsersFollowedByUserAlphabetical but uses the local user instead of passing one in.
+ (void)getAllUsersFollowedByLocalUserAlphabetical:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
// Same as getAllUsersFollowedByUserAlphabetical but only returns the users who have the application specified by applicationId
+ (void)getAllUsersWithApp:(NSString*)applicationId followedByUser:(NSString*)userId alphabeticalOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// isLocalUserFollowingAnyone
/// 
/// @param onSuccess	Delegate is passed an NSNumber with a boolValue
/// @param onFailure	Delegate is called without parameters
///
////////////////////////////////////////////////////////////
+ (void)isLocalUserFollowingAnyone:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// getUsersWithAppFollowedByUser
/// 
/// @param applicationId	The id of the application the users must have to be included in the list. (OFPlayedGame clientApplicationId)
/// @param userId			The id of the user who's friends to retrieve (OFUser resourceId)
/// @param pageIndex		1 based page index
/// @param onSuccess		Delegate is passed an OFPaginatedSeries with OFGamePlayers which contain the users and the users gamerscore for this specific game.
/// @param onFailure		Delegate is called without parameters
///
/// @note					Returns all the users (OFGamePlayers) who are followed by a user and also own the specified application
///
////////////////////////////////////////////////////////////
+ (void)getUsersWithAppFollowedByUser:(NSString*)applicationId followedByUser:(NSString*)userId pageIndex:(NSInteger)pageIndex onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

// Same as getUsersWithAppFollowedByLocalUser but uses local user instead of passing in a user
+ (void)getUsersWithAppFollowedByLocalUser:(NSString*)applicationId pageIndex:(NSInteger)pageIndex onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// getUsersFollowingUser
/// 
/// @param userId						The id of the user who's followers to retrieve (OFUser resourceId)
/// @param excludeUsersFollowedByTarget If true, only return users following the passed in user who aren't followed by the passed in user in return
/// @param pageIndex					1 based page index
/// @param onSuccess					Delegate is passed an OFPaginatedSeries with OFUsers.
/// @param onFailure					Delegate is called without parameters
///
/// @note								Returns all the users following the specified user
///										You normally never need to care who's following someone. Only call this if you want to display them in a list somewhere.
///
////////////////////////////////////////////////////////////
+ (void)getUsersFollowingUser:(NSString*)userId 
 excludeUsersFollowedByTarget:(BOOL)excludeUsersFollowedByTarget
					pageIndex:(NSInteger)pageIndex 
					onSuccess:(const OFDelegate&)onSuccess 
					onFailure:(const OFDelegate&)onFailure;
 
// Same as getUsersFollowingUser but uses the local user instead of passing one in.
+ (void)getUsersFollowingLocalUser:(NSInteger)pageIndex 
						 excludeUsersFollowedByTarget:(BOOL)excludeUsersFollowedByTarget
						 onSuccess:(const OFDelegate&)onSuccess 
						 onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// makeLocalUserFollow
/// 
/// @param userId				The id ([OFUser resourceId]) of the user the local user should start following 
/// @param onSuccess			Delegate is called without parameters
/// @param onFailure			Delegate is called without parameters
///
////////////////////////////////////////////////////////////
+ (void)makeLocalUserFollow:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// makeLocalUserStopFollowing
/// 
/// @param userId				The id ([OFUser resourceId]) of the user the local user should stop following 
/// @param onSuccess			Delegate is called without parameters
/// @param onFailure			Delegate is called without parameters
///
////////////////////////////////////////////////////////////
+ (void)makeLocalUserStopFollowing:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

////////////////////////////////////////////////////////////
///
/// removeLocalUsersFollower
/// 
/// @param userId				The id ([OFUser resourceId]) of the follower that the local user wants to remove 
/// @param onSuccess			Delegate is called without parameters
/// @param onFailure			Delegate is called without parameters
///
////////////////////////////////////////////////////////////
+ (void)removeLocalUsersFollower:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

@end
