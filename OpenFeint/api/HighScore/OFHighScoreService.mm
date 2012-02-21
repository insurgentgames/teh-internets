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
#import "OFHighScoreService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFHighScore.h"
#import "OFLeaderboard.h"
#import "OFNotificationData.h"
#import "OFHighScoreService+Private.h"
#import "OFDelegateChained.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFReachability.h"
#import "OFUser.h"
#import "OFNotification.h"

#define kDefaultPageSize 25

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFHighScoreService);

@implementation OFHighScoreService

OPENFEINT_DEFINE_SERVICE(OFHighScoreService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFHighScore getResourceName], [OFHighScore class]);
}

+ (OFRequestHandle*) getPage:(NSInteger)pageIndex forLeaderboard:(NSString*)leaderboardId friendsOnly:(BOOL)friendsOnly onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	return [OFHighScoreService getPage:pageIndex forLeaderboard:leaderboardId friendsOnly:friendsOnly silently:NO onSuccess:onSuccess onFailure:onFailure];
}

+ (OFRequestHandle*) getPage:(NSInteger)pageIndex forLeaderboard:(NSString*)leaderboardId friendsOnly:(BOOL)friendsOnly silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	return [OFHighScoreService getPage:pageIndex
				 forLeaderboard:leaderboardId
			   comparedToUserId:nil
					friendsOnly:friendsOnly
					   silently:silently
					  onSuccess:onSuccess
					  onFailure:onFailure];
}

+ (OFRequestHandle*) getPage:(NSInteger)pageIndex 
  forLeaderboard:(NSString*)leaderboardId 
comparedToUserId:(NSString*)comparedToUserId 
	 friendsOnly:(BOOL)friendsOnly
		silently:(BOOL)silently
	   onSuccess:(const OFDelegate&)onSuccess 
	   onFailure:(const OFDelegate&)onFailure
{
	return [OFHighScoreService 
		getPage:pageIndex 
		pageSize:kDefaultPageSize 
		forLeaderboard:leaderboardId 
		comparedToUserId:comparedToUserId
		friendsOnly:friendsOnly 
		silently:silently
		onSuccess:onSuccess 
		onFailure:onFailure];
}

+ (OFRequestHandle*) getPage:(NSInteger)pageIndex pageSize:(NSInteger)pageSize forLeaderboard:(NSString*)leaderboardId comparedToUserId:(NSString*)comparedToUserId friendsOnly:(BOOL)friendsOnly silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("leaderboard_id", leaderboardId);
	params->io("page", pageIndex);
	params->io("page_size", pageSize);
	
	if (friendsOnly)
	{
		bool friendsLeaderboard = true;
		OFRetainedPtr<NSString> followerId = @"me";
		params->io("friends_leaderboard", friendsLeaderboard);
		params->io("follower_id", followerId);
	}
	
	if (comparedToUserId && [comparedToUserId length] > 0)
	{
		params->io("compared_user_id", comparedToUserId);
	}
	
	OFActionRequestType requestType = silently ? OFActionRequestSilent : OFActionRequestForeground;
	
	return [[self sharedInstance] 
	 getAction:@"client_applications/@me/high_scores.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:requestType
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded High Scores"]];
}

+ (void) getLocalHighScores:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService getHighScoresLocal:leaderboardId onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getPageWithLoggedInUserWithPageSize:(NSInteger)pageSize forLeaderboard:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("leaderboard_id", leaderboardId);	
	params->io("near_user_id", @"me");
	params->io("page_size", pageSize);
	
	[[self sharedInstance]
	 getAction:@"client_applications/@me/high_scores.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded High Scores"]];
}

+ (void) getPageWithLoggedInUserForLeaderboard:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService getPageWithLoggedInUserWithPageSize:kDefaultPageSize forLeaderboard:leaderboardId onSuccess:onSuccess onFailure:onFailure];
}

- (void)_onSetHighScore:(NSArray*)resources nextCall:(OFDelegateChained*)nextCall
{
	//NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	unsigned int highScoreCnt = [resources count];
	for (unsigned int i = 0; i < highScoreCnt; i++ )
	{
	OFHighScore* highScore = [resources objectAtIndex:i];
		[OFHighScoreService 
		 localSetHighScore:highScore.score
		 forLeaderboard:[NSString stringWithFormat:@"%d", highScore.leaderboardId]
		 forUser:highScore.user.resourceId
		 displayText:highScore.displayText
		 customData:highScore.customData
		 serverDate:[NSDate date]
	 	 addToExisting:NO];
	}
	[nextCall invoke];
}

+ (void) setHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService setHighScore:score withDisplayText:nil forLeaderboard:leaderboardId silently:NO onSuccess:onSuccess onFailure:onFailure];
}

+ (void) setHighScore:(int64_t)score forLeaderboard:(NSString*)leaderboardId silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{	
	[OFHighScoreService setHighScore:score withDisplayText:nil forLeaderboard:leaderboardId silently:silently onSuccess:onSuccess onFailure:onFailure];
}

+ (void) setHighScore:(int64_t)score withDisplayText:(NSString*)displayText forLeaderboard:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService setHighScore:score withDisplayText:displayText forLeaderboard:leaderboardId silently:NO onSuccess:onSuccess onFailure:onFailure];
}

+ (void) setHighScore:(int64_t)score withDisplayText:(NSString*)displayText forLeaderboard:(NSString*)leaderboardId silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService setHighScore:score withDisplayText:displayText withCustomData:nil forLeaderboard:leaderboardId silently:silently onSuccess:onSuccess onFailure:onFailure];
}

+ (void) setHighScore:(int64_t)score withDisplayText:(NSString*)displayText withCustomData:(NSString*)customData forLeaderboard:(NSString*)leaderboardId silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> leaderboardIdString = leaderboardId;
	params->io("leaderboard_id", leaderboardIdString);
	
	{
		OFISerializer::Scope high_score(params, "high_score");
		params->io("score", score);
		if (displayText)
		{
			params->io("display_text", displayText);
		}
		if (customData)
		{
			params->io("custom_data", customData);
		}

		CLLocation* location = [OpenFeint getUserLocation];
		if (location)
		{
			double lat = location.coordinate.latitude;
			double lng = location.coordinate.longitude;
			params->io("lat", lat);
			params->io("lng", lng);
		}
	}
	
	NSString* notificationText = nil;
	
    NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	BOOL shouldSubmit = YES;
	BOOL succeeded = [OFHighScoreService localSetHighScore:score forLeaderboard:leaderboardId forUser:lastLoggedInUser displayText:displayText customData:customData serverDate:nil addToExisting:NO shouldSubmit:&shouldSubmit];
	if (shouldSubmit)
	{
		if ([OpenFeint isOnline])
		{
			OFDelegate submitSuccessDelegate([self sharedInstance], @selector(_onSetHighScore:nextCall:));

			[[self sharedInstance]
				postAction:@"client_applications/@me/high_scores.xml"
				withParameters:params
				withSuccess:submitSuccessDelegate
				withFailure:OFDelegate()
				withRequestType:OFActionRequestSilent
				withNotice:nil];

			notificationText = @"New high score!";
		}
		else
		{
			notificationText = @"New high score! Saving locally.";
		}

		if (!silently)
		{
			OFNotificationData* notice = [OFNotificationData dataWithText:notificationText andCategory:kNotificationCategoryHighScore andType:kNotificationTypeSuccess];
			[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusSuccess andInputResponse:nil];
		}
	}
	
	if (succeeded)
		onSuccess.invoke();
	else
		onFailure.invoke();
}
/*
+ (void) queueHighScore:(int64_t)score withDisplayText:(NSString*)displayText forLeaderboard:(NSString*)leaderboardId silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
    NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	[OFHighScoreService localSetHighScore:score forLeaderboard:leaderboardId forUser:lastLoggedInUser displayText:displayText serverDate:nil addToExisting:NO];

	if (!silently)
	{
		OFNotificationData* notice = [OFNotificationData dataWithText:@"Saved High Score" andCategory:kNotificationCategoryLeaderboard andType:kNotificationTypeSuccess];
		[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusSuccess andInputResponse:nil];
	}
	
}

+ (void) sendQueuedHighScores:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	NSString* lastLoggedInUser = [OpenFeint lastLoggedInUserId];
	[OFHighScoreService sendPendingHighScores:lastLoggedInUser silently:silently onSuccess:onSuccess onFailure:onFailure];
}

*/

+ (void) batchSetHighScores:(OFHighScoreBatchEntrySeries&)highScoreBatchEntrySeries onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure optionalMessage:(NSString*)submissionMessage
{
	[OFHighScoreService batchSetHighScores:highScoreBatchEntrySeries silently:NO onSuccess:onSuccess onFailure:onFailure optionalMessage:submissionMessage];
}

+ (void) batchSetHighScores:(OFHighScoreBatchEntrySeries&)highScoreBatchEntrySeries silently:(BOOL)silently onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure optionalMessage:(NSString*)submissionMessage
{
	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->serialize("high_scores", "entry", highScoreBatchEntrySeries);

	CLLocation* location = [OpenFeint getUserLocation];
	if (location)
	{
		double lat = location.coordinate.latitude;
		double lng = location.coordinate.longitude;
		params->io("lat", lat);
		params->io("lng", lng);
	}
	
	OFNotificationData* notice = [OFNotificationData dataWithText:submissionMessage ? submissionMessage : @"Submitted High Scores" 
													  andCategory:kNotificationCategoryHighScore
														  andType:kNotificationTypeSubmitting];
	[[self sharedInstance]
	 postAction:@"client_applications/@me/high_scores.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:(silently ? OFActionRequestSilent : OFActionRequestBackground)
	 withNotice:notice];
}

+ (void) getAllHighScoresForLoggedInUser:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure optionalMessage:(NSString*)submissionMessage
{
	OFNotificationData* notice = [OFNotificationData dataWithText:submissionMessage ? submissionMessage : @"Downloaded High Scores" 
													  andCategory:kNotificationCategoryHighScore
														  andType:kNotificationTypeDownloading];
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> me = @"me";
	bool acrossLeaderboards = true;
	params->io("across_leaderboards", acrossLeaderboards);
	params->io("user_id", me);
	
	[[self sharedInstance] 
	 getAction:@"client_applications/@me/high_scores.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:notice];
}

+ (void) getHighScoresFromLocation:(CLLocation*)origin radius:(int)radius pageIndex:(NSInteger)pageIndex forLeaderboard:(NSString*)leaderboardId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFHighScoreService getHighScoresFromLocation:origin radius:radius pageIndex:pageIndex forLeaderboard:leaderboardId userMapMode:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getHighScoresFromLocation:(CLLocation*)origin radius:(int)radius pageIndex:(NSInteger)pageIndex forLeaderboard:(NSString*)leaderboardId userMapMode:(NSString*)userMapMode onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	bool geolocation = true;
	params->io("geolocation", geolocation);

	params->io("page", pageIndex);
	
	params->io("leaderboard_id", leaderboardId);
	if (radius != 0)
		params->io("radius", radius);
	
	if (origin)
	{
		CLLocationCoordinate2D coord = origin.coordinate;
		params->io("lat", coord.latitude);
		params->io("lng", coord.longitude);
	}
	
	if (userMapMode)
	{
		params->io("map_me", userMapMode);
	}

	[[self sharedInstance] 
	 getAction:@"client_applications/@me/high_scores.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:nil];	
}

@end

