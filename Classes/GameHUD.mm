#import "GameHUD.h"
#import "Game.h"
#import "GameTroll.h"
#include "math.h"

@implementation GameHUD

@synthesize dPadLayer;
@synthesize brb;
@synthesize score;
@synthesize paused;

-(id) init {
	if((self = [super init])) {
		paused = NO;
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// d-pad
		dPadLayer = [CCLayer node];
		dPadCircle = [CCSprite spriteWithFile:@"GameHUDDPad.png" rect:CGRectMake(0, 0, 100, 100)];
		dPadCircle.position = ccp(GameHUDDPadX, GameHUDDPadY);
		[dPadLayer addChild:dPadCircle z:0];
		dPadTouch = [CCSprite spriteWithFile:@"GameHUDDPad.png" rect:CGRectMake(100, 0, 45, 45)];
		dPadTouch.position = ccp(GameHUDDPadX, GameHUDDPadY);
		dPadTouch.opacity = 0;
		[dPadLayer addChild:dPadTouch z:1];
		[self addChild:dPadLayer z:0];
		
		// dark bar
		CCColorLayer* dark = [CCColorLayer layerWithColor:ccc4(0,0,0,255)];
		dark.contentSize = CGSizeMake(480,40);
		dark.position = ccp(0,280);
		dark.opacity = 175;
		[self addChild:dark z:-1];
		
		// lives
		livesLayer = [CCLayer node];
		[self addChild:livesLayer z:0];
		for(int i=0; i<GameMaxLives; i++) {
			CCSprite* life = [CCSprite spriteWithFile:@"GameLollerskaterLife.png" rect:CGRectMake(0, 0, 30, 36)];
			CCSpriteSheet* spriteSheet = [CCSpriteSheet spriteSheetWithFile:@"GameLollerskaterLife.png"];
			CCAnimation* lifeAnim = [CCAnimation animationWithName:@"lifeAnim" delay:0.25f];
			for(int frame=0; frame<3; frame++)
				[lifeAnim addFrameWithTexture:spriteSheet.texture rect:CGRectMake(0, frame*36, 30, 36)];
			[life runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:lifeAnim]]];
			life.position = ccp(20+i*35, 300);
			life.opacity = 50;
			[livesLayer addChild:life z:0 tag:100+i];
		}
		
		// score
		score = [CCLabel labelWithString:@"Score: 0" fontName:@"AmericanTypewriter" fontSize:18];
		score.position = ccp(289,300);
		[self addChild:score z:0];
		
		// pause
		brb = [CCLabel labelWithString:@"brb" fontName:@"AmericanTypewriter-Bold" fontSize:32];
		brb.position = ccp(440, 300);
		[self addChild:brb z:0 tag:GameHUDTagPause];
		
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) handleTouches:(NSSet *)touches withEvent:(UIEvent *)event {
	if(paused)
		return;
		//return kEventIgnored;
	
	UITouch* touch;
	NSEnumerator *e = [touches objectEnumerator];
	while((touch = (UITouch*)[e nextObject])) {
		CGPoint touchPoint = [touch locationInView: [touch view]];
		CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];
		
		// touching the d-pad
		if(ccpDistance(CGPointMake(GameHUDDPadX, GameHUDDPadY), location) <= GameHUDRadius) {
			// and in which direction is it pointing?
			CGFloat angle = atan2(location.y - GameHUDDPadY, location.x - GameHUDDPadX) * 180 / M_PI;
			if(angle < 0)
				angle += 360;
			
			// display the d-pad touch circle
			dPadTouch.position = location;
			dPadTouch.opacity = 255;
			
			// let the game know what's being pushed
			[(Game*)self.parent doPushDPad:angle];
			return;
			//return kEventHandled;
		}
	}
	
	// pass it on to the next
	//return kEventIgnored;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//return [self handleTouches:touches withEvent:event];
	[self handleTouches:touches withEvent:event];
}

- (void) ccTouchesMoved:(NSMutableSet *)touches withEvent:(UIEvent *)event {
	//return [self handleTouches:touches withEvent:event];
	[self handleTouches:touches withEvent:event];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(paused)
		return;
		//return kEventIgnored;
	
	dPadTouch.opacity = 0;
	[(Game*)self.parent doLetGo];
	
	UITouch *touch = [touches anyObject];
	if(touch) {
		CGPoint touchPoint = [touch locationInView: [touch view]];
		CGPoint location = [[CCDirector sharedDirector] convertToGL:touchPoint];
		
		CGRect rect;
		
		// pause?
		rect = CGRectMake(brb.position.x-brb.contentSize.width/2, brb.position.y-brb.contentSize.height/2, brb.contentSize.width, brb.contentSize.height);
		if(CGRectContainsPoint(rect, location)) {
			[(Game*)self.parent doPause];
			return;
			//return kEventHandled;
		}
		
		// make sure trolls don't get fed if the touch is over the d-pad
		if(ccpDistance(CGPointMake(GameHUDDPadX, GameHUDDPadY), location) > GameHUDRadius) {
			// touching a troll
			GameTroll* troll;
			for(troll in [((Game*)self.parent).trollLayer children]) {
				if([troll touchedTroll:location])
					return;
					//return kEventHandled;
			}
		}
		
		// no other handlers will receive this event
		return;
		//return kEventIgnored;
	}
	
	// we ignore the event
	return;
	//return kEventIgnored;
}

- (void)ccTouchesCancelled:(NSMutableSet *)touches withEvent:(UIEvent *)event {
	// the player is no longer holding up or down
	[(Game*)self.parent doLetGo];
	
	// we ignore the event
	return;
	//return kEventIgnored;
}

- (void) updateLives {
	Game* game = (Game*)self.parent;
	for(int i=0; i<GameMaxLives; i++) {
		CCSprite* life = (CCSprite*)[livesLayer getChildByTag:100+i];
		if(i < game.lives)
			life.opacity = 255;
		else
			life.opacity = 50;
	}
}

@end
