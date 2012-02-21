#import "cocos2d.h"
@class Game;
@class GameLolcatPhrase;

#define GameLolcatRadius 25

@interface GameLolcat : CCSprite {
	Game* g;
	GameLolcatPhrase* lolcatPhrase;
}

@property (nonatomic,retain) GameLolcatPhrase* lolcatPhrase;

- (void) initLolcatWithGame:(Game*)game;
- (void) tick:(id)sender;
- (void) die;

@end
