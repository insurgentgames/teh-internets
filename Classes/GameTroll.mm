#import "GameTroll.h"
#import "Game.h"
#import "OFAchievementService.h"
#import "Achievements.h"

@implementation GameTroll

@synthesize radius;
@synthesize level;

- (void) initTrollWithGame:(Game*)game andType:(GameTrollType)_type {
	NSLog(@"GameTroll init");
	
	g = game;
	type = _type;
	level = 0;
	
	// choose sprite
	switch(type) {
		case GameTrollTypeAverage:
			[self setTextureRect:CGRectMake(0, 0, 200, 200)];
			self.scale = 0.5;
			radius = 100 * self.scale;
			break;
		case GameTrollTypeRuthless:
			[self setTextureRect:CGRectMake(200, 0, 200, 200)];
			self.scale = 0.5;
			radius = 100 * self.scale;
			break;
		case GameTrollTypeFlaming:
			[self setTextureRect:CGRectMake(400, 0, 200, 200)];
			self.scale = 0.6;
			radius = 100 * self.scale;
			break;
	}
	
	// set up actions
	CGFloat y = arc4random() % 280;
	ccTime moveDuration = 7 / g.objectSpeed;
	//ccTime rotateDuration = arc4random() % 2 + 2; // 2 to 4 seconds
	self.position = CGPointMake(580, y);
	self.rotation = 0;
	
	// start moving and spinning
	[self runAction:[CCMoveTo actionWithDuration:moveDuration position:CGPointMake(-300, y)]];
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
	
	// if it's a flaming troll, launch an insult
	if(type == GameTrollTypeFlaming) {
		float insultTime = (1+arc4random()%3) / g.objectSpeed;
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:insultTime], 
						 [CCCallFunc actionWithTarget:self selector:@selector(launchInsult:)], 
						 nil]];
	}
}

- (int) feed {
	level++;
	if(level == 3) {
		[self die];
		((Game*)self.parent).trollsKilled++;
		
		if(((Game*)self.parent).trollsKilled == 20)
			[OFAchievementService unlockAchievement:ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB];
		
		return GameScoreTrollHitL3;
	}
	
	switch(type) {
		case GameTrollTypeAverage:
			switch(level) {
				case 1:
					self.scale = 0.4;
					radius = 100 * self.scale;
					break;
				case 2:
					self.scale = 0.2;
					radius = 30;
					break;
			}
			break;
		case GameTrollTypeRuthless:
			switch(level) {
				case 1:
					self.scale = 0.6;
					radius = 100 * self.scale;
					break;
				case 2:
					self.scale = 0.8;
					radius = 100 * self.scale;
					break;
			}
			break;
		case GameTrollTypeFlaming:
			switch(level) {
				case 1:
					self.scale = 0.8;
					radius = 100 * self.scale;
					break;
				case 2:
					self.scale = 1.0;
					radius = 100 * self.scale;
					break;
			}
			break;
	}
	
	switch(level) {
		case 1:
			return GameScoreTrollHitL1;
			break;
		case 2:
			return GameScoreTrollHitL2;
			break;
	}
	return 0;
}

- (void) tick:(id)sender {
	// delete myself if i'm off the screen
	CGRect largerThanScreen = CGRectMake(-100, -100, 980, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameTroll removing myself");
		[self die];
	}
}

- (void) launchInsult:(id)sender {
	[g launchInsultFrom:self.position];
}

- (void) die {
	NSLog(@"GameTroll die");
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

- (BOOL) touchedTroll:(CGPoint)location {
	if(ccpDistance(location, self.position) <= 2*radius) {
		NSLog(@"GameTroll troll was touched!");
		[g launchCheezburgerTowards:location];
		return YES;
	} else {
		return NO;
	}
}

@end
