#import "cocos2d.h"

#define GameHUDDPadX 55
#define GameHUDDPadY 55
#define GameHUDRadius 65

typedef enum {
	GameHUDTagUp = 0,
	GameHUDTagDown = 1,
	GameHUDTagPause = 2
} GameHUDTags;

@interface GameHUD : CCLayer {
	// d-pad
	CCLayer* dPadLayer;
	CCSprite* dPadCircle;
	CCSprite* dPadTouch;
	
	// lives
	CCLayer* livesLayer;
	
	// pause
	CCLabel* brb;
	
	// score
	CCLabel* score;

	// paused?
	BOOL paused;
}

@property (nonatomic,retain) CCLayer* dPadLayer;
@property (nonatomic,retain) CCLabel* brb;
@property (nonatomic,retain) CCLabel* score;
@property (readwrite) BOOL paused;

- (void) handleTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) updateLives;

@end
