#import "cocos2d.h"

#define GamePlayerMaxVelocity 8.0
#define GamePlayerFriction 0.8
#define GamePlayerRadius 40

@interface GamePlayer : CCSprite {
	CGFloat velocity;
	CGFloat angle;
	
	BOOL invincible;
}

@property (readwrite) CGFloat velocity;
@property (readwrite) CGFloat angle;
@property (readonly) BOOL invincible;

- (void) initPlayer;
- (void) update:(BOOL)pushingDPad;
- (void) becomeInvincible:(NSUInteger)seconds;
- (void) notInvincible:(id)sender;

@end
