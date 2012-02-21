#import "GameLollerskater.h"
#import "Game.h"

@implementation GameLollerskater

- (void) initLollerskaterWithGame:(Game*)game {
	g = game;
	
	CCSpriteSheet* spriteSheet = [CCSpriteSheet spriteSheetWithFile:@"GameLollerskater.png"];
	CCAnimation* animation = [CCAnimation animationWithName:@"lollerskaterAnim" delay:0.25f];
	for(int frame=0; frame<3; frame++)
		[animation addFrameWithTexture:spriteSheet.texture rect:CGRectMake(0, frame*48, 39, 48)];
	[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
	self.position = ccp(519, 25);
	[self runAction:[CCMoveTo actionWithDuration:3.0 position:ccp(-100, 25)]];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	CGRect largerThanScreen = CGRectMake(-100, -100, 980, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameLollerskater removing myself");
		[g addScore:GameScoreLollerskaterHit];
		[self die];
	}
}

- (void) die {
	NSLog(@"GameLollerskater die");
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
