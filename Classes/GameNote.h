#import "cocos2d.h"

@interface GameNote : CCLabel {
}

+ (GameNote*)noteWithString:(NSString*)string andPosition:(CGPoint)p;
- (void) die:(id)sender;

@end
