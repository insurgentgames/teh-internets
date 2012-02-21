#import "OptionsMenu.h"
#import "Options.h"
#import "OpenFeint.h"
#import "OpenFeint+UserOptions.h"
#import "OFAchievementService+Private.h"
#import "OFAchievementService.h"
#import "Achievements.h"
#import "tehinternetsAppDelegate.h"

@implementation OptionsMenu

+ (id) sceneWithOptions:(Options*)_options music:(NSString*)_music startPaused:(BOOL)_paused {
	OptionsMenu* scene = [OptionsMenu node];
	[scene initWithOptions:_options music:_music startPaused:_paused];
	return scene;
}

- (void) initWithOptions:(Options*)_options music:(NSString*)_music startPaused:(BOOL)_paused {
	NSLog(@"OptionsMenu init");
	options = _options;
	music = _music;
	paused = _paused;
	
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
	
	// header
	CCSprite* header = [CCSprite spriteWithFile:@"Menu.png" rect:CGRectMake(0, 100, 480, 100)];
	header.position = ccp(240, 270);
	[self addChild:header z:1];	
	
	// is god mode enabled?
	bool rickRollEnabled;
	if(music == @"Menu.mp3") {
		rickRollEnabled = [OFAchievementService alreadyUnlockedAchievement:ACHIEVEMENT_GOD_MODE forUser:[OpenFeint lastLoggedInUserId]];
	} else {
		rickRollEnabled = NO;
	}
	
	// create the menu
	NSString* musicString;
	if(options.musicEnabled)
		musicString = @"music is ON";
	else
		musicString = @"music is OFF";
	NSString* soundString;
	if(options.soundEnabled)
		soundString = @"sound is ON";
	else
		soundString = @"sound is OFF";
	[CCMenuItemFont setFontSize:32];
	[CCMenuItemFont setFontName:@"AmericanTypewriter-Bold"];
	itemMusic = [CCMenuItemFont itemFromString:musicString target:self selector:@selector(doMusic:)];
	itemSound = [CCMenuItemFont itemFromString:soundString target:self selector:@selector(doSound:)];
	if(rickRollEnabled)
		itemRickTolld = [CCMenuItemFont itemFromString:@"god mode OFF" target:self selector:@selector(doRickRolld:)];
	CCMenuItemFont* itemBack = [CCMenuItemFont itemFromString:@"go back" target:self selector:@selector(doBack:)];
	CCMenu* menu;
	if(rickRollEnabled)
		menu = [CCMenu menuWithItems:itemMusic, itemSound, itemRickTolld, itemBack, nil];
	else
		menu = [CCMenu menuWithItems:itemMusic, itemSound, itemBack, nil];
	menu.position = ccp(240,110);
	[menu alignItemsVerticallyWithPadding:10];
	[self addChild:menu z:1];
}

- (void) dealloc {
	NSLog(@"OptionsMenu dealloc");
	[super dealloc];
}

- (void)doMusic:(id)sender {
	if(options.musicEnabled) {
		NSLog(@"OptionsMenu turning off music");
		[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) stopMusic];
		[itemMusic setString:@"music is OFF"];
		options.musicEnabled = NO;
		[options save];
	} else {
		NSLog(@"OptionsMenu turning on music");
		options.musicEnabled = YES;
		[options save];
		[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) startMusic:music];
		if(paused)
			[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) pauseMusic];
		[itemMusic setString:@"music is ON"];
	}
}

- (void)doSound:(id)sender {
	if(options.soundEnabled) {
		NSLog(@"OptionsMenu turning off sound");
		[itemSound setString:@"sound is OFF"];
		options.soundEnabled = NO;
		[options save];
	} else {
		options.soundEnabled = YES;
		[options save];
		NSLog(@"OptionsMenu turning on sound");
		[itemSound setString:@"sound is ON"];
	}
}

- (void)doRickRolld:(id)sender {
	[OFAchievementService unlockAchievement:ACHIEVEMENT_RICKROLLD];
	
	CCColorLayer* color = [CCColorLayer layerWithColor:ccc4(255,0,0,255)];
	[self addChild:color z:10];
	CCLabel* label1 = [CCLabel labelWithString:@"loading" fontName:@"AmericanTypewriter-Bold" fontSize:40];
	label1.position = ccp(240,190);
	[self addChild:label1 z:11];
	CCLabel* label2 = [CCLabel labelWithString:@"GOD MODE" fontName:@"AmericanTypewriter-Bold" fontSize:60];
	label2.position = ccp(240,130);
	[self addChild:label2 z:11];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:2.0],
					 [CCCallFunc actionWithTarget:self selector:@selector(rickRolld:)],
					 nil]];
}

- (void)rickRolld:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/watch?v=oHg5SJYRHA0"]];
}

- (void)doBack:(id)sender {
	[[CCDirector sharedDirector] popScene];
}

@end
