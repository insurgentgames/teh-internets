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
#import "OFChallengeService.h"
#import "OFResourceDataMap.h"
#import "OFChallengeDefinition.h"
#import "OFUser.h"

@implementation OFChallenge

@synthesize challengeDefinition, challengeDescription, challenger, challengeDataUrl, hiddenText, userMessage;

- (void)setChallengeDescription:(NSString*)value
{
	OFSafeRelease(challengeDescription);
	challengeDescription = [value retain];
}

- (void)setUserMessage:(NSString*)value
{
	OFSafeRelease(userMessage);
	userMessage = [value retain];
}

-(void)setHiddenText:(NSString*)value
{
	OFSafeRelease(hiddenText);
	hiddenText = [value retain];
}

- (void)setChallengeDefinition:(OFChallengeDefinition*)value
{
	OFSafeRelease(challengeDefinition);
	challengeDefinition = [value retain];
}

- (OFChallengeDefinition*)getChallengeDefinition
{
	return challengeDefinition;
}

- (void)setDataUrl:(NSString*)value
{
	OFSafeRelease(challengeDataUrl);
	challengeDataUrl = [value retain];
}


+ (OFService*)getService;
{
	return [OFChallengeService sharedInstance];
}

- (void)setChallenger:(OFUser*)value
{
	OFSafeRelease(challenger);
	challenger = [value retain];
}

- (OFUser*)getChallenger
{
	return challenger;
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"description", @selector(setChallengeDescription:), @selector(challengeDescription));
		dataMap->addField(@"hidden_text", @selector(setHiddenText:), @selector(hiddenText));
		dataMap->addField(@"user_message", @selector(setUserMessage:), @selector(userMessage));
		dataMap->addField(@"user_data_url", @selector(setDataUrl:), @selector(challengeDataUrl));
		dataMap->addNestedResourceField(@"challenge_definition", @selector(setChallengeDefinition:), @selector(getChallengeDefinition), [OFChallengeDefinition class]);
		dataMap->addNestedResourceField(@"user",@selector(setChallenger:), @selector(getChallenger), [OFUser class]);
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"challenge";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_challenge_discovered";
}

- (BOOL)usesChallengeData
{
	return	challengeDataUrl && 
			![challengeDataUrl isEqualToString:@""] &&
			![challengeDataUrl isEqualToString:@"/empty.blob"];
}

- (void) dealloc
{
	OFSafeRelease(challengeDefinition);
	OFSafeRelease(challenger);
	OFSafeRelease(challengeDescription);
	OFSafeRelease(hiddenText);
	OFSafeRelease(userMessage);
	[super dealloc];
}

@end
