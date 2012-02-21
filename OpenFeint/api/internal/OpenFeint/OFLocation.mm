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


#import "OFLocation.h"
#import "OFUserService.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "MPOAuthAPIRequestLoader.h"
#import "MPOAuthURLResponse.h"
#import "OFActionRequest.h"

@implementation OFLocation

@synthesize locationManager;
@synthesize userLocation;

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		locationManager = [[[CLLocationManager alloc] init] retain];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest; //kCLLocationAccuracyNearestTenMeters;
		[locationManager startUpdatingLocation];
		[self performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:60];
	}
	return self;
}

- (void) dealloc 
{
	OFSafeRelease(locationManager);
	OFSafeRelease(userLocation);
	[super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	OFSafeRelease(userLocation);
	userLocation = [newLocation retain];

	OFUserDistanceUnitType userDistanceUnit = [OpenFeint userDistanceUnit];
	if ( userDistanceUnit == kDistanceUnitNotDefined ) 
	{
		userAllowed = YES;
		[OpenFeint setUserDistanceUnit:kDistanceUnitMiles];
	}
	
	[self stopUpdatingLocation];	
	[self performSelector:@selector(updateUserLocation) withObject:nil afterDelay:0];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied) 
	{
        [OpenFeint setUserDistanceUnit:kDistanceUnitNotAllowed];
    }
	
	[self stopUpdatingLocation];
}

- (void)stopUpdatingLocation 
{
	[locationManager stopUpdatingLocation];
	locationManager.delegate = nil;
	OFSafeRelease(locationManager);
}

- (CLLocation*)getUserLocation
{
	return userLocation;
}

- (void)updateUserLocation
{
	static int tries = 0;
	if ([OpenFeint isOnline])
	{
		OFDelegate locationFailed(self, @selector(_onSetLocationFailed:));
		[OFUserService setUserLocation:nil location:userLocation allowed:userAllowed onSuccess:OFDelegate() onFailure:locationFailed];
	}
	else if (tries++ < 10)
	{
		[self performSelector:@selector(updateUserLocation) withObject:nil afterDelay:10];
	}
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void) _onSetLocationFailed:(MPOAuthAPIRequestLoader*)request
{
	//NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)request.oauthResponse.urlResponse;
	//if([httpResponse statusCode] == OpenFeintHttpStatusCodeForbidden)
	//{
		[OpenFeint setUserDistanceUnit:kDistanceUnitNotAllowed];
		[OpenFeint setUserLocation:nil];
	//}
}

@end