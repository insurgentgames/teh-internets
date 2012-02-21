#import "GameBluescreen.h"
#import "MainMenu.h"
#import "tehinternetsAppDelegate.h"

@implementation GameBluescreen

+ (id) scene {
	CCScene* scene = [CCScene node];
	GameBluescreen* layer = [GameBluescreen node];
	[scene addChild:layer];
	return scene;
}

- (id) init {
	if((self = [super init])) {
		NSLog(@"GameBluescreen init");
		
		// add the blue screen of death
		bluescreen = [CCSprite spriteWithFile:@"GameBluescreen.png" rect:CGRectMake(0, 0, 480, 320)];
		bluescreen.position = ccp(240, 160);
		[self addChild:bluescreen];
		
		// schedule the EPIC FAIL
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1.5], 
						 [CCCallFunc actionWithTarget:self selector:@selector(epicFail:)], 
						 nil]];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"GameBluescreen dealloc");
	[super dealloc];
}

- (void) epicFail:(id)sender {
	// switch to epic fail frame
	[bluescreen setTextureRect:CGRectMake(0, 320, 480, 320)];
	
	// play crash sound
	[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) playSound:@"PopupCrash.wav"];
	
	// add tap to continue
	CCLabel* tap = [CCLabel labelWithString:@"tap to continue" fontName:@"AmericanTypewriter" fontSize:20];
	tap.position = ccp(400,20);
	tap.opacity = 0;
	[self addChild:tap z:10];
	[tap runAction:[CCSequence actions:
					[CCDelayTime actionWithDuration:0.2], 
					[CCFadeTo actionWithDuration:0.5 opacity:255], 
					nil]];
	
	// enable touches
	self.isTouchEnabled = YES;
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// start the menu music
	[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) startMusic:@"Menu.mp3"];
	
	// go to main menu
	[[CCDirector sharedDirector] replaceScene:[CCFadeTRTransition transitionWithDuration:0.5 scene:[MainMenu scene]]];
	
	// load leaderboards
	[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) openHighScores];
	
	//return kEventHandled;
}

@end

