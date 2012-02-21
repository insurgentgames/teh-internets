#import "GameCheezburger.h"
#import "Game.h"

@implementation GameCheezburger

- (void) initCheezburgerWithGame:(Game*)game position:(CGPoint)p angle:(float)a {
	NSLog(@"Initiating cheezburger");
	g = game;
	self.position = p;
	angle = a;
	self.rotation = 360-angle;
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}


- (void) tick:(id)sender {
	// update position
	CGFloat x = self.position.x + GameCheezburgerVelocity*g.objectSpeed*cos(angle*M_PI/180);
	CGFloat y = self.position.y + GameCheezburgerVelocity*g.objectSpeed*sin(angle*M_PI/180);
	self.position = CGPointMake(x, y);
	
	// flown off screen?
	CGRect largerThanScreen = CGRectMake(-100, -100, 680, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameCheezburger removing myself");
		[self die];
	}
}

- (void) die {
	NSLog(@"GameCheezburger die");
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end

