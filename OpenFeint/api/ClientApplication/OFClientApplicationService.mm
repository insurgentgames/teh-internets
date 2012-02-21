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
#import "OFClientApplicationService.h"
#import "OFService+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFHttpNestedQueryStringWriter.h"

#import "OFPlayedGame.h"
#import "OFUserGameStat.h"
#import "OFUser.h"
#import "OFGameProfilePageInfo.h"
#import "OFGameProfilePageComparisonInfo.h"
#import "OFPaginatedSeries.h"
#import "OFPlayerReview.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFClientApplicationService)

@implementation OFClientApplicationService

OPENFEINT_DEFINE_SERVICE(OFClientApplicationService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFPlayedGame getResourceName], [OFPlayedGame class]);
	namedResources->addResource([OFUserGameStat getResourceName], [OFUserGameStat class]);
	namedResources->addResource([OFUser getResourceName], [OFUser class]);
	namedResources->addResource([OFGameProfilePageInfo getResourceName], [OFGameProfilePageInfo class]);
	namedResources->addResource([OFGameProfilePageComparisonInfo getResourceName], [OFGameProfilePageComparisonInfo class]);
	namedResources->addResource([OFPlayerReview getResourceName], [OFPlayerReview class]);
}

+ (void) getPlayedGamesForUser:(NSString*)userId 
			 favoriteGamesOnly:(bool)favoriteGamesOnly
					  withPage:(NSInteger)pageIndex 
			   andCountPerPage:(NSInteger)perPage 
					 onSuccess:(OFDelegate const&)onSuccess 
					 onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageIndex);
	params->io("per_page", perPage);
	
	if (userId == nil || [userId isEqualToString:[OpenFeint lastLoggedInUserId]])
	{
		userId = @"me";
	}
	else
	{
		params->io("compared_to_user_id", @"me");
	}
	
	if (favoriteGamesOnly)
	{
		params->io("only_favorites", favoriteGamesOnly);
	}
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"profiles/%@/list_games", userId]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Game Information"]];
}

+ (void) getPlayedGamesForUser:(NSString*)userId withPage:(NSInteger)pageIndex andCountPerPage:(NSInteger)perPage onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	[OFClientApplicationService getPlayedGamesForUser:userId favoriteGamesOnly:false withPage:pageIndex andCountPerPage:perPage onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getFavoriteGamesForUser:(NSString*)userId withPage:(NSInteger)pageIndex andCountPerPage:(NSInteger)perPage onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	[OFClientApplicationService getPlayedGamesForUser:userId favoriteGamesOnly:true withPage:pageIndex andCountPerPage:perPage onSuccess:onSuccess onFailure:onFailure];
}

+ (void)getPlayedGamesInScope:(NSString*)scope page:(NSInteger)pageIndex onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("page", pageIndex);
	params->io("scope", scope);
	
	
	[[self sharedInstance] 
	 getAction:@"apps.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Game Information"]];
}

+ (void) getPlayedGamesForLocalUsersFriends:(NSInteger)pageIndex onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	[OFClientApplicationService getPlayedGamesInScope:@"people-of-interest" page:pageIndex onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getGameProfilePageInfo:(NSString*)clientApplicationId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	[OFClientApplicationService getGameProfilePageComparisonInfo:clientApplicationId comparedToUserId:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getGameProfilePageComparisonInfo:(NSString*)clientApplicationId 
						 comparedToUserId:(NSString*)comparedToUserId 
								onSuccess:(OFDelegate const&)onSuccess 
								onFailure:(OFDelegate const&)onFailure
{
	bool comparison = comparedToUserId && [comparedToUserId length] > 0;
	
	// if it's the local client application just immediately invoke success with a local profile page info
	OFGameProfilePageInfo* localProfile = [OpenFeint localGameProfileInfo];
	if (!comparison && ([clientApplicationId length] == 0 || [clientApplicationId isEqualToString:localProfile.resourceId]))
	{
		onSuccess.invoke([OFPaginatedSeries paginatedSeriesWithObject:localProfile]);
		return;
	}
	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool game_profile_page_info = true;
	params->io("game_profile_page_info", game_profile_page_info);
	
	if (comparison)
	{
		params->io("compared_user_id", comparedToUserId);
	}
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"apps/%@.xml", clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId]]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloading Game Information"]];
}

+ (void) getPlayerReviewForGame:(NSString*)clientApplicationId byUser:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	clientApplicationId = clientApplicationId ? clientApplicationId : [OpenFeint clientApplicationId];
	userId = userId ? userId : [OpenFeint lastLoggedInUserId];
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"client_applications/%@/users/%@.xml", clientApplicationId, userId]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloading"]];
}

@end