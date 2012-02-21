#import "cocos2d.h"
@class Game;

@interface GameStuff : CCLayer {
	Game* game;
	BOOL paused;
}

@property (nonatomic,retain) Game* game;

- (void) pause;
- (void) resume;

// putting these selectors here so they'll pause when the game pauses
- (void) launch;
- (void) newObject;
- (void) speedIncrease;
- (void) checkAchievements;
- (void) instructionsLaunch;

@end
