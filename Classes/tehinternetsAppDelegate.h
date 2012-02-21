#import <UIKit/UIKit.h>
#import "OpenFeint.h"
@class Options;
@class Stats;
@class NoOfAchievements;
@class Game;

@interface tehinternetsAppDelegate : NSObject <UIApplicationDelegate, OpenFeintDelegate, OFNotificationDelegate> {
	Options* options;
	Stats* stats;
	Game* game;
	NoOfAchievements* noOfAchievements;
	UIWindow *window;
	
	BOOL musicPlaying;
}

@property (nonatomic, retain) Options* options;
@property (nonatomic, retain) Stats* stats;
@property (nonatomic, retain) Game* game;
@property (nonatomic, retain) UIWindow* window;

// sound and music
- (void) playSound:(NSString*)sound;
- (void) startMusic:(NSString*)music;
- (void) stopMusic;
- (void) pauseMusic;
- (void) resumeMusic;

// high scores
- (void) submitHighScore:(int64_t)score time:(int64_t)t lolcats:(int64_t)cats;
- (void) submitTotals;
- (void) openHighScores;
- (void) submitFailed;
- (void) submitSucceeded;

// achievements
- (void) unlockAchievement:(NSString*)achievementId;
- (BOOL) isAchievementUnlocked:(NSString*)achievementId;
- (NSString*) getAchievementTitle:(NSString*)achievementId;
- (NSString*) getAchievementDescription:(NSString*)achievementId;

@end
