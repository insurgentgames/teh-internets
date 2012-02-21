#import "cocos2d.h"

typedef enum {
	GameMessageTypeSpeedIncrease = 0,
	GameMessageTypeAverageTrolls = 1,
	GameMessageTypeVirii = 2,
	GameMessageTypeRuthlessTrolls = 3,
	GameMessageTypeFlamingTrolls = 4,
	GameMessageTypeFirewalls = 5,
	GameMessageTypeLolcats = 6,
	GameMessageTypePopups = 7
} GameMessageType;

@interface GameMessage : CCSprite {
}

- (void) initMessageWithType:(GameMessageType)type;
- (void) die:(id)sender;

@end
