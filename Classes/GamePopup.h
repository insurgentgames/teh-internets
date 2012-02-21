#import "cocos2d.h"
@class Game;

#define GamePopupRadius 43

@interface GamePopup : CCSprite {
	Game* g;
}

- (void) initPopupWithGame:(Game*)game;
- (void) tick:(id)sender;
- (void) die;

@end
