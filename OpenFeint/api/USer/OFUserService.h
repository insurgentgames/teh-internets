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
#import <CoreLocation/CoreLocation.h>

@interface OFUserService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFUserService);

+ (void)getUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;
+ (void)findUsersByName:(NSString*)name pageIndex:(NSInteger)pageIndex onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

+ (void)findUsersForLocalDeviceOnSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

+ (void)getEmailForUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

+ (void) setUserLocation:(NSString*)userId location:(CLLocation*)location allowed:(BOOL)allowed onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure;

@end