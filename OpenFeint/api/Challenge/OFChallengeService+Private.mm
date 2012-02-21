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
#import "OFChallengeService+Private.h"
#import "OFChallenge.h"
#import "OFChallengeToUser.h"
#import "OFService+Private.h"
#import "OFControllerLoader.h"
#import "OpenFeint+Private.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFChallengeDetailController.h"
#import "OFInputResponseOpenDashboard.h"
#import "OFNotification.h"
#import "OpenFeint+Dashboard.h"
#import "OFDelegateChained.h"
#import "OpenFeint+UserOptions.h"

@implementation OFChallengeService (Private)

//download challenge to user - and launch OFNotification
+(void)getChallengeToUserAndShowNotification:(NSString*)challengeToUserId
{
	OFDelegate success([self sharedInstance], @selector(_onChallengeReceivedNotification:));
	OFDelegate failure([self sharedInstance], @selector(_onChallengeReceivedFailed));
	
	[self getChallengeToUserWithId:challengeToUserId onSuccess:success onFailure:failure];
}

- (void)_getChallengeToUserAndShowDetailView:(NSString*)challengeToUserId
{
	if ([OpenFeint isOnline])
	{
		OFDelegate success(self, @selector(_onChallengeReceivedDetailView:));
		OFDelegate failure(self, @selector(_onChallengeReceivedFailed));
		[OFChallengeService getChallengeToUserWithId:challengeToUserId onSuccess:success onFailure:failure];
	}
	else
	{
		// When the user hasn't logged in yet we gotta do some trickery so we wait for the bootstrap and then call ourselves again
		// The reason for _chainedGetChallengeToUserAndShowDetailView is that user params are always passed as the second argument
		OFDelegate success(self, @selector(_chainedGetChallengeToUserAndShowDetailView:challengeId:), challengeToUserId);
		OFDelegate failure(self, @selector(_onChallengeReceivedFailed));
		[OpenFeint addBootstrapDelegates:success onFailure:failure];
	}
}

- (void)_chainedGetChallengeToUserAndShowDetailView:(OFDelegateChained*)next challengeId:(NSString*)challengeToUserId
{
	[self _getChallengeToUserAndShowDetailView:challengeToUserId];
	[next invoke];
}

//downloads challenge to user - and launch detail view
+(void)getChallengeToUserAndShowDetailView:(NSString*)challengeToUserId
{
	[[self sharedInstance] _getChallengeToUserAndShowDetailView:challengeToUserId];
}

//download sent challenges
+(void)getSentChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
											  onSuccess:(OFDelegate const&)onSuccess 
											  onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageIndex);
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenges.xml"]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Challenge Information"]];
}

//download completed challenges
+(void)getCompletedChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
												   onSuccess:(OFDelegate const&)onSuccess 
												   onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool complete = true;
	params->io("complete", complete);
	params->io("page", pageIndex);
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenges_users.xml"]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Challenge Information"]];
}

+(void)getPendingChallengesForLocalUserAndApplication:(NSString*)clientApplicationId
											pageIndex:(NSUInteger)pageIndex
											onSuccess:(OFDelegate const&)onSuccess 
											onFailure:(OFDelegate const&)onFailure
{
	[OFChallengeService getPendingChallengesForLocalUserAndApplication:clientApplicationId 
															 pageIndex:pageIndex 
													  comparedToUserId:nil
															 onSuccess:onSuccess onFailure:onFailure];
}

+(void)getPendingChallengesForLocalUserAndLocalApplication:(NSUInteger)pageIndex
												 onSuccess:(OFDelegate const&)onSuccess 
												 onFailure:(OFDelegate const&)onFailure
{
	[OFChallengeService getPendingChallengesForLocalUserAndApplication:nil
															 pageIndex:pageIndex
															 onSuccess:onSuccess
															 onFailure:onFailure];
	
}

+(void)getPendingChallengesForLocalUserAndApplication:(NSString*)clientApplicationId
											pageIndex:(NSUInteger)pageIndex
									 comparedToUserId:(NSString*)comparedToUserId
											onSuccess:(OFDelegate const&)onSuccess 
											onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool incomplete = true;
	bool viewed = true;
	params->io("incomplete", incomplete);
	params->io("page", pageIndex);
	params->io("mark_as_viewed",viewed);
	if (clientApplicationId && [clientApplicationId length] != 0)
	{
		params->io("client_application_id", clientApplicationId);
	}
	if (comparedToUserId && [comparedToUserId length] != 0)
	{
		params->io("compared_user_id", comparedToUserId);
	}
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenges_users.xml"]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Challenge Information"]];
}

//downloads a list of challenge to users with challenge id
+(void)getUsersWhoReceivedChallengeWithId:(NSString*)challengeId
					  clientApplicationId:(NSString*)clientApplicationId
								pageIndex:(NSUInteger)pageIndex
								onSuccess:(OFDelegate const&)onSuccess
								onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("challenge_id", challengeId);
	params->io("client_application_id", clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId]);
	params->io("page", pageIndex);
	
	[[self sharedInstance] 
	 getAction:@"challenges_users.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)getUsersToChallenge:(NSString*)instigatingChallengerId 
				  pageIndex:(NSUInteger)pageIndex
				  onSuccess:(OFDelegate const&)onSuccess 
				  onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageIndex);
	params->io("user_id", @"me");
	params->io("scope", @"people-of-interest");
	params->io("with_client_application", [OpenFeint clientApplicationId]);
	params->io("not_sectioned", @"yes");
	if (instigatingChallengerId)
	{
		params->io("challenger_user_id", instigatingChallengerId);
	}

	[[self sharedInstance] 
	 getAction:@"users.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Friends"]];

}

#pragma mark Callbacks
//onsuccess for downloadChallengeWithId-launches challengeNotification in game
- (void)_onChallengeReceivedNotification:(OFPaginatedSeries*)resources
{
	OFChallengeToUser* newChallenge = [resources.objects objectAtIndex:0];
	
	//launch OFChallengeNotification
	OFChallengeDetailController *detailController = (OFChallengeDetailController*)OFControllerLoader::load(@"ChallengeDetail");
	//detailController.userChallenge = newChallenge;
	detailController.challengeId = newChallenge.challenge.resourceId;
	OFNotificationInputResponse* inputResponse = [[[OFInputResponseOpenDashboard alloc] 
												   initWithTab:OpenFeintDashBoardTabNowPlaying 
												   andController:detailController] autorelease];
	
	[[OFNotification sharedInstance] showChallengeNotice:newChallenge withInputResponse:inputResponse];
}

- (void)_onChallengeReceivedDetailView:(OFPaginatedSeries*)resources
{
	if ([resources count] == 0)
	{
		return;
	}
	OFChallengeToUser* newChallenge = [resources.objects objectAtIndex:0];
	UIViewController* listController = OFControllerLoader::load(@"ChallengeList");
	OFChallengeDetailController *detailController = (OFChallengeDetailController*)OFControllerLoader::load(@"ChallengeDetail");
	detailController.challengeId = newChallenge.challenge.resourceId;
	[OpenFeint launchDashboardWithDelegate:nil tabControllerName:OpenFeintDashBoardTabNowPlaying andControllers:[NSArray arrayWithObjects:listController, detailController, nil]];
}

//onfailure for downloadChallengeWithId
- (void)_onChallengeReceivedFailed
{
	[[OFNotification sharedInstance] showBackgroundNotice:[OFNotificationData dataWithText:@"Error downloading challenge." 
																			   andCategory:kNotificationCategoryChallenge
																				   andType:kNotificationTypeError] 
												andStatus:OFNotificationStatusFailure 
										 andInputResponse:nil];
	OFLog(@"OFChallengeService challenge data download failed!");
}

@end
