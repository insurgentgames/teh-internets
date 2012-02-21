#import "GameInsult.h"
#import "Game.h"

@implementation GameInsult

- (void) initInsultWithGame:(Game*)game position:(CGPoint)p angle:(float)a {
	NSLog(@"Initiating insult");
	
	g = game;
	self.position = p;
	angle = a;
	self.rotation = 360-angle;
	
	// choose a random insult
	int rand = (int)(arc4random()%4);
	[self setTextureRect:CGRectMake(600, rand*25, 50, 25)];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}


- (void) tick:(id)sender {
	// update position
	CGFloat x = self.position.x + GameInsultVelocity*g.objectSpeed*cos(angle*M_PI/180);
	CGFloat y = self.position.y + GameInsultVelocity*g.objectSpeed*sin(angle*M_PI/180);
	self.position = CGPointMake(x, y);
	
	// flown off screen?
	CGRect largerThanScreen = CGRectMake(-100, -100, 680, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameInsult removing myself");
		[self die];
	}
}

- (void) die {
	NSLog(@"GameInsult die");
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
