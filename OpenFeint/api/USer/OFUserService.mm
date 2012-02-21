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
#import "OFUserService.h"
#import "OFUserService+Private.h"
#import "OFService+Private.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFReachability.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint.h"
#import "OFUser.h"
#import "OFPaginatedSeries.h"

#import "OFHttpBasicCredential.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFUserService)

@implementation OFUserService

OPENFEINT_DEFINE_SERVICE(OFUserService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFUser getResourceName], [OFUser class]);

	namedResources->addResource([OFHttpBasicCredential getResourceName], [OFHttpBasicCredential class]);
}

+ (void) getUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	// if it's the local user just immediately invoke success with our local user information
	OFUser* localUser = [OpenFeint localUser];
	if ([userId length] == 0 || [userId isEqualToString:localUser.resourceId])
	{
		onSuccess.invoke([OFPaginatedSeries paginatedSeriesWithObject:localUser]);
		return;
	}

	if ([OpenFeint isOnline])
	{
		if (userId == nil)
		{
			userId = @"@me";
		}
		
		[[self sharedInstance] 
		 getAction:[NSString stringWithFormat:@"users/%@/", userId]
		 withParameters:nil
		 withSuccess:onSuccess
		 withFailure:onFailure
		 withRequestType:OFActionRequestSilent
		 withNotice:nil];
	} else {
		[OFUserService 
		 getLocalUser:userId
		 onSuccess:onSuccess
		 onFailure:onFailure];
	}
}

+ (void)findUsersByName:(NSString*)name pageIndex:(NSInteger)pageIndex onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("name", name);
	params->io("page", pageIndex);
	
	[[self sharedInstance] 
	 getAction:@"users.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void)findUsersForLocalDeviceOnSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("udid", [[UIDevice currentDevice] uniqueIdentifier]);
	
	[[self sharedInstance] 
		_performAction:@"users/for_device.xml"
		withParameters:params
		withHttpMethod:@"GET"
		withSuccess:onSuccess
		withFailure:onFailure
		withRequestType:OFActionRequestSilent
		withNotice:nil
		requiringAuthentication:false];
}

+ (void) getEmailForUser:(NSString*)userId onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	if (userId == nil)
	{
		userId = @"@me";
	}
	
	[[self sharedInstance] 
	 getAction:[NSString stringWithFormat:@"http_basic_credentials/%@.xml", userId]
	 withParameters:nil
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

+ (void) setUserLocation:(NSString*)userId location:(CLLocation*)location allowed:(BOOL)allowed onSuccess:(OFDelegate const&)onSuccess onFailure:(OFDelegate const&)onFailure
{
	if (userId == nil)
	{
		userId = @"@me";
	}
		
	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	double lat = location.coordinate.latitude;
	double lng = location.coordinate.longitude;
	params->io("lat", lat);
	params->io("lng", lng);

	if (allowed)
	{
		params->io("allowed", @"1");
	}
	
	[[self sharedInstance] 
	 postAction:[NSString stringWithFormat:@"users/%@/set_location.xml", userId]
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestSilent
	 withNotice:nil];
}

@end
