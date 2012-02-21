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
#import "OFSocialNotificationService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"
#import "OFSocialNotificationService+Private.h"
#import "OFImageUrl.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFSocialNotificationService);

@implementation OFSocialNotificationService

OPENFEINT_DEFINE_SERVICE(OFSocialNotificationService);

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFImageUrl getResourceName], [OFImageUrl class]);
}

+ (void)getImageUrlForNotificationImageNamed:(NSString*)imageName onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("image_name", imageName);

	[[self sharedInstance] 
		getAction:[NSString stringWithFormat:@"client_applications/%@/notification_images/show.xml", [OpenFeint clientApplicationId]]
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)sendWithText:(NSString *)text
{
	[self sendWithSocialNotification:[[[OFSocialNotification alloc] initWithText:text] autorelease]];
}

+ (void)sendWithText:(NSString*)text imageNamed:(NSString*)imageName
{
	[self sendWithSocialNotification:[[[OFSocialNotification alloc] initWithText:text imageNamed:imageName] autorelease]];
}



@end