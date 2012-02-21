#import "GameMessage.h"

@implementation GameMessage

- (void) initMessageWithType:(GameMessageType)type {
	[self setTextureRect:CGRectMake(0, type*100, 480, 100)];
	self.position = ccp(240, -100);
	self.opacity = 200;
	[self runAction:[CCSequence actions:
						[CCMoveTo actionWithDuration:2.8 position:ccp(240,530)], 
						[CCCallFunc actionWithTarget:self selector:@selector(die:)], 
						nil]];
}

- (void) die:(id)sender {
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
