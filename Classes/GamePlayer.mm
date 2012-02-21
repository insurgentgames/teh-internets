#import "GamePlayer.h"

@implementation GamePlayer

@synthesize velocity;
@synthesize angle;
@synthesize invincible;

- (void) initPlayer {
	self.position = CGPointMake(100, 160);
	
	velocity = 0;
	angle = 0;
	
	invincible = NO;
}

- (void) update:(BOOL)pushingDPad {
	// update acceleration
	if(pushingDPad) {
		velocity = GamePlayerMaxVelocity;
	} else {
		// account for friction
		if(velocity > 0) {
			velocity -= GamePlayerFriction;
			if(velocity < 0)
				velocity = 0;
		}
	}
	
	// update position
	CGFloat x = self.position.x + velocity*cos(angle*M_PI/180);
	CGFloat y = self.position.y + velocity*sin(angle*M_PI/180);
	self.position = CGPointMake(x, y);
	
	// make sure player doesn't fly off the screen
	BOOL stop = NO;
	if(self.position.y > 280 - GamePlayerRadius/2) {
		y = 280 - GamePlayerRadius/2;
		stop = YES;
	}
	if(self.position.y < GamePlayerRadius/2) {
		y = GamePlayerRadius/2;
		stop = YES;
	}
	if(self.position.x > 480 - GamePlayerRadius/2) {
		x = 480 - GamePlayerRadius/2;
		stop = YES;
	}
	if(self.position.x < GamePlayerRadius/2) {
		x = GamePlayerRadius/2;
		stop = YES;
	}
	if(stop) {
		velocity = 0;
	}
	self.position = CGPointMake(x, y);
	
	// update the rotation
	BOOL left, right;
	if(pushingDPad) {
		left = (angle >= 90 && angle < 270);
		right = ((angle >= 0 && angle < 90) || (angle >= 270 && angle < 360));
	} else {
		left = NO;
		right = NO;
	}
	
	CGFloat r;
	if(left)
		r = 350;
	else if(right)
		r = 10;
	else
		r = 0;
	if(r != self.rotation) {
		self.rotation = r;
	}
}

- (void) becomeInvincible:(NSUInteger)seconds {
	NSLog(@"GamePlayer becoming invincible");
	invincible = YES;
	CCRepeatForever* invincibleAction = [CCRepeatForever actionWithAction:[CCSequence actions:
														[CCFadeTo actionWithDuration:0.6 opacity:0], 
														[CCFadeTo actionWithDuration:0.6 opacity:150], 
														nil]];
	invincibleAction.tag = 0;
	[self runAction:invincibleAction];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:seconds], 
					 [CCCallFunc actionWithTarget:self selector:@selector(notInvincible:)], 
					 nil]];
}

- (void) notInvincible:(id)sender {
	NSLog(@"GamePlayer not invincible");
	invincible = NO;
	self.opacity = 255;
	[self stopActionByTag:0];
}

@end
