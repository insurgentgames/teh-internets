#import "cocos2d.h"
@class Stats;

@interface MainMenu : CCScene {
	Stats* stats;
}

+ (id) scene;
- (void) onPlay:(id)sender;
- (void) onInstructions:(id)sender;
- (void) onOptions:(id)sender;
- (void) onLeaderboards:(id)sender;
- (void) onAchievements:(id)sender;
- (void) onOtherGames:(id)sender;
- (void) onCredits:(id)sender;

@end
