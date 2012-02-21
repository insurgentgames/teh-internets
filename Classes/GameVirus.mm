#import "GameVirus.h"
#import "Game.h"

@implementation GameVirus

@synthesize hit;

- (void) initVirusWithGame:(Game*)game {
	NSLog(@"Initiating virus");
	g = game;
	
	// either top or bottom of screen
	float y;
	int rand = (int)(arc4random()%2);
	if(rand == 0) {
		y = 50;
		angle = 359;
		angleInc = -0.07*g.objectSpeed;
	} else {
		y = 230;
		angle = 1;
		angleInc = 0.07*g.objectSpeed;
	}
	self.position = ccp(-90, y);
	
	// start the animation
	CCSpriteSheet* spriteSheet = [CCSpriteSheet spriteSheetWithFile:@"GameVirus.png"];
	CCAnimation* animation = [CCAnimation animationWithName:@"GameVirus" delay:0.1f];
	for(int i=0; i<4; i++)
		[animation addFrameWithTexture:spriteSheet.texture rect:CGRectMake(40*i, 0, 40, 40)];
	[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]]];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	// update position
	CGFloat x = self.position.x + GameVirusVelocity*g.objectSpeed*cos(angle*M_PI/180);
	CGFloat y = self.position.y + GameVirusVelocity*g.objectSpeed*sin(angle*M_PI/180);
	self.position = CGPointMake(x, y);
	
	// update angle
	angle += angleInc;
	if(angle < 0) angle += 360;
	if(angle >= 360) angle -= 360;
	self.rotation = 360 - angle;
	
	// flown off screen?
	CGRect largerThanScreen = CGRectMake(-100, -100, 680, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameVirus removing myself");
		[self die];
	}
}

- (void) die {
	NSLog(@"GameVirus die");
	
	if(!hit) {
		[g launchScoreNoteScore:GameScoreVirusMiss position:ccp(470,self.position.y)];
		[g addScore:GameScoreVirusMiss];
	}	
	
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
