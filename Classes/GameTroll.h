#import "cocos2d.h"
@class Game;

typedef enum {
	GameTrollTypeAverage = 0,
	GameTrollTypeRuthless = 1,
	GameTrollTypeFlaming = 2
} GameTrollType;

@interface GameTroll : CCSprite {
	Game* g;
	GameTrollType type;
	float radius;
	int level;
}

@property (readonly) float radius;
@property (readonly) int level;

- (void) initTrollWithGame:(Game*)game andType:(GameTrollType)_type;
- (int) feed;
- (void) tick:(id)sender;
- (void) launchInsult:(id)sender;
- (void) die;
- (BOOL) touchedTroll:(CGPoint)location;

@end
