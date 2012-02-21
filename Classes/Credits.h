#import "cocos2d.h"

@interface Credits : CCScene {
	int count;
}

+ (id) scene;
- (void) doBack:(id)sender;
- (void) addChunk:(id)sender;

@end
