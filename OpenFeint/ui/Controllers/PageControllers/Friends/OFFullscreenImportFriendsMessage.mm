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

#import "OFFullscreenImportFriendsMessage.h"
#import "OFControllerLoader.h"
#import "OFUsersCredential.h"
#import "OpenFeint+Private.h"

@implementation OFFullScreenImportFriendsMessage

@synthesize owner;
@synthesize messageLabel;

- (void)dealloc
{
	self.owner = nil;
	self.messageLabel = nil;
	[super dealloc];
}

- (IBAction)onImportFriendsPressed
{
	[self.owner.navigationController pushViewController:OFControllerLoader::load(@"ImportFriends") animated:YES];
}

- (void)setMissingCredentials:(NSArray*)missingUsersCredentials withNotice:(NSString*)notice
{
	const unsigned int numMissingCredentials = [missingUsersCredentials count];

	NSMutableArray* networkNames = [NSMutableArray arrayWithCapacity:2];		
	for(unsigned int i = 0; i < numMissingCredentials; ++i)
	{	
		OFUsersCredential* credential = [missingUsersCredentials objectAtIndex:i];
		
		NSString* humanReadableName = [OFUsersCredential getDisplayNameForCredentialType:credential.credentialType];

		if(i == numMissingCredentials - 1 && numMissingCredentials > 1)
		{
			humanReadableName = [NSString stringWithFormat:@"or %@", humanReadableName];
		}
		
		[networkNames addObject:humanReadableName];
	}
		
	NSString* socialNetworkNames = @"your social networkNames";	
	if([missingUsersCredentials count] == 2)
	{
		socialNetworkNames = [networkNames componentsJoinedByString:@" "];
	}
	else if(numMissingCredentials > 0)
	{
		socialNetworkNames = [networkNames componentsJoinedByString:@", "];
	}
	
	NSString* maybeASpace = @"";
	if (notice && [notice length] >= 0)
		maybeASpace = @" ";
	
	NSString* formatString = @"%@%@Import your friends from %@ to see what OpenFeint games they're playing, compare progress, and more.";	
	messageLabel.text = [NSString stringWithFormat:formatString, notice, maybeASpace, socialNetworkNames];
}

@end