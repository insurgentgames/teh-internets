#import "cocos2d.h"
@class Game;

#define GameLollerskaterRadius 37

@interface GameLollerskater : CCSprite {
	Game* g;
}

- (void) initLollerskaterWithGame:(Game*)game;
- (void) tick:(id)sender;
- (void) die;

@end
