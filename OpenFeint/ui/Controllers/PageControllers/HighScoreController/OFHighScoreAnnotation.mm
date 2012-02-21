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

#import "OFHighScoreAnnotation.h"
#import "OFUser.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFStringUtility.h"

const double milePerMeter = .000621371;

#pragma mark -
#pragma mark OFHighScoreAnnotation implementation

@implementation OFHighScoreAnnotation

@synthesize coordinate = _coordinate;
//@synthesize title = _title;
@synthesize highScore = _highScore;
@synthesize rank;
@synthesize rankBadge;
@synthesize leaderboardInfo;

- (id)initWithHighScore:(OFHighScore*)highScore leaderboardInfo:(OFLeaderboard_Sync*)leaderboard 
{
	if ( (self = [super init]) ) {
		self.highScore = highScore;
		self.leaderboardInfo = leaderboard;
		
		//self.title = self.highScore.displayText;
		
		if (highScore == nil || [highScore.user.resourceId isEqualToString:[OpenFeint localUser].resourceId])
		{
			self.rankBadge = [OFBadgeView redBadge];
			_coordinate.latitude = [OpenFeint getUserLocation].coordinate.latitude;
			_coordinate.longitude = [OpenFeint getUserLocation].coordinate.longitude;
		}
		else
		{
			self.rankBadge = [OFBadgeView greenBadge];
			_coordinate.latitude = highScore.latitude;
			_coordinate.longitude = highScore.longitude;
		}
		[self.rankBadge setCenter:CGPointMake(15, -15)];
		if (highScore == nil || highScore.rank > 9)
		{
			[self.rankBadge setValueText:@"-"];
		}
		else
		{
			[self.rankBadge setValue:highScore.rank];
		}
	}

	return self;
}

#pragma mark -
#pragma mark MKAnnotation Methods
- (NSString *)title 
{
	NSString* title = nil;
	double distanceBetweenScores = 0.0f;
	NSString* name = [OpenFeint lastLoggedInUserName];
	NSString* distance = nil;
	OFUserDistanceUnitType unit = [OpenFeint userDistanceUnit];
	if( self.highScore )
	{
		name = self.highScore.user.name;
		CLLocation* userLocation = [OpenFeint getUserLocation];
		CLLocation* highScoreLocation = [[[CLLocation alloc] initWithLatitude:self.highScore.latitude longitude:self.highScore.longitude] autorelease];
		distanceBetweenScores = [userLocation getDistanceFrom:highScoreLocation] * (unit == kDistanceUnitMiles ? milePerMeter : 1000);
		distance = [NSString stringWithFormat:@" [%.1f %@]", distanceBetweenScores, (unit == kDistanceUnitMiles ? @"miles" : @"kms")];
	}
	
	title = [NSString stringWithFormat:@"%@%@", name, (distance ? distance : @"")];

	return title;
}

- (NSString *)subtitle 
{
	NSString* subtitle = nil;
	
	//OFUserDistanceUnitType unit = [OpenFeint userDistanceUnit];
	//CLLocation* userLocation = [OpenFeint getUserLocation];
	//CLLocation* highScoreLocation = [[[CLLocation alloc] initWithLatitude:[self.highScore.latitude doubleValue] longitude:[self.highScore.longitude doubleValue]] autorelease];
	//double distanceBetweenScores = [userLocation getDistanceFrom:highScoreLocation] * (unit == kDistanceUnitMiles ? milePerMeter : 1000);
	//subtitle = [NSString stringWithFormat:@"%@ [%5.02f %@ away]", self.highScore.user.name, distanceBetweenScores, (unit == kDistanceUnitMiles ? @"miles" : @"kms")];
	
	if (self.highScore  && self.highScore.rank > 0)
	{
		subtitle = [NSString stringWithFormat:@"Rank in area %d. %@", self.highScore.rank, self.highScore.displayText];
	}
	else
	{
		subtitle = @"No Score";
	}
	return subtitle;
}

- (void) updateRankBadge
{
	[self.rankBadge setValue:self.rank];
}

- (void) setScore:(OFHighScore*)score andLocation:(bool)setLocation
{
	self.highScore = score;
	if (score == nil || score.rank < 1 || score.rank > 9)
	{
		[self.rankBadge setValueText:@"-"];
	}
	else
	{
		[self.rankBadge setValue:score.rank];
	}

	_coordinate.latitude = [OpenFeint getUserLocation].coordinate.latitude;
	_coordinate.longitude = [OpenFeint getUserLocation].coordinate.longitude;

	if (setLocation)
	{
		if (score.latitude)
			_coordinate.latitude = score.latitude;
		if (score.longitude)
			_coordinate.longitude = score.longitude;
	}
}

- (NSComparisonResult)compareScores:(OFHighScoreAnnotation*)otherAnnotation 
{
	if (self.highScore.score < otherAnnotation.highScore.score)
		return (self.leaderboardInfo.descendingSortOrder ? NSOrderedDescending : NSOrderedAscending);
	else if (self.highScore.score > otherAnnotation.highScore.score)
		return (self.leaderboardInfo.descendingSortOrder ? NSOrderedAscending : NSOrderedDescending);
	else 
		return NSOrderedSame;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc 
{
	OFSafeRelease(_highScore);
	[rankBadge removeFromSuperview];
	OFSafeRelease(rankBadge);
	OFSafeRelease(leaderboardInfo);
	
	[super dealloc];
}

@end
#endif