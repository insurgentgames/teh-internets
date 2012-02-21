#import "GameBackground.h"
#import "Game.h"

@implementation GameBackground

@synthesize speed;

- (void) initBackground {
	speed = 1.0;
	
	// static
	slow1 = [CCSprite spriteWithFile:@"GameBackgroundSlow.png"];
	slow1.position = ccp(320, 160);
	[self addChild:slow1 z:0];
	slow2 = [CCSprite spriteWithFile:@"GameBackgroundSlow.png"];
	slow2.position = ccp(959, 160);
	[self addChild:slow2 z:0];
	
	// fast
	fast1 = [CCSprite spriteWithFile:@"GameBackgroundFast.png"];
	fast1.position =  ccp(512, 160);
	[self addChild:fast1 z:1];
	fast2 = [CCSprite spriteWithFile:@"GameBackgroundFast.png"];
	fast2.position = ccp(1536, 160);
	[self addChild:fast2 z:1];
	
	// schedule the update
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	float x;
	
	// slow1
	x = slow1.position.x - (GameBackgroundSlowVelocity*speed);
	if(x <= -320)
		x += 640;
	slow1.position = ccp(x, 160);
	
	// slow2
	x = slow2.position.x - (GameBackgroundSlowVelocity*speed);
	if(x <= 319)
		x += 640;
	slow2.position = ccp(x, 160);
	
	// fast1
	x = fast1.position.x - (GameBackgroundFastVelocity*speed);
	if(x <= -512)
		x += 1024;
	fast1.position = ccp(x, 160);
	
	// fast2
	x = fast2.position.x - (GameBackgroundFastVelocity*speed);
	if(x <= 511)
		x += 1024;
	fast2.position = ccp(x, 160);
}

@end
