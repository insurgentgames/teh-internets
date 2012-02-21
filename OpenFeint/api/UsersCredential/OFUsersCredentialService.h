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

#import "OFService.h"

@class OFLeaderboard;

@interface OFUsersCredentialService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFUsersCredentialService);

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess 
				 onFailure:(const OFDelegate&)onFailure 
onlyIncludeNotLinkedCredentials:(bool)onlyIncludeNotLinkedCredentials
onlyIncludeFriendsCredentials:(bool)onlyIncludeFriendsCredentials;

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess 
				 onFailure:(const OFDelegate&)onFailure 
onlyIncludeLinkedCredentials:(bool)onlyIncludeLinkedCredentials;

+ (void)importFriendsFromCredentialType:(NSString*)credentialType 
							  onSuccess:(const OFDelegate&)onSuccess 
							  onFailure:(const OFDelegate&)onFailure;

+ (void)getProfilePictureCredentialsForLocalUserOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (void)selectProfilePictureSourceForLocalUser:(NSString*)credentialSource onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;
+ (void)uploadProfilePictureLocalUser:(UIImage *)image onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;
+ (void)requestProfilePictureUpdateForLocalUserOnSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

@end
