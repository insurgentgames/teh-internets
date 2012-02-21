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


#import "OpenFeint+UserStats.h"


static const NSString* OpenFeintUserStatNumberOfGameSessions = @"OpenFeintUserStatNumberOfGameSessions";
static const NSString* OpenFeintUserStatTotalGameSessionsDuration = @"OpenFeintUserStatTotalGameSessionsDuration";
static const NSString* OpenFeintUserStatNumberOfDashboardLaunches = @"OpenFeintUserStatNumberOfDashboardLaunches";
static const NSString* OpenFeintUserStatTotalDashboardDuration = @"OpenFeintUserStatTotalDashboardDuration";
static const NSString* OpenFeintUserStatNumberOfOnlineGameSessions = @"OpenFeintUserStatNumberOfOnlineGameSessions";

static NSDate* appStartedAt;
static NSDate* dashboardLaunchedAt;

@implementation OpenFeint (UserStats)

+ (void)intiailizeUserStats
{
	appStartedAt = [[NSDate date] retain];
	OFSafeRelease(dashboardLaunchedAt);
	dashboardLaunchedAt = nil;
}

- (void) dealloc
{
	if (appStartedAt)
		OFSafeRelease(appStartedAt);
	if (dashboardLaunchedAt)
		OFSafeRelease(dashboardLaunchedAt);
	[super dealloc];
}

+ (void)setNumberOfGameSessions:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:OpenFeintUserStatNumberOfGameSessions];
}

+ (void)incrementNumberOfGameSessions
{
	[OpenFeint setNumberOfGameSessions:[OpenFeint numberOfGameSessions] + 1];
}

+ (NSInteger)numberOfGameSessions
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserStatNumberOfGameSessions];
}

+ (void)setNumberOfOnlineGameSessions:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:OpenFeintUserStatNumberOfOnlineGameSessions];
}

+ (void)incrementNumberOfOnlineGameSessions
{
	[OpenFeint setNumberOfOnlineGameSessions:[OpenFeint numberOfOnlineGameSessions] + 1];
}

+ (NSInteger)numberOfOnlineGameSessions
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserStatNumberOfOnlineGameSessions];
}

+ (void)seTotalGameSessionsDuration:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:OpenFeintUserStatTotalGameSessionsDuration];
}

+ (void)incrementTotalGameSessionsDurationBy:(NSInteger)value
{
	[OpenFeint seTotalGameSessionsDuration:[OpenFeint totalGameSessionsDuration] + value];
}

+ (NSInteger)totalGameSessionsDuration
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserStatTotalGameSessionsDuration];
}

+ (void)setNumberOfDashboardLaunches:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:OpenFeintUserStatNumberOfDashboardLaunches];
}

+ (void)incrementNumberOfDashboardLaunches
{
	[OpenFeint setNumberOfDashboardLaunches:[OpenFeint numberOfDashboardLaunches] + 1];
}

+ (NSInteger)numberOfDashboardLaunches
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserStatNumberOfDashboardLaunches];
}

+ (void)setTotalDashboardDuration:(NSInteger)value
{
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:OpenFeintUserStatTotalDashboardDuration];
}

+ (void)incrementTotalDashboardDurationBy:(NSInteger)value
{
	[OpenFeint setTotalDashboardDuration:[OpenFeint totalDashboardDuration] + value];
}

+ (NSInteger)totalDashboardDuration
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:OpenFeintUserStatTotalDashboardDuration];
}

+ (void)dashboardLaunched
{
	dashboardLaunchedAt = [[NSDate date] retain];
	[OpenFeint incrementNumberOfDashboardLaunches];
}

+ (void)dashboardClosed
{
	if (dashboardLaunchedAt != nil)
	{
		[OpenFeint incrementTotalDashboardDurationBy:[[NSDate date] timeIntervalSince1970] - [dashboardLaunchedAt timeIntervalSince1970]];
		OFSafeRelease(dashboardLaunchedAt);
		dashboardLaunchedAt = nil;
	}
}

+ (void)sessionClosed
{
	[OpenFeint incrementTotalGameSessionsDurationBy:[[NSDate date] timeIntervalSince1970] - [appStartedAt timeIntervalSince1970]];
}

+ (void) getUserStatsParams:(OFHttpNestedQueryStringWriter*)params
{
	params->io("[user_stats]total_dashboard_duration", [NSString stringWithFormat:@"%d", [OpenFeint totalDashboardDuration]]);
	params->io("[user_stats]total_dashboard_launches", [NSString stringWithFormat:@"%d", [OpenFeint numberOfDashboardLaunches]]);
	params->io("[user_stats]total_game_session_duration", [NSString stringWithFormat:@"%d", [OpenFeint totalGameSessionsDuration]]);
	params->io("[user_stats]total_game_sessions", [NSString stringWithFormat:@"%d", [OpenFeint numberOfGameSessions]]);
	params->io("[user_stats]total_online_game_sessions", [NSString stringWithFormat:@"%d", [OpenFeint numberOfOnlineGameSessions]]);
}

@end