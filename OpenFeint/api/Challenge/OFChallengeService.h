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
#import "OFChallengeToUser.h"

class OFHttpService;

@interface OFChallengeService : OFService
{
@private
	OFPointer<OFHttpService> mHttpService;
}

OPENFEINT_DECLARE_AS_SERVICE(OFChallengeService);

////////////////////////////////////////////////////////////
///
/// sendChallenge
/// 
/// @param challengeDefinitionId	The id of the definition as seen in the developer dashboard
/// @param challengeText			Should state what needs to be fullfilled to complete the challenge
/// @param challengeData			The data needed to replay the challenge
/// @param userMessage				A message entered by the user specific to this challenge. If the user does not enter
///									one a default message should be provided instead
/// @param hiddenText				Not used directly by OpenFeint. Use this if you want to display any extra data with the 
///									challenge when implementing your own UI
/// @param toUsers					Array of NSStrings with the id of the users who will receive the challenge (OFUsers resourceId property)
/// @param inResponseToChallenge	For multi attempt challenges only. This is an aptional parameter that is currently only used to track statistics
///									on whether a challenge was created directly or as a "re-challenge" after beating a challenge.
///
/// @note							If you call displaySendChallengeModal you should not call this function directly. It will be called by the modal.
///
////////////////////////////////////////////////////////////
+ (void)sendChallenge:(NSString*)challengeDefinitionId
		challengeText:(NSString*)challengeText 
		challengeData:(NSData*)challengeData
		  userMessage:(NSString*)userMessage
		   hiddenText:(NSString*)hiddenText
			  toUsers:(NSArray*)userIds 
inResponseToChallenge:(NSString*)instigatingChallengeId
			onSuccess:(OFDelegate const&)onSuccess 
			onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// submitChallengeResult
/// 
/// @param challengeToUserId	The resourceId of the OFChallengeToUser that initiated the challenge.
/// @param challengeResult		OFChallengeResult enum with either win, lose or tie
/// @param resultDescription	The result description will be prefixed by either the recipients name or You if it's the local
///								player whenever displayed. The result description should not state if the recipient won or lost
///								but contain the statistics of his attempt. 
///								Example: "beat 30 monsters" will turn into "You beat 30 monsters" and will be display next to a icon for win or lose
///
/// @note						This should be called before you call displayChallengeCompletedModal
///
////////////////////////////////////////////////////////////
+ (void)submitChallengeResult:(NSString*)challengeToUserId
					   result:(OFChallengeResult)challengeResult
			resultDescription:(NSString*)resultDescription
					onSuccess:(OFDelegate const&)onSuccess 
					onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// displaySendChallengeModal
/// 
/// @param challengeDefinitionId		The id of the definition as seen in the developer dashboard
/// @param challengeText				Should state what needs to be fullfilled to complete the challenge
/// @param challengeData				The data needed to replay the challenge
///
/// @note								displaySendChallengeModal calls sendChallenge
///
////////////////////////////////////////////////////////////
+ (void)displaySendChallengeModal:(NSString*)challengeDefinitionId
					challengeText:(NSString*)challengeText 
					challengeData:(NSData*)challengeData;


////////////////////////////////////////////////////////////
///
/// displayChallengeCompletedModal
/// 
/// @param OFChallengeToUser		The OFChallengeToUser that was passed in when the challenge was created
/// @param resultData				Only used for multiAttempt challenges. The data needed to send the challenge result out as a new challenge
/// @param challengeResult			OFChallengeResult enum with either win, lose or tie
/// @param resultDescription		If the result description contains %@ it will be replaced with You for the local user and the name of other users.
///									The result description should not state if the recipient won or lost but contain the statistics of his attempt. 
///									Example: "%@ beat 30 monsters" will turn into "You beat 30 monsters" (for the local user) and will be display next to a icon for win or lose
/// @param reChallengeDescription	If the challenge result is sent out as a new challenge (multi attempt only), this will be the description for
///									the new challenge. Should be formatted the same way as challengeText in sendChallenge
///
/// @note							Call submitChallengeResult before calling this.	If the user turns off the game during the challenge you must serialize 
///									the OFChallengeToUser as its used to display the completion modal. Serialize it to and from disc by calling 
///									writeChallengeToUserToFile or readChallengeToUserFromFile.
///
////////////////////////////////////////////////////////////
+ (void)displayChallengeCompletedModal:(OFChallengeToUser*)userChallenge
							resultData:(NSData*)resultData
								result:(OFChallengeResult)result
					 resultDescription:(NSString*)resultDescription
				reChallengeDescription:(NSString*)reChallengeDescription;

////////////////////////////////////////////////////////////
///
/// downloadChallengeData
/// 
/// @param challengeDataUrl		The url of the blob (OFChallengeToUser's challengeDataUrl property)
/// 
/// @note						The data is passed into the success delegate as NSData.
///								You should never have to call this function directly unless you implement your own UI.
///
////////////////////////////////////////////////////////////
+(void)downloadChallengeData:(NSString*)challengeDataUrl
				   onSuccess:(OFDelegate const&)onSuccess
				   onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeToUserWithId
/// 
/// @param challengeToUserId	The resouceId of the OFChallengeToUser to download
///
/// @note						The success delegate gets passed a OFPaginatedSeries that contains the OFChallengeToUser
///								You should never have to call this function directly unless you implement your own UI.
///
////////////////////////////////////////////////////////////
+(void)getChallengeToUserWithId:(NSString*)challengeToUserId
					  onSuccess:(OFDelegate const&)onSuccess
					  onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// rejectChallenge
/// 
/// @param challengeToUserId	The name of the file to read the data from
/// @param onSuccess			Delegate is called without parameters
/// @param onFailure			Delegate is called without parameters
///
/// @note						A rejected challenge will no longer appear in the pending challenges list
///
////////////////////////////////////////////////////////////
+ (void)rejectChallenge:(NSString*)challengeToUserId
							onSuccess:(OFDelegate const&)onSuccess
							onFailure:(OFDelegate const&)onFailure;


////////////////////////////////////////////////////////////
///
/// writeChallengeToUserToFile
/// 
/// @param fileName				The name of the file to write the data to
/// @param challengeToUser		The OFChallengeToUser to serialize to the file
///
////////////////////////////////////////////////////////////
+ (void)writeChallengeToUserToFile:(NSString*)fileName challengeToUser:(OFChallengeToUser*)challengeToUser;

////////////////////////////////////////////////////////////
///
/// readChallengeToUserFromFile
/// 
/// @param fileName				The name of the file to read the data from
///
/// @return OFChallengeToUser	The  OFChallengeToUser deserialized from the file
///
////////////////////////////////////////////////////////////
+ (OFChallengeToUser*)readChallengeToUserFromFile:(NSString*)fileName;

////////////////////////////////////////////////////////////
///
/// getChallengeHistoryAcrossAllTypes
/// 
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFChallengeToUsers and OFChallenges.
/// @param onFailure	Delegate is called without parameters
///
/// @note				Returns a paginated list of received challenges (OFChallengeToUsers) and send challenges (OFChallenge) in
///						chronological order. Whenever a user responds to a sent challenge it's timestamp is updated so it
///						shows up at the top of the list. Challenges belonging to all challenge definitions are mixed.
///
////////////////////////////////////////////////////////////
+ (void)getChallengeHistoryAcrossAllTypes:(NSUInteger)pageIndex
								onSuccess:(OFDelegate const&)onSuccess 
								onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeHistoryForType
/// 
/// @param challengeDefinitionId	The resource id of the OFChallengeDefinition for which to retrieve the challenge history
/// @param clientApplicationId		The resource id of the cleint application for which to retrieve the challenge history. Nil for local application.
/// @param pageIndex				1 based page index
/// @param onSuccess				Delegate is passed an OFPaginatedSeries with OFChallengeToUsers and OFChallenges.
/// @param onFailure				Delegate is called without parameters
///
/// @note							Returns a paginated list of received challenges (OFChallengeToUsers) and send challenges (OFChallenge) in
///									chronological order belonging to the passed in challenge definition. Whenever a user responds to a sent challenge 
///									it's timestamp is updated so it	shows up at the top of the list.
///
////////////////////////////////////////////////////////////
+ (void)getChallengeHistoryForType:(NSString*)challengeDefinitionId
			   clientApplicationId:(NSString*)clientApplicationId			   
						 pageIndex:(NSInteger)pageIndex
						 onSuccess:(OFDelegate const&)onSuccess 
						 onFailure:(OFDelegate const&)onFailure;

////////////////////////////////////////////////////////////
///
/// getChallengeHistoryForType
/// 
/// @param challengeDefinitionId	The resource id of the OFChallengeDefinition for which to retrieve the challenge history
/// @param clientApplicationId		The resource id of the cleint application for which to retrieve the challenge history. Nil for local application.
/// @param pageIndex				1 based page index
/// @param comparedToUserId			The resource id of a user who you are comparing with. Only challenges between 
///									the local user and this user will be returned.
/// @param onSuccess				Delegate is passed an OFPaginatedSeries with OFChallengeToUsers and OFChallenges.
/// @param onFailure				Delegate is called without parameters
///
/// @note							Returns a paginated list of received challenges (OFChallengeToUsers) and send challenges (OFChallenge) in
///									chronological order belonging to the passed in challenge definition. Whenever a user responds to a sent challenge 
///									it's timestamp is updated so it	shows up at the top of the list.
///
////////////////////////////////////////////////////////////
+ (void)getChallengeHistoryForType:(NSString*)challengeDefinitionId
			   clientApplicationId:(NSString*)clientApplicationId
						 pageIndex:(NSInteger)pageIndex
				  comparedToUserId:(NSString*)comparedToUserId
						 onSuccess:(OFDelegate const&)onSuccess 
						 onFailure:(OFDelegate const&)onFailure;
@end