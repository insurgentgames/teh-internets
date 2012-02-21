#import "cocos2d.h"
@class Game;

#define GameInsultVelocity 7.0
#define GameInsultRadius 10

@interface GameInsult : CCSprite {
	Game* g;
	float angle;
}

- (void) initInsultWithGame:(Game*)game position:(CGPoint)p angle:(float)a;
- (void) tick:(id)sender;
- (void) die;

@end
