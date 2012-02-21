#import <Foundation/Foundation.h>

@interface NoOfAchievements : NSObject {
	NSMutableDictionary* achievements;
}

@property (nonatomic,retain) NSMutableDictionary* achievements;

- (NSString*)getFilePath;
- (void) load;
- (void) save;
- (void) display;
- (void) unlockAchievement:(NSString*)achievementId;
- (BOOL) isAchievementUnlocked:(NSString*)achievementId;

@end
