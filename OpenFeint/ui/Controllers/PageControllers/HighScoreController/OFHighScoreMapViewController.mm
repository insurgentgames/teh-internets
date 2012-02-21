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

#ifdef __IPHONE_3_0

#import "OFDependencies.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFHighScoreMapViewController.h"
#import "OFHighScore.h"
#import "OFHighScoreService.h"
#import "OFHighScoreAnnotation.h"
#import "OFHighScoreAnnotationView.h"
#import "OFProfileController.h"
#import "OFImageLoader.h"
#import <CoreLocation/CoreLocation.h>

const double milePerMeter = .000621371;
const int maxAnnotations = 10;
const int maxSearchRadius = 1000;
const int startSearchRadius = 100;

@interface OFHighScoreMapViewController ()
@property (retain) CLLocation* locationOfUser;
@property (retain) CLLocation* locationOfCenter;
@end

@implementation OFHighScoreMapViewController

@synthesize leaderboardInfo, locationOfUser, locationOfCenter;

- (void)dealloc
{
	[mapView removeAnnotations:annotations];
	[annotations removeAllObjects];
	OFSafeRelease(annotations);

	self.locationOfUser = nil;
	self.locationOfCenter = nil;
	
	mapView.delegate = nil;

	OFSafeRelease(mapView);
	OFSafeRelease(leaderboardInfo);
	OFSafeRelease(leaderboardId);
	OFSafeRelease(refreshButton);
	OFSafeRelease(findMeButton);
	OFSafeRelease(annotationForUser);

	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	findMeButton = [[OFDefaultButton greenButton:CGRectMake(0, 0, 100, 10)] retain];
	findMeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.f];
	[findMeButton setTitle:@"Find Me" forState:UIControlStateNormal];
	[findMeButton addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:findMeButton] autorelease];
	self.title = @"Near Me";
	
	mapView.mapType = MKMapTypeStandard; //MKMapTypeHybrid; //MKMapTypeSatellite;
	mapView.delegate=self;
	
	refreshButton.enabled = NO;
	refreshButton.hidden = YES;
	[refreshButton removeFromSuperview];
	
	[mapView addSubview:refreshButton];
	
	self.locationOfUser = [OpenFeint getUserLocation];
	receivedScores = false;
	zoomToLocation = true;
}

- (void) loadAnnotationsFromHighScores:(NSArray*) highScores
{
	if ([annotations count] > 0)
	{
		[mapView removeAnnotations:annotations];
		[annotations removeAllObjects];
	}
	
	if (!annotations)
	{
		annotations = [[NSMutableArray alloc] initWithCapacity:maxAnnotations];
	}
	
	double latitudeDelta = 0.0;
	double longitudeDelta = 0.0;

	unsigned int highScoresCnt = [highScores count];
	if (highScoresCnt > 0)
	{
		int annotationCount = 0;
		
		for (unsigned int i = 0; i < highScoresCnt && annotationCount < maxAnnotations; i++)
		{
			OFHighScore* highScore = [highScores objectAtIndex:i];
			
			double highScoreLatitude = highScore.latitude;
			double highScoreLongitude = highScore.longitude;
			
			//The first score sets the center if not known
			if (self.locationOfCenter == nil && i == 0)
			{
				self.locationOfCenter = [[[CLLocation alloc] initWithLatitude:highScoreLatitude longitude:highScoreLongitude] autorelease];
			}
			
			OFHighScoreAnnotation* annotation;
			
			if ([[OpenFeint lastLoggedInUserId] isEqualToString:highScore.user.resourceId])
			{
				annotation = annotationForUser;
				[annotation setScore:highScore andLocation:true];
			}
			else
			{
				annotation = [[[OFHighScoreAnnotation alloc] initWithHighScore:highScore leaderboardInfo:leaderboardInfo] autorelease];
			}
			
			[annotations addObject:annotation];
			
			if (zoomToLocation)
			{
				double absLatitudeDelta = fabs(fabs(locationOfCenter.coordinate.latitude) - fabs(highScoreLatitude));
				latitudeDelta = MAX(latitudeDelta, absLatitudeDelta);
				double absLongitudeDelta = fabs(fabs(locationOfCenter.coordinate.longitude) - fabs(highScoreLongitude));
				longitudeDelta = MAX(longitudeDelta, absLongitudeDelta);
			}
		}
	}
	
	[mapView addAnnotations:annotations];

	if (zoomToLocation)
	{
		MKCoordinateRegion region;
		
		//region.center = locationOfUser.coordinate;
		region.center = annotationForUser.coordinate;

		//Use span to zoom in
		MKCoordinateSpan span;
		
		span.latitudeDelta = (latitudeDelta != 0.0 ? (latitudeDelta*2.0) + .001 : .5);
		span.longitudeDelta = (longitudeDelta != 0.0 ? (longitudeDelta*2.0) + .001 : .5);
		region.span=span;

		[mapView setRegion:region animated:TRUE];
	    dontShowit = 3;
		zoomToLocation = false;
	}
	[self setBoundaryCoordinates];
	[self hideLoadingScreen];

	refreshButton.enabled = NO;
	refreshButton.hidden = YES;
	receivedScores = true;
}

- (void) setBoundaryCoordinates
{
	//Get the coordinates of the viewable map boundaries
	boundaryCoordNE.latitude = mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta/2.0);
	boundaryCoordNE.longitude =	 mapView.centerCoordinate.longitude + (mapView.region.span.longitudeDelta/2.0);
	boundaryCoordSW.latitude = mapView.centerCoordinate.latitude - (mapView.region.span.latitudeDelta/2.0);
	boundaryCoordSW.longitude = mapView.centerCoordinate.longitude - (mapView.region.span.longitudeDelta/2.0);
	
	self.locationOfCenter = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude] autorelease];
	CLLocation* latLocation = [[[CLLocation alloc] initWithLatitude:boundaryCoordNE.latitude longitude:mapView.centerCoordinate.longitude] autorelease];
	CLLocation* longLocation = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:boundaryCoordNE.longitude] autorelease];
	
	smallestBoarderDistance = (milePerMeter * MIN([locationOfCenter getDistanceFrom:latLocation],[locationOfCenter getDistanceFrom:longLocation]));
}

- (bool) isNewCoordinateInsideView
{
	bool inside = (mapView.centerCoordinate.latitude > boundaryCoordSW.latitude && mapView.centerCoordinate.latitude < boundaryCoordNE.latitude);
	//Does the boundary cross the Meridian
	if (boundaryCoordSW.longitude > boundaryCoordNE.longitude)
	{
		inside &= (mapView.centerCoordinate.longitude < boundaryCoordNE.longitude || mapView.centerCoordinate.longitude > boundaryCoordSW.longitude);
	}
	else
	{
		inside &= (mapView.centerCoordinate.longitude < boundaryCoordNE.longitude && mapView.centerCoordinate.longitude > boundaryCoordSW.longitude);
	}
	return inside;
}


- (void) setLeaderboard:(NSString*)lbId
{
	self.leaderboardInfo = [OFLeaderboardService getLeaderboardDetails:lbId];

	OFSafeRelease(leaderboardId);
	leaderboardId = [lbId retain];
	
	OFSafeRelease(annotationForUser)
	annotationForUser = [[OFHighScoreAnnotation alloc] initWithHighScore:nil leaderboardInfo:leaderboardInfo];
}


- (void)determineIfResetShouldShow
{
	bool showIt = true;
	CLLocation* newCenterLocation = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude] autorelease];
	CLLocation* newBoundaryCorner = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta/2.0)
																longitude:mapView.centerCoordinate.longitude + (mapView.region.span.longitudeDelta/2.0)]
									 autorelease];
	double newMilesBetween = (milePerMeter * [newCenterLocation getDistanceFrom:newBoundaryCorner]);	
	
	if( [self isNewCoordinateInsideView] )
	{
		CLLocation* currentBoundaryCorner = [[[CLLocation alloc] initWithLatitude:boundaryCoordNE.latitude longitude:boundaryCoordNE.longitude] autorelease];
		
		double milesBetweenCenters = (milePerMeter * [locationOfCenter getDistanceFrom:newCenterLocation]);
		double currentMilesBetween = (milePerMeter * [locationOfCenter getDistanceFrom:currentBoundaryCorner]);
		
		showIt = (newMilesBetween < maxSearchRadius && (milesBetweenCenters > (smallestBoarderDistance*.9) || (newMilesBetween*1.50) < currentMilesBetween  /*zooming in*/ || newMilesBetween > (currentMilesBetween * 1.5)) /*zooming out*/);
	}
	
	if (showIt && dontShowit <= 0)
	{
		refreshButton.enabled = YES;
		refreshButton.hidden = NO;
	}
	else
	{
		dontShowit--;
		refreshButton.enabled = NO;
		refreshButton.hidden = YES;
	}
}

- (void)doIndexAction:(CLLocation*)location radius:(int)radius userMapMode:(NSString*)userMapMode
{
	self.locationOfCenter = location;
	refreshButton.enabled = NO;
	refreshButton.hidden = YES;
	[self showLoadingScreen];
	//mapView.hidden = zoomToLocation;

	OFDelegate success = OFDelegate(self, @selector(loadAnnotationsFromHighScores:)); 
	OFDelegate failure;

	[OFHighScoreService getHighScoresFromLocation:location
										   radius:radius
										pageIndex:1
								   forLeaderboard:leaderboardId
										userMapMode:userMapMode
										onSuccess:success 
										onFailure:failure];
	receivedScores = false;
}

- (void) getScores
{
	[self doIndexAction:nil radius:startSearchRadius userMapMode:@"location"];
}

- (IBAction) _clickedRefresh
{
	[self setBoundaryCoordinates];
	
	CGPoint annPoint = [mapView convertCoordinate:annotationForUser.coordinate toPointToView:mapView];
	CGPoint userPoint = [mapView convertCoordinate:locationOfUser.coordinate toPointToView:mapView];
	
	NSString* userMapMode = nil;
	bool annotationAtLocation = (fabs(annotationForUser.coordinate.latitude - locationOfUser.coordinate.latitude) < 0.000001 && fabs(annotationForUser.coordinate.longitude - locationOfUser.coordinate.longitude) < 0.000001);
	
	if (userPoint.x > 0 && userPoint.y > 0 && userPoint.x <= mapView.frame.size.width && userPoint.y <= mapView.frame.size.height && annotationAtLocation)
	{
		userMapMode = @"location";
	}
	else if (annPoint.x > 0 && annPoint.y > 0 && annPoint.x <= mapView.frame.size.width && annPoint.y <= mapView.frame.size.height)
	{
		userMapMode = @"score";
	} 
	else
	{
		userMapMode = @"no";
	}
	
	[self doIndexAction:locationOfCenter
				 radius:MAX(1, lround(smallestBoarderDistance*1.25))
			userMapMode:userMapMode];
}

- (void) findMe
{
	zoomToLocation = true;
	[self doIndexAction:locationOfUser radius:startSearchRadius userMapMode:@"location"];
}


- (OFHighScoreAnnotation*) getAnnotationForHighScore:(OFHighScore*) highScore
{
	if ([[OpenFeint lastLoggedInUserId] isEqualToString:highScore.user.resourceId])
	{
		return annotationForUser;
	}
	else
	{
		for (OFHighScoreAnnotation* mapAnnotation in annotations) 
		{
			if (mapAnnotation.highScore && [mapAnnotation.highScore.resourceId isEqualToString:highScore.resourceId])
			{
				return mapAnnotation;
			}
		}
	}
	return nil;
}

- (void) rankVisibleAnnotations
{
	return;
	NSMutableArray* visibleAnnotations = [NSMutableArray arrayWithCapacity:16];
	for (id <MKAnnotation> mapAnnotation in annotations) 
	{
		CGPoint p = [mapView convertCoordinate: mapAnnotation.coordinate toPointToView:mapView];
		if (p.x > 0 && p.y > 0 && p.x <= mapView.frame.size.width && p.y <= mapView.frame.size.height)
			//is it visible
			//if (p.x > 0 && p.y > 0 && p.x <= self.view.frame.size.width && p.y <= self.view.frame.size.height)
		{
			[visibleAnnotations addObject:(OFHighScoreAnnotation*)mapAnnotation];
		}
	}
	
	[visibleAnnotations sortUsingSelector:@selector(compareScores:)];
	
	OFHighScoreAnnotation* annotation;
	NSInteger counter = 1;
	NSInteger currentRank = 0;
	int64_t previousScore = 0;
	NSEnumerator *enumerator = [visibleAnnotations objectEnumerator];
	while ( (annotation = [enumerator nextObject]) )
	{
		if( counter == 1 || (annotation.leaderboardInfo.descendingSortOrder && annotation.highScore.score < previousScore) || (!annotation.leaderboardInfo.descendingSortOrder && annotation.highScore.score > previousScore))
		{
			currentRank = counter;
		}
		previousScore = annotation.highScore.score;
		annotation.rank = currentRank;
		[annotation updateRankBadge];
		counter++;
	}
}

- (OFHighScoreAnnotationView*)getAnnotationView:(OFHighScoreAnnotation*)annotation
{
	static NSString const* kHighScoreAnnotationViewReuseIdentifier = @"HighScoreAnnotationView";
	
	OFHighScoreAnnotationView* hsAnnotationView = (OFHighScoreAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kHighScoreAnnotationViewReuseIdentifier];	
	if (hsAnnotationView == nil) 
	{
		hsAnnotationView = [[[OFHighScoreAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kHighScoreAnnotationViewReuseIdentifier] autorelease];
	}
	else
	{
		[hsAnnotationView setHighScoreAnnotation:annotation];
	}
	return hsAnnotationView;
}

#pragma mark -
#pragma mark MKMapViewDelegate Methods
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if (receivedScores)
	{
		[self determineIfResetShouldShow];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)_mapView
{
	if (receivedScores)
	{
		[self determineIfResetShouldShow];
	}
}

- (MKAnnotationView*)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation 
{
	return [self getAnnotationView:(OFHighScoreAnnotation*)annotation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([control isKindOfClass:[UIButton class]]) {
		OFHighScoreAnnotationView* annotationView = (OFHighScoreAnnotationView*) view;
		OFHighScoreAnnotation* highScoreAnnotation = (OFHighScoreAnnotation*) annotationView.annotation;
		[OFProfileController showProfileForUser:highScoreAnnotation.highScore.user];
	}
}

#pragma mark -
#pragma mark - OFCallbackable Methods
- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
#endif