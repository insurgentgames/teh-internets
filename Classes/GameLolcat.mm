#import "GameLolcat.h"
#import "Game.h"

@implementation GameLolcat

@synthesize lolcatPhrase;

- (void) initLolcatWithGame:(Game*)game {
	NSLog(@"GameLolcat init");
	g = game;
	lolcatPhrase = nil;
	
	CGFloat y = arc4random() % 280;
	ccTime moveDuration = 5 / g.objectSpeed;
	ccTime rotateDuration = arc4random() % 2 + 2; // 2 to 4 seconds
	self.position = CGPointMake(580, y);
	self.rotation = arc4random() % 360;
	
	// start moving and spinning
	[self runAction:[CCMoveTo actionWithDuration:moveDuration position:CGPointMake(-300, y)]];
	[self runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:rotateDuration angle:360]]];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	CGRect largerThanScreen = CGRectMake(-100, -100, 980, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameLolcat removing myself");
		[self die];
	}
}

- (void) die {
	NSLog(@"GameLolcat die");
	if(lolcatPhrase != nil)
		[lolcatPhrase die];
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
