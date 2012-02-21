#import "cocos2d.h"
@class Game;

#define GameBackgroundSlowVelocity 0.6
#define GameBackgroundFastVelocity 0.9

@interface GameBackground : CCLayer {
	float speed;
	
	CCSprite* slow1;
	CCSprite* slow2;
	CCSprite* fast1;
	CCSprite* fast2;
}

@property (readwrite) float speed;

- (void) initBackground;
- (void) tick:(id)sender;

@end
