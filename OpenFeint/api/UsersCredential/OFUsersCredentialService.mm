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
#import "OFUsersCredentialService.h"
#import "OFUsersCredential.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFUsersCredentialService);

@implementation OFUsersCredentialService

OPENFEINT_DEFINE_SERVICE(OFUsersCredentialService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFUsersCredential getResourceName], [OFUsersCredential class]);
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess 
				 onFailure:(const OFDelegate&)onFailure 
onlyIncludeNotLinkedCredentials:(bool)onlyIncludeNotLinkedCredentials
onlyIncludeFriendsCredentials:(bool)onlyIncludeFriendsCredentials
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("only_include_not_linked_credentials", onlyIncludeNotLinkedCredentials);
	params->io("only_include_friends_credentials", onlyIncludeFriendsCredentials);
	OFRetainedPtr<NSString> me = @"me";
	params->io("user_id", me);
	
	[[self sharedInstance]
		getAction:@"users_credentials"
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestForeground
		withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded"]];
}


+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess 
				 onFailure:(const OFDelegate&)onFailure 
onlyIncludeLinkedCredentials:(bool)onlyIncludeLinkedCredentials
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("only_include_linked_credentials", onlyIncludeLinkedCredentials);
	OFRetainedPtr<NSString> me = @"me";
	params->io("user_id", me);
	
	[[self sharedInstance]
	 getAction:@"users_credentials"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)importFriendsFromCredentialType:(NSString*)credentialType 
							  onSuccess:(const OFDelegate&)onSuccess 
							  onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("credential_name", credentialType);
	params->io("user_id", @"me");
	
	[[self sharedInstance]
	 getAction:@"users_credentials/import_friends"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)getProfilePictureCredentialsForLocalUserOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	[[self sharedInstance]
		getAction:@"profile_picture"
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)selectProfilePictureSourceForLocalUser:(NSString*)credentialSource onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
	if ([credentialSource length] == 0)
		credentialSource = @"http_basic";
	
	[[self sharedInstance]
		postAction:[NSString stringWithFormat:@"profile_picture/select/%@", credentialSource]
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

+ (void)uploadProfilePictureLocalUser:(UIImage *)image onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure {
    OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	
    NSString *credentialSource = @"http_basic";
    
    OFRetainedPtr<NSData> retainedImageData = nil;
    if (image) {
        retainedImageData = UIImageJPEGRepresentation(image, 0.7);
        params->io("uploaded_profile_picture", retainedImageData);
    } else {
        params->io("uploaded_profile_picture", @"");
    }
    
    [[self sharedInstance]
        postAction:[NSString stringWithFormat:@"profile_picture/select/%@", credentialSource]
        withParameters:params
        withSuccess:onSuccess
        withFailure:onFailure
        withRequestType:OFActionRequestSilent
        withNotice:nil];
}

+ (void)requestProfilePictureUpdateForLocalUserOnSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	[[self sharedInstance]
		postAction:@"profile_picture/refresh"
		withParameters:params
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil];
}

@end
