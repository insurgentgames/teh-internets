#import "cocos2d.h"
@class Game;

#define GameVirusVelocity 5.0
#define GameVirusRadius 15

@interface GameVirus : CCSprite {
	Game* g;
	float angle;
	float angleInc;
	BOOL hit;
}

@property (readwrite) BOOL hit;

- (void) initVirusWithGame:(Game*)game;
- (void) tick:(id)sender;
- (void) die;

@end
