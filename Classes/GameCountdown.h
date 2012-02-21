#import "cocos2d.h"

@interface GameCountdown : CCLabel {
	int counter;
}

+ (GameCountdown*) countdown;
- (void) initCountdown;
- (void) bam:(id)sender;

@end
