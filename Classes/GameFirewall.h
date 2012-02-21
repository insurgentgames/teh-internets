#import "cocos2d.h"
@class Game;

#define GameFirewallRadius 15

@interface GameFirewall : CCLayer {
	Game* g;
	BOOL hit;
}

@property (readwrite) BOOL hit;

- (void) initFirewallWithGame:(Game*)game;
- (BOOL) collideWith:(CGPoint)p radius:(float)r;
- (void) die;

@end
