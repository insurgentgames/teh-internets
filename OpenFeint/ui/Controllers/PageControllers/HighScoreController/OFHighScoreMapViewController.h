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

#import "OFViewController.h"
#import "OFHighScore.h"
#import "OFHighScoreAnnotationView.h"
#import "OFLeaderboardService+Private.h"
#import "OFDefaultButton.h"
#import <MapKit/MapKit.h>


@interface OFHighScoreMapViewController : OFViewController <MKMapViewDelegate, OFCallbackable>
//@interface OFHighScoreMapViewController : OFTableSequenceControllerHelper <MKMapViewDelegate, OFCallbackable>
{
@package
	IBOutlet MKMapView *mapView;
	CLLocation* locationOfUser;
	OFLeaderboard_Sync* leaderboardInfo;
	NSString* leaderboardId;
	OFHighScoreAnnotation* annotationForUser;

	bool receivedScores;
	bool zoomToLocation;

	CLLocation* locationOfCenter;
	double smallestBoarderDistance;
	
	//UIButton* refreshButton;
	IBOutlet OFDefaultButton* refreshButton;
	OFDefaultButton* findMeButton;
	
	CLLocationCoordinate2D boundaryCoordNE;
	CLLocationCoordinate2D boundaryCoordSW;
	
	int dontShowit;
	
	NSMutableArray* annotations;
}

- (IBAction) _clickedRefresh;
- (void) loadAnnotationsFromHighScores:(NSArray*) resources;
- (OFHighScoreAnnotation*) getAnnotationForHighScore:(OFHighScore*) highScore;
- (OFHighScoreAnnotationView*)getAnnotationView:(OFHighScoreAnnotation*)annotation;
- (void) rankVisibleAnnotations;
- (void) getScores;
- (void) setLeaderboard:(NSString*)leaderboardId;
- (void) determineIfResetShouldShow;
- (bool) isNewCoordinateInsideView;
- (void) setBoundaryCoordinates;

@property (nonatomic, retain) OFLeaderboard_Sync* leaderboardInfo;

@end

#endif