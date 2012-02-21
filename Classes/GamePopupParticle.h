#import "cocos2d.h"

@interface GamePopupParticle : CCSprite {
	float xinc;
	float yinc;
}

- (void) initPopupParticleWithPosition:(CGPoint)p;
- (void) tick:(id)sender;
- (void) die;

@end
