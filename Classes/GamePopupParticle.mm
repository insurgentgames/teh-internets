#import "GamePopupParticle.h"

@implementation GamePopupParticle

- (void) initPopupParticleWithPosition:(CGPoint)p {
	xinc = arc4random() % 5 + 10;
	if((int)(arc4random() % 2) == 0)
		xinc *= -1;
	yinc = arc4random() % 5 + 5;
	if((int)(arc4random() % 2) == 0)
		yinc *= -1;
	xinc *= 2;
	yinc *= 2;
	
	self.position = p;
	self.rotation = arc4random() % 360;
	
	// start moving and spinning
	[self runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0 angle:360]]];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	// update position
	self.position = CGPointMake(self.position.x+xinc, self.position.y+yinc);
	xinc--;
	
	CGRect largerThanScreen = CGRectMake(-100, -100, 980, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		[self die];
	}
}

- (void) die {
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
