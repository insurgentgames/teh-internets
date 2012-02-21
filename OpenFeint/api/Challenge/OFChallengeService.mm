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
#import "OFChallenge.h"
#import "OFChallengeToUser.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeService.h"
#import "OFSendChallengeController.h"
#import "OFCompletedChallengeHeaderController.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFControllerLoader.h"
#import "OpenFeint+Private.h"
#import "OFNavigationController.h"
#import "OFHttpService.h"
#import "OFBlobDownloadObserver.h"
#import "OFProvider.h"
#import "OFChallengeDetailController.h"
#import "OFXmlDocument.h"
#import "OFFramedNavigationController.h"
#import "OFUser.h"


OPENFEINT_DEFINE_SERVICE_INSTANCE(OFChallengeService)

#pragma mark OFChallengeService

@implementation OFChallengeService

OPENFEINT_DEFINE_SERVICE(OFChallengeService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFChallenge getResourceName], [OFChallenge class]);
	namedResources->addResource([OFChallengeToUser getResourceName], [OFChallengeToUser class]);
	namedResources->addResource([OFUser getResourceName], [OFUser class]);
}

// NOTE: Assigning to a OFPointer property in 2.2.1 doesn't actually retain the object! Never use properties with OFPointers. 
- (OFHttpService*)createHttpService
{
	if (mHttpService)
	{
		mHttpService->cancelAllRequests();
	}
	mHttpService = [OFProvider createHttpService];
	return mHttpService.get();
}

//displays the send challenge modal
+ (void)displaySendChallengeModal:(NSString*)challengeDefinitionId
					challengeText:(NSString*)challengeText 
					challengeData:(NSData*)challengeData
{
	OFSendChallengeController* modal = (OFSendChallengeController*)OFControllerLoader::load(@"SendChallenge");
	modal.challengeDefinitionId = challengeDefinitionId;
	modal.challengeText = challengeText;
	modal.challengeData = challengeData;
	modal.title = @"Challenge Friends";
	modal.isCompleted = NO;
	[OFNavigationController addCloseButtonToViewController:modal target:modal action:@selector(cancel)];
	OFNavigationController* navController = [[[OFFramedNavigationController alloc] initWithRootViewController:modal] autorelease];
	[OpenFeint presentRootControllerWithModal:navController];
}

+ (void)displayChallengeCompletedModal:(OFChallengeToUser*)userChallenge
							resultData:(NSData*)resultData
								result:(OFChallengeResult)result
					 resultDescription:(NSString*)resultDescription
				reChallengeDescription:(NSString*)reChallengeDescription
{
	UIViewController* modal = nil;
	userChallenge.isCompleted = !userChallenge.challenge.challengeDefinition.multiAttempt || (result == kChallengeResultRecipientWon);
	userChallenge.resultDescription = resultDescription;
	userChallenge.result = result;
	if (userChallenge.challenge.challengeDefinition.multiAttempt && result == kChallengeResultRecipientWon)
	{
		OFSendChallengeController* sendChallengeModal = (OFSendChallengeController*)OFControllerLoader::load(@"SendChallenge");
		sendChallengeModal.challengeDefinitionId = userChallenge.challenge.challengeDefinition.resourceId;
		sendChallengeModal.challengeText = reChallengeDescription;
		sendChallengeModal.resultData = resultData;
		sendChallengeModal.userChallenge = userChallenge;
		sendChallengeModal.isCompleted = userChallenge.isCompleted;
		sendChallengeModal.title = @"Challenge Result";
		modal = sendChallengeModal;
	}
	else
	{
		OFCompletedChallengeHeaderController* completedChallengeModal = (OFCompletedChallengeHeaderController*)OFControllerLoader::load(@"CompletedChallengeHeader");
		completedChallengeModal.sendChallengeController = nil;
		[completedChallengeModal setChallenge:userChallenge];
		modal = completedChallengeModal;
	}
	
	[OFNavigationController addCloseButtonToViewController:modal target:modal action:@selector(cancel)];
	OFNavigationController* navController = [[[OFFramedNavigationController alloc] initWithRootViewController:modal] autorelease];
	[OpenFeint presentRootControllerWithModal:navController];
}

//sends challenges to users
+ (void)sendChallenge:(NSString*)challengeDefinitionId
		challengeText:(NSString*)challengeText 
		challengeData:(NSData*)challengeData
		  userMessage:(NSString*)userMessage
		   hiddenText:(NSString*)hiddenText
			  toUsers:(NSArray*)userIds 
inResponseToChallenge:(NSString*)instigatingChallengeId
			onSuccess:(OFDelegate const&)onSuccess 
			onFailure:(OFDelegate const&)onFailure
{	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("challenge_hidden_text", hiddenText);
	params->io("challenger_id", @"me");
	params->io("challenge_description", challengeText);
	params->io("challenge_definition_id", challengeDefinitionId);
	if (instigatingChallengeId)
	{
		params->io("challenge_response_to_challenge_id", challengeDefinitionId);
	}
	
	if (userMessage)
	{
		params->io("challenge_user_message", userMessage);
	}
	
	OFRetainedPtr<NSData> retainedData = challengeData;
	params->io("challenge_user_data", retainedData);
	
	std::vector<OFRetainedPtr<NSString> > stdUserIds;
	for (NSString* curUserId in userIds)
	{
		stdUserIds.push_back(curUserId);
	}

	params->serialize("challenge_user_ids", "user_ids", stdUserIds);
	
	[[self sharedInstance] 
	 postAction:@"challenges.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestBackground
	 withNotice:[OFNotificationData dataWithText:@"Challenge Sent"
									 andCategory:kNotificationCategoryChallenge
										 andType:kNotificationTypeSubmitting]];	
}

+ (void)submitChallengeResult:(NSString*)challengeToUserId
					   result:(OFChallengeResult)challengeResult
			resultDescription:(NSString*)resultDescription
					onSuccess:(OFDelegate const&)onSuccess 
					onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	{
		OFISerializer::Scope challengesUserScope(params.get(), "challenges_user", false);
		params->io("result_text", resultDescription);
		if (challengeResult == kChallengeResultRecipientWon)
		{
			params->io("result", @"win");
		}
		else if (challengeResult == kChallengeResultRecipientLost)
		{
			params->io("result", @"lose");
		}
		else if (challengeResult == kChallengeResultTie)
		{
			params->io("result", @"tie");
		}
	}
	
	[[self sharedInstance] 
	 postAction:[NSString stringWithFormat:@"challenges_users/%@/update.xml", challengeToUserId]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Submitted Challenge"]];
}

+(void)getChallengeToUserWithId:(NSString*)challengeToUserId
					  onSuccess:(OFDelegate const&)onSuccess
					  onFailure:(OFDelegate const&)onFailure
{
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenges_users/%@.xml",challengeToUserId]
	 withParameters:nil
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)rejectChallenge:(NSString*)challengeToUserId
			  onSuccess:(OFDelegate const&)onSuccess
			  onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	{
		OFISerializer::Scope challengesUserScope(params.get(), "challenges_user", false);
		bool ignored = true;
		params->io("ignored", ignored);
	}
	
	[[self sharedInstance] 
	 postAction:[NSString stringWithFormat:@"challenges_users/%@/update.xml", challengeToUserId]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Rejected Challenge"]];
}

//download challenge blob
+(void)downloadChallengeData:(NSString*)challengeDataUrl
				   onSuccess:(OFDelegate const&)onSuccess
				   onFailure:(OFDelegate const&)onFailure
{
	OFChallengeService* instance = [OFChallengeService sharedInstance];
	if(challengeDataUrl != nil && ![challengeDataUrl isEqualToString:@""])
	{
		OFHttpService* httpService = [instance createHttpService];
		httpService->startRequest(challengeDataUrl, HttpMethodGet, NULL, new OFBlobDownloadObserver(onSuccess, onFailure));
	}
}

+ (void)writeChallengeToUserToFile:(NSString*)fileName challengeToUser:(OFChallengeToUser*)challengeToUser
{
	NSString* xmlString = [challengeToUser toResourceArrayXml];
	NSData* data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	[data writeToFile:fileName atomically:YES];	
}

+ (OFChallengeToUser*)readChallengeToUserFromFile:(NSString*)fileName
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
	{
		return nil;
	}
	NSData* documentData = [NSData dataWithContentsOfFile:fileName];
	OFXmlDocument* document = [OFXmlDocument xmlDocumentWithData:documentData];
	OFPaginatedSeries* page = [OFResource resourcesFromXml:document withMap:[[OFChallengeService sharedInstance] getKnownResources]];
	if ([page.objects count] > 0)
	{
		return [page.objects objectAtIndex:0];
	}
	else
	{
		return nil;
	}
}

+ (void)getChallengeHistoryAcrossAllTypes:(NSUInteger)pageIndex
								onSuccess:(OFDelegate const&)onSuccess 
								onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool history = true;
	params->io("history", history);
	params->io("page", pageIndex);
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"challenges_users.xml"]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloading Challenge Information"]];
}

+ (void)getChallengeHistoryForType:(NSString*)challengeDefinitionId
			   clientApplicationId:(NSString*)clientApplicationId
						 pageIndex:(NSInteger)pageIndex
						 onSuccess:(OFDelegate const&)onSuccess 
						 onFailure:(OFDelegate const&)onFailure
{
	[OFChallengeService getChallengeHistoryForType:challengeDefinitionId
							   clientApplicationId:clientApplicationId
										 pageIndex:pageIndex
								  comparedToUserId:nil
										 onSuccess:onSuccess
										 onFailure:onFailure];
}

+ (void)getChallengeHistoryForType:(NSString*)challengeDefinitionId
			   clientApplicationId:(NSString*)clientApplicationId
						 pageIndex:(NSInteger)pageIndex
				  comparedToUserId:(NSString*)comparedToUserId
						 onSuccess:(OFDelegate const&)onSuccess 
						 onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	bool history = true;
	params->io("history", history);
	params->io("page", pageIndex);
	params->io("challenge_definition_id", challengeDefinitionId);
	if (clientApplicationId)
	{
		params->io("client_application_id", clientApplicationId);
	}
	if (comparedToUserId && [comparedToUserId length] > 0)
	{
		params->io("compared_user_id", comparedToUserId);
	}
	
	[[self sharedInstance] 
		  getAction:[NSString stringWithFormat:@"challenges_users.xml"]
	 withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
	withRequestType:OFActionRequestForeground
		 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloading Challenge Information"]];
}

@end