#import "tehinternetsAppDelegate.h"
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Options.h"
#import "Stats.h"
#import "Game.h"
#import "MainMenu.h"
#import "OFHighScoreService.h"
#import "OFAchievement.h"
#import "OFAchievementService.h"
#import "OFAchievementService+Private.h"
#import "OpenFeint+UserOptions.h"
#import "OFUnlockedAchievementNotificationData.h"
#import "OpenFeint+Dashboard.h"
#import "Notification.h"
#import "Achievements.h"
#import "NoOfAchievements.h"

@implementation tehinternetsAppDelegate

@synthesize options;
@synthesize stats;
@synthesize game;
@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	// WARNING: FastDirector doesn't interact well with UIKit controls
	//[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	//[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:NO];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];
	[window makeKeyAndVisible];
	
	// no active game yet
	game = nil;
	
	// noOfAchievements allocated, just in case
	noOfAchievements = [[NoOfAchievements alloc] init];
	
	// load the options
	options = [[Options alloc] init];
	
	// start the menu music and pause
	[self startMusic:@"Menu.mp3"];
	
	// init openfeint
	NSDictionary* ofSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], OpenFeintSettingDashboardOrientation,
								@"internets", OpenFeintSettingShortDisplayName, 
								[NSNumber numberWithBool:NO], OpenFeintSettingEnablePushNotifications,
								[NSNumber numberWithBool:YES], OpenFeintSettingDisableUserGeneratedContent,
								nil
								];
	[OpenFeint initializeWithProductKey:@"ymAsQe8z1Gr612KG3a2YsQ" 
							  andSecret:@"8Ka20CnD6to0xbbMwx377EEXx4CktnE2YEeofqE7TA" 
						 andDisplayName:@"internets" 
							andSettings:ofSettings 
						   andDelegates:[OFDelegatesContainer containerWithOpenFeintDelegate:self 
																		andChallengeDelegate:nil 
																	 andNotificationDelegate:self]];
	
	// load stats
	stats = [[Stats alloc] init];
	
	// start the main menu
	[[CCDirector sharedDirector] runWithScene: [MainMenu scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	/*if(game != nil)
		if(game.paused == NO)
			[game doPause];*/
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	/*if(game != nil) {
		if(game.paused)
			[game doResume:nil];
		[game endGameplay];
	}*/
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	// shut down openfeint
	[OpenFeint shutdown];
	
	[[CCDirector sharedDirector] release];
	[options release];
	[stats release];
	[noOfAchievements release];
	[window release];
	[super dealloc];
}

// sound and music functions
- (void) playSound:(NSString*)sound {
	if(options.soundEnabled) {
		[[SimpleAudioEngine sharedEngine] playEffect:sound];
	}
}

- (void) startMusic:(NSString*)music {
	if(options.musicEnabled) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:music];
	}
}

- (void) stopMusic {
	if(options.musicEnabled) {
		//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic]; // stopBackgroundMusic has a bug in the simulator
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	}
}

- (void) pauseMusic {
	if(options.musicEnabled) {
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	}
}

- (void) resumeMusic {
	if(options.musicEnabled) {
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	}
}

// openfeint methods
- (void)dashboardWillAppear {
	if([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
		musicPlaying = YES;
		[self pauseMusic];
	} else {
		musicPlaying = NO;
	}
	
	/*// pause the game
	if(game != nil) {
		if(!game.paused) {
			[game doPause];
		}
	}*/
}

- (void)dashboardDidAppear {
}

- (void)dashboardWillDisappear {
	if(musicPlaying) {
		[self resumeMusic];
	}
}

- (void)dashboardDidDisappear {
}

- (void)userLoggedIn:(NSString*)userId {
	// if there are achievements saved from when the player didn't approve OF, add them to OF
	NSString* achievementId;
	for(achievementId in [noOfAchievements.achievements allKeys]) {
		if([noOfAchievements isAchievementUnlocked:achievementId] == YES) {
			[OFAchievementService unlockAchievement:achievementId];
		}
	}
}

- (BOOL)showCustomOpenFeintApprovalScreen {
	return NO;
}

- (void) submitHighScore:(int64_t)score time:(int64_t)t lolcats:(int64_t)cats {
	// High Scores
	[OFHighScoreService setHighScore:score 
					  forLeaderboard:@"59283" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	
	// Best Times
	[OFHighScoreService setHighScore:t 
					  forLeaderboard:@"59293" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	
	// Most Lolcats
	[OFHighScoreService setHighScore:cats 
					  forLeaderboard:@"59303" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
}

- (void) submitTotals {
	// total time wasted
	[OFHighScoreService setHighScore:stats.totalTimeWasted 
					  forLeaderboard:@"59313" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	// total score
	[OFHighScoreService setHighScore:stats.totalScore 
					  forLeaderboard:@"73103" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	// total lolcats
	[OFHighScoreService setHighScore:stats.totalLolcats 
					  forLeaderboard:@"73113" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	// total cheezburgerz eaten
	[OFHighScoreService setHighScore:stats.totalCheezburgersEaten
					  forLeaderboard:@"73123" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	// total lollerskaters
	[OFHighScoreService setHighScore:stats.totalLollerskaters
					  forLeaderboard:@"73133" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
	// total trolls killed
	[OFHighScoreService setHighScore:stats.totalTrollsKilled
					  forLeaderboard:@"73203" 
						   onSuccess:OFDelegate(self, @selector(submitSucceeded)) 
						   onFailure:OFDelegate(self, @selector(submitFailed))];
}

- (void) openHighScores {
	[OpenFeint launchDashboardWithListLeaderboardsPage];
}

- (void) submitSucceeded {
	// success
}

- (void) submitFailed {
	// failure
}

- (bool)canReceiveCallbacksNow {
	return true;
}

- (BOOL)isOpenFeintNotificationAllowed:(OFNotificationData*)notificationData {
	return NO; // I'll handle my own notifications
}

- (void)handleDisallowedNotification:(OFNotificationData*)notificationData {
	// if it's an achievement, the notification should have already popped up
	if(notificationData.notificationCategory == kNotificationCategoryAchievement)
		return;
	
	CCScene* scene = [[CCDirector sharedDirector] runningScene];
	Notification* notification = [Notification node];
	[notification initWithText:notificationData.notificationText];
	[scene addChild:notification z:300];
}

- (void)notificationWillShow:(OFNotificationData*)notificationData {
}

// achievements
- (void) unlockAchievement:(NSString*)achievementId {
	// popup the notification if the achievement isn't already unlocked
	if([self isAchievementUnlocked:achievementId] == NO) {
		CCScene* scene = [[CCDirector sharedDirector] runningScene];
		Notification* notification = [Notification node];
		[notification initWithText:[NSString stringWithFormat:@"Unlocked: %@ !!!", [self getAchievementTitle:achievementId]]];
		[scene addChild:notification z:300];
	}
	
	// if OF is enabled
	if([OpenFeint hasUserApprovedFeint]) {
		[OFAchievementService unlockAchievement:achievementId];
	}
	// OF is not enabled, so use my own achievements
	else {
		// unlock and save
		[noOfAchievements unlockAchievement:achievementId];
	}
}

- (BOOL) isAchievementUnlocked:(NSString*)achievementId {
	// if OF is enabled
	if([OpenFeint hasUserApprovedFeint]) {
		if([OFAchievementService alreadyUnlockedAchievement:achievementId forUser:[OpenFeint lastLoggedInUserId]])
			return YES;
		else
			return NO;
	}
	// OF is not enabled, so use my own achievements
	else {
		return [noOfAchievements isAchievementUnlocked:achievementId];
	}
}

- (NSString*) getAchievementTitle:(NSString*)achievementId {
	NSString* title = @"unknown achievement";
	if([achievementId compare:ACHIEVEMENT_RTFM] == NSOrderedSame)
		title = ACHIEVEMENT_RTFM_NAME;
	else if([achievementId compare:ACHIEVEMENT_RTFM] == NSOrderedSame)
		title = ACHIEVEMENT_RTFM_NAME;
	else if([achievementId compare:ACHIEVEMENT_N00BS_FIRST_LOLCAT] == NSOrderedSame)
		title = ACHIEVEMENT_N00BS_FIRST_LOLCAT_NAME;
	else if([achievementId compare:ACHIEVEMENT_LOLLERSKATER_SOS] == NSOrderedSame)
		title = ACHIEVEMENT_LOLLERSKATER_SOS_NAME;
	else if([achievementId compare:ACHIEVEMENT_I_CAN_HAS_CHEEZBURGER] == NSOrderedSame)
		title = ACHIEVEMENT_I_CAN_HAS_CHEEZBURGER_NAME;
	else if([achievementId compare:ACHIEVEMENT_GOD_MODE] == NSOrderedSame)
		title = ACHIEVEMENT_GOD_MODE_NAME;
	else if([achievementId compare:ACHIEVEMENT_AVERAGE] == NSOrderedSame)
		title = ACHIEVEMENT_AVERAGE_NAME;
	else if([achievementId compare:ACHIEVEMENT_OMG_A_VIRUS_] == NSOrderedSame)
		title = ACHIEVEMENT_OMG_A_VIRUS__NAME;
	else if([achievementId compare:ACHIEVEMENT_RUTHLESS] == NSOrderedSame)
		title = ACHIEVEMENT_RUTHLESS_NAME;
	else if([achievementId compare:ACHIEVEMENT_FLAMING_] == NSOrderedSame)
		title = ACHIEVEMENT_FLAMING__NAME;
	else if([achievementId compare:ACHIEVEMENT_THE_OPEN_PORT] == NSOrderedSame)
		title = ACHIEVEMENT_THE_OPEN_PORT_NAME;
	else if([achievementId compare:ACHIEVEMENT_CAT_LADY] == NSOrderedSame)
		title = ACHIEVEMENT_CAT_LADY_NAME;
	else if([achievementId compare:ACHIEVEMENT_OVER_9000] == NSOrderedSame)
		title = ACHIEVEMENT_OVER_9000_NAME;
	else if([achievementId compare:ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB] == NSOrderedSame)
		title = ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB_NAME;
	else if([achievementId compare:ACHIEVEMENT_RICKROLLD] == NSOrderedSame)
		title = ACHIEVEMENT_RICKROLLD_NAME;
	else if([achievementId compare:ACHIEVEMENT_KITTENS_INSPIRED_BY_KITTENS] == NSOrderedSame)
		title = ACHIEVEMENT_KITTENS_INSPIRED_BY_KITTENS_NAME;
	else if([achievementId compare:ACHIEVEMENT_DONT_TAZE_ME_BRO] == NSOrderedSame)
		title = ACHIEVEMENT_DONT_TAZE_ME_BRO_NAME;
	else if([achievementId compare:ACHIEVEMENT_IS_THIS_GONNA_BE_FOREVER] == NSOrderedSame)
		title = ACHIEVEMENT_IS_THIS_GONNA_BE_FOREVER_NAME;
	else if([achievementId compare:ACHIEVEMENT_IMMA_LET_YOU_FINISH_] == NSOrderedSame)
		title = ACHIEVEMENT_IMMA_LET_YOU_FINISH__NAME;
	else if([achievementId compare:ACHIEVEMENT_GODWINS_LAW] == NSOrderedSame)
		title = ACHIEVEMENT_GODWINS_LAW_NAME;
	else if([achievementId compare:ACHIEVEMENT_DNFTT] == NSOrderedSame)
		title = ACHIEVEMENT_DNFTT_NAME;
	else if([achievementId compare:ACHIEVEMENT_ITS_PEANUT_BUTTER_JELLY_TIME] == NSOrderedSame)
		title = ACHIEVEMENT_ITS_PEANUT_BUTTER_JELLY_TIME_NAME;
	else if([achievementId compare:ACHIEVEMENT_HAMMER_TIME] == NSOrderedSame)
		title = ACHIEVEMENT_HAMMER_TIME_NAME;
	else if([achievementId compare:ACHIEVEMENT_THE_BACKDOOR] == NSOrderedSame)
		title = ACHIEVEMENT_THE_BACKDOOR_NAME;
	return title;
}

- (NSString*) getAchievementDescription:(NSString*)achievementId {
	NSString* title = @"unknown derscription";
	if([achievementId compare:ACHIEVEMENT_RTFM] == NSOrderedSame)
		title = ACHIEVEMENT_RTFM_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_RTFM] == NSOrderedSame)
		title = ACHIEVEMENT_RTFM_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_N00BS_FIRST_LOLCAT] == NSOrderedSame)
		title = ACHIEVEMENT_N00BS_FIRST_LOLCAT_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_LOLLERSKATER_SOS] == NSOrderedSame)
		title = ACHIEVEMENT_LOLLERSKATER_SOS_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_I_CAN_HAS_CHEEZBURGER] == NSOrderedSame)
		title = ACHIEVEMENT_I_CAN_HAS_CHEEZBURGER_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_GOD_MODE] == NSOrderedSame)
		title = ACHIEVEMENT_GOD_MODE_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_AVERAGE] == NSOrderedSame)
		title = ACHIEVEMENT_AVERAGE_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_OMG_A_VIRUS_] == NSOrderedSame)
		title = ACHIEVEMENT_OMG_A_VIRUS__DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_RUTHLESS] == NSOrderedSame)
		title = ACHIEVEMENT_RUTHLESS_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_FLAMING_] == NSOrderedSame)
		title = ACHIEVEMENT_FLAMING__DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_THE_OPEN_PORT] == NSOrderedSame)
		title = ACHIEVEMENT_THE_OPEN_PORT_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_CAT_LADY] == NSOrderedSame)
		title = ACHIEVEMENT_CAT_LADY_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_OVER_9000] == NSOrderedSame)
		title = ACHIEVEMENT_OVER_9000_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB] == NSOrderedSame)
		title = ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_RICKROLLD] == NSOrderedSame)
		title = ACHIEVEMENT_RICKROLLD_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_KITTENS_INSPIRED_BY_KITTENS] == NSOrderedSame)
		title = ACHIEVEMENT_KITTENS_INSPIRED_BY_KITTENS_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_DONT_TAZE_ME_BRO] == NSOrderedSame)
		title = ACHIEVEMENT_DONT_TAZE_ME_BRO_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_IS_THIS_GONNA_BE_FOREVER] == NSOrderedSame)
		title = ACHIEVEMENT_IS_THIS_GONNA_BE_FOREVER_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_IMMA_LET_YOU_FINISH_] == NSOrderedSame)
		title = ACHIEVEMENT_IMMA_LET_YOU_FINISH__DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_GODWINS_LAW] == NSOrderedSame)
		title = ACHIEVEMENT_GODWINS_LAW_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_DNFTT] == NSOrderedSame)
		title = ACHIEVEMENT_DNFTT_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_ITS_PEANUT_BUTTER_JELLY_TIME] == NSOrderedSame)
		title = ACHIEVEMENT_ITS_PEANUT_BUTTER_JELLY_TIME_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_HAMMER_TIME] == NSOrderedSame)
		title = ACHIEVEMENT_HAMMER_TIME_DESCRIPTION;
	else if([achievementId compare:ACHIEVEMENT_THE_BACKDOOR] == NSOrderedSame)
		title = ACHIEVEMENT_THE_BACKDOOR_DESCRIPTION;
	return title;
}

@end
