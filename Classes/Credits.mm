#import "Credits.h"
#import "MainMenu.h"
#import "CreditChunk.h"

@implementation Credits

+ (id) scene {
	Credits* scene = [Credits node];
	return scene;
}

- (id) init {
	if((self = [super init])) {
		NSLog(@"Credits init");
		count = 0;
		
		// add the background
		CCSprite* background1 = [CCSprite spriteWithFile:@"Menu.png" rect:CGRectMake(0, 200, 480, 640)];
		background1.position = ccp(240,320);
		[background1 runAction:[CCRepeatForever 
								actionWithAction:[CCSequence actions:
												  [CCMoveTo actionWithDuration:40 position:ccp(240, -320)],
												  [CCMoveTo actionWithDuration:0 position:ccp(240, 320)], 
												  nil]]];
		CCSprite* background2 = [CCSprite spriteWithFile:@"Menu.png" rect:CGRectMake(0, 200, 480, 640)];
		background2.position = ccp(240,960);
		[background2 runAction:[CCRepeatForever 
								actionWithAction:[CCSequence actions:
												  [CCMoveTo actionWithDuration:40 position:ccp(240, 319)],
												  [CCMoveTo actionWithDuration:0 position:ccp(240, 959)], 
												  nil]]];
		[self addChild:background1 z:0];
		[self addChild:background2 z:0];
		
		// back button
		[CCMenuItemFont setFontSize:40];
        [CCMenuItemFont setFontName:@"AmericanTypewriter-Bold"];
		CCMenuItemFont* itemBack = [CCMenuItemFont itemFromString:@"go back" target:self selector:@selector(doBack:)];
		CCMenu* menu = [CCMenu menuWithItems:itemBack, nil];
		menu.position = ccp(240, 25);
		menu.opacity = 128;
		[self addChild:menu z:1];
		
		// now do all the instructions forever
		[self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
														 [CCCallFunc actionWithTarget:self selector:@selector(addChunk:)], 
														 [CCDelayTime actionWithDuration:3.0f], 
														 nil]]];
		
	}
	return self;
}

- (void) dealloc {
	NSLog(@"Credits dealloc");
	[super dealloc];
}

- (void)doBack:(id)sender {
	[[CCDirector sharedDirector] replaceScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[MainMenu scene]]];
}

- (void) addChunk:(id)sender {
	NSLog(@"Credits addChunk");
	
	CreditChunk* chunk = [CreditChunk node];
	NSString* str1 = @"";
	NSString* str2 = @"";
	NSString* str3 = @"";
	
	switch (count) {
		default:
		case 0:
			str1 = @"THE CREDITS";
			str2 = @"for teh internets";
			break;
		case 1:
			str1 = @"Insurgent Games";
			str2 = @"the BEST indie";
			str3 = @"game company EVER";
			break;
		case 2:
			str1 = @"Micah Lee";
			str2 = @"coding, graphics, sounds";
			str3 = @"computer hacking skillz";
			break;
		case 3:
			str1 = @"Kevin MacLeod";
			str2 = @"Creative Commons music";
			str3 = @"incompetech.com";
			break;
		case 4:
			str1 = @"Crystal Mayer";
			str2 = @"bouncer of ideas";
			break;
		case 5:
			str1 = @"cocos2d-iphone";
			str2 = @"sweet open source";
			str3 = @"game dev framework";
			break;
		case 6:
			str1 = @"OpenFeint";
			str2 = @"bringing the internet";
			str3 = @"to teh internets";
			break;
		case 7:
			str1 = @"TouchArcade Forums";
			str2 = @"for the ideas, inspiration,";
			str3 = @"and 1337 gamerz";
			break;
		case 8:
			str1 = @"Beta Testers:";
			str2 = @"Foozelz, derek420,";
			str3 = @"thenonsequitur";
			break;
		case 9:
			str1 = @"Dial-up Modems";
			str2 = @"for being awesome";
			str3 = @"but s...l...o...w";
			break;
		case 10:
			str1 = @"ASCII Art";
			str2 = @"for being awesome";
			break;
		case 11:
			str1 = @"EFF";
			str2 = @"for protecting our rights";
			str3 = @"eff.org";
			break;
		case 12:
			str1 = @"Noisebridge";
			str2 = @"bringin' the awesome sauce";
			str3 = @"noisebridge.net";
			break;
		case 13:
			str1 = @"HTTP";
			str2 = @"couldn't have done it";
			str3 = @"without this protocol";
			break;
		case 14:
			str1 = @"YOU!";
			str2 = @"for helping with rent";
			break;
	}
	
	[chunk initStr1:str1 str2:str2 str3:str3];
	[self addChild:chunk z:2];
	
	count++;
	if(count > 14)
		count = 0;
}

@end
