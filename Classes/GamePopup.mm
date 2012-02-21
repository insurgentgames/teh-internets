#import "GamePopup.h"
#import "Game.h"
#import "time.h"

@implementation GamePopup

- (void) initPopupWithGame:(Game*)game {
	g = game;
	
	NSLog(@"Initiating popup window");
	CGFloat y = arc4random() % 280;
	//ccTime moveDuration = arc4random() % 3 + 3; // 3 to 6 seconds
	ccTime moveDuration = 5 / g.objectSpeed;
	ccTime rotateDuration = arc4random() % 2 + 7; // 7 to 9 seconds
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
		NSLog(@"GamePopup removing myself");
		[g launchScoreNoteScore:GameScorePopupMiss position:ccp(10,self.position.y)];
		[g addScore:GameScorePopupMiss];
		[self die];
	}
}

- (void) die {
	NSLog(@"GamePopup die");
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
