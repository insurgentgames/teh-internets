#import "cocos2d.h"

@interface GameScoreNote : CCSprite {

}

- (void) initWithScore:(NSUInteger)score andPosition:(CGPoint)p;
- (void) die:(id)sender;

@end
