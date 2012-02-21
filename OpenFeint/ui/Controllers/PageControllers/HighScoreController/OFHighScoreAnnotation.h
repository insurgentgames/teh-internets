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
#import "OFHighScore.h"
#import "OFBadgeView.h"
#import "OFLeaderboard+Sync.h"

#import <MapKit/MapKit.h>

@interface OFHighScoreAnnotation : NSObject <MKAnnotation> {
	OFHighScore* _highScore;
	NSInteger rank;
	OFBadgeView* rankBadge;
	OFLeaderboard_Sync* leaderboardInfo;

@private
	CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, retain) OFHighScore* highScore;
@property (nonatomic, retain) OFBadgeView* rankBadge;
@property (nonatomic, retain) OFLeaderboard_Sync* leaderboardInfo;
@property (nonatomic) NSInteger rank;

- (id)initWithHighScore:(OFHighScore*)highScore leaderboardInfo:(OFLeaderboard_Sync*)leaderboardInfo;
- (void) updateRankBadge;
- (void) setScore:(OFHighScore*)score andLocation:(bool)setLocation;

@end
#endif