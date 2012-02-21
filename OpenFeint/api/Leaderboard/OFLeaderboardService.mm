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
#import "OFLeaderboardService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFLeaderboard.h"
#import "OFLeaderboardService+Private.h"
#import "OFReachability.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFLeaderboardService);

@implementation OFLeaderboardService

OPENFEINT_DEFINE_SERVICE(OFLeaderboardService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFLeaderboard getResourceName], [OFLeaderboard class]);
}

+ (OFNotificationData*)getDownloadNotification
{
	return [OFNotificationData dataWithText:@"Downloaded Leaderboards" andCategory:kNotificationCategoryLeaderboard andType:kNotificationTypeDownloading];
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFLeaderboardService getLeaderboardsForApplication:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getLeaderboardsComparisonWithUser:(NSString*)comparedToUserId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFLeaderboardService getLeaderboardsComparisonWithUser:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void)getLeaderboardsForApplication:(NSString*)applicationId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFLeaderboardService getLeaderboardsForApplication:applicationId comparedToUserId:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void)getLeaderboardsForApplication:(NSString*)applicationId comparedToUserId:(NSString*)comparedToUserId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	if ([OpenFeint isOnline]) 
	{
		OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
		if (applicationId == nil || [applicationId length] == 0)
		{
			applicationId = @"@me";
		}
		
		if (comparedToUserId && [comparedToUserId length] != 0)
		{
			params->io("compared_user_id", comparedToUserId);
		}
		
		[[self sharedInstance] 
		 getAction:[NSString stringWithFormat:@"client_applications/%@/leaderboards.xml", applicationId]
		 withParameters:params
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestForeground
		 withNotice:[OFLeaderboardService getDownloadNotification]];
	} else {
		[OFLeaderboardService getLeaderboardsLocal:onSuccess onFailure:onFailure];
	}
}

@end
