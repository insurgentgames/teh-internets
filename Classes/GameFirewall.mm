#import "GameFirewall.h"
#import "Game.h"
#import "Achievements.h"
#import "tehinternetsAppDelegate.h"

@implementation GameFirewall

@synthesize hit;

- (void) initFirewallWithGame:(Game*)game {
	g = game;
	hit = NO;
	
	// figure out the y coordinates for the particle systems
	int y[6];
	switch ((int)(arc4random()%3)) {
		case 0:
			// hole at top
			y[0] = -15; y[1] = 15; y[2] = 45; y[3] = 75; y[4] = 105; 
			y[5] = 295;
			break;
		
		case 1:
			// hole at middle
			y[0] = -15; y[1] = 15; y[2] = 43;
			y[3] = 235; y[4] = 268; y[5] = 295;
			break;
			
		case 2:
			// hole at bottom
			y[0] = -15;
			y[1] = 175; y[2] = 205; y[3] = 235; y[4] = 265; y[5] = 295;
			break;
	}
	
	// add the particle systems as children
	CCParticleFire* emitter;
	for(int i=0; i<6; i++) {
		emitter = [CCParticleFire node];
		emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
		emitter.position = ccp(0, y[i]);
		emitter.angle = 0;
		emitter.speed = 0;
		emitter.speedVar = 0.5;
		emitter.totalParticles = 12;
		emitter.life = 0.3;
		emitter.posVar = CGPointMake(16,20);
		[self addChild:emitter];
	}
	
	// make the whole firewall move from right to left
	ccTime moveDuration = 3 / g.objectSpeed;
	self.position = ccp(580, 0);
	[self runAction:[CCSequence actions:
					 [CCMoveTo actionWithDuration:moveDuration position:ccp(-100, 0)], 
					 [CCCallFunc actionWithTarget:self selector:@selector(die)], 
					 nil]];
}

- (BOOL) collideWith:(CGPoint)p radius:(float)r {
	BOOL ret = NO;
	CCParticleFire* emitter;
	for(emitter in [self children]) {
		if(ccpDistance(p, ccp(self.position.x, emitter.position.y)) <= GameFirewallRadius + r)
			ret = YES;
	}
	return ret;
}

- (void) die {
	NSLog(@"GameFirewall die");
	
	if(!hit) {
		[g launchScoreNoteScore:GameScoreFirewallMiss position:ccp(10,140)];
		[g addScore:GameScoreFirewallMiss];
		g.firewallsPassed++;
		if(g.firewallsPassed == 10) {
			tehinternetsAppDelegate* appDelegate = ((tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate));
			[appDelegate unlockAchievement:ACHIEVEMENT_THE_BACKDOOR];
		}
	}
	
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
