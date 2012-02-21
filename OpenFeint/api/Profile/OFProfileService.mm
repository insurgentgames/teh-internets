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
#import "OFProfileService.h"
#import "OFService+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFHttpNestedQueryStringWriter.h"

#import "OFPlayedGame.h"
#import "OFGamerscore.h"
#import "OFUserGameStat.h"
#import "OFUser.h"
#import "OFUsersCredential.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFProfileService)

@implementation OFProfileService

OPENFEINT_DEFINE_SERVICE(OFProfileService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFPlayedGame getResourceName], [OFPlayedGame class]);
	namedResources->addResource([OFGamerscore getResourceName], [OFGamerscore class]);
	namedResources->addResource([OFUserGameStat getResourceName], [OFUserGameStat class]);
	namedResources->addResource([OFUser getResourceName], [OFUser class]);
	namedResources->addResource([OFUsersCredential getResourceName], [OFUsersCredential class]);
}

+ (void) getLocalPlayerProfileOnSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	[OFProfileService getProfileForUser:nil onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getProfileForUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	if (userId == nil || [userId isEqualToString:[OpenFeint lastLoggedInUserId]])
	{
		userId = @"me";
	}
	else
	{
		OFRetainedPtr<NSString> comparedToUserId = @"me";
		params->io("compared_to_user_id", comparedToUserId);
	}
	
	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"profiles/%@/", userId]
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void) getGamerscoreForUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	if (userId == nil)
		userId = @"me";

	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"profiles/%@/gamerscore", userId]
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

@end