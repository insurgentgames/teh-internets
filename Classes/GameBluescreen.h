#import "cocos2d.h"

@interface GameBluescreen : CCLayer {
	CCSprite* bluescreen;
}

+ (id) scene;
- (void) epicFail:(id)sender;

@end
