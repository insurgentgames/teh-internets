#import "cocos2d.h"
@class Game;

#define GameCheezburgerVelocity 13.0
#define GameCheezburgerRadius 9.0

@interface GameCheezburger : CCSprite {
	Game* g;
	float angle;
}

- (void) initCheezburgerWithGame:(Game*)game position:(CGPoint)p angle:(float)a;
- (void) tick:(id)sender;
- (void) die;

@end
