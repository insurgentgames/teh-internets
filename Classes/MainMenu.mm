#import "MainMenu.h"
#import "Game.h"
#import "Credits.h"
#import "OptionsMenu.h"
#import "OpenFeint.h"
#import "OpenFeint+Dashboard.h"
#import "Stats.h"
#import "tehinternetsAppDelegate.h"
#import "AchievementsScene.h"

@implementation MainMenu

+ (id) scene {
	MainMenu* scene = [MainMenu node];
	return scene;
}

- (id) init {
	if((self = [super init])) {
		NSLog(@"MainMenu init");
		
		stats = ((tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate)).stats;
		
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
		CCSprite* header = [CCSprite spriteWithFile:@"Menu.png" rect:CGRectMake(0, 0, 480, 100)];
		header.position = ccp(240, 270);
		[self addChild:header z:1];
		
		// roflcopter
		CCSpriteSheet* roflcopterSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"MainMenuRoflcopter.png"];
		CCAnimation* roflcopterAnimation = [CCAnimation animationWithName:@"MainMenuRoflcopter" delay:0.1f];
		for(int i=0;i<5;i++)
			[roflcopterAnimation addFrameWithTexture:roflcopterSpriteSheet.texture rect:CGRectMake(0, i*112, 160, 112)];
		CCSprite* roflcopter = [CCSprite spriteWithFile:@"MainMenuRoflcopter.png" rect:CGRectMake(0, 0, 160, 112)];
		[roflcopter runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:roflcopterAnimation]]];
		[roflcopter runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
																 [CCRotateBy actionWithDuration:1.0 angle:10], 
																 [CCRotateBy actionWithDuration:1.0 angle:-10], 
																 nil]]];
		roflcopter.position = ccp(350, 130);
		roflcopter.scale = 1.4;
		[self addChild:roflcopter z:2];
		
		// create the menu
		[CCMenuItemFont setFontSize:25];
        [CCMenuItemFont setFontName:@"AmericanTypewriter-Bold"];
		CCMenuItem* itemPlay			= [CCMenuItemFont itemFromString: @"play!" target:self selector:@selector(onPlay:)];
		CCMenuItem* itemInstructions	= [CCMenuItemFont itemFromString: @"help" target:self selector:@selector(onInstructions:)];
		CCMenuItem* itemOptions			= [CCMenuItemFont itemFromString: @"options" target:self selector:@selector(onOptions:)];
		CCMenuItem* itemLeaderboards	= [CCMenuItemFont itemFromString: @"leaderboards" target:self selector:@selector(onLeaderboards:)];
		CCMenuItem* itemAchievements	= [CCMenuItemFont itemFromString: @"achievements" target:self selector:@selector(onAchievements:)];
		CCMenuItem* itemOtherGames		= [CCMenuItemFont itemFromString: @"other_games" target:self selector:@selector(onOtherGames:)];
		CCMenuItem* itemCredits			= [CCMenuItemFont itemFromString: @"credz" target:self selector:@selector(onCredits:)];
		CCMenu *menu = [CCMenu menuWithItems: itemPlay, itemInstructions, itemOptions, itemLeaderboards, itemAchievements, itemOtherGames, itemCredits, nil];
		[menu alignItemsVerticallyWithPadding:0];
		menu.position = ccp(120, 115);
		[self addChild: menu z:2];
		
		// total time wasted in the bottom right
		int hoursWasted = (int)(stats.totalTimeWasted / 3600);
		int minutesWasted = (int)(stats.totalTimeWasted / 60) - 60*hoursWasted;
		int secondsWasted = stats.totalTimeWasted - 60*minutesWasted;
		NSString* timeWastedString = [NSString stringWithFormat:@"%i hours, %i minutes, %i seconds", hoursWasted, minutesWasted, secondsWasted];
		CCLabel* timeWasted1 = [CCLabel labelWithString:@"total time wasted" fontName:@"Arial-BoldMT" fontSize:15];
		timeWasted1.position = ccp(350, 30);
		timeWasted1.opacity = 128;
		[self addChild:timeWasted1 z:3];
		CCLabel* timeWasted2 = [CCLabel labelWithString:timeWastedString fontName:@"Arial-BoldMT" fontSize:15];
		timeWasted2.position = ccp(350, 15);
		timeWasted2.opacity = 128;
		[self addChild:timeWasted2 z:3];
		
	}
	return self;
}

- (void) dealloc {
	NSLog(@"MainMenu dealloc");
	[super dealloc];
}

- (void) onPlay:(id)sender {
	// stop menu music
	[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) stopMusic];
	
	// play game
	[[CCDirector sharedDirector] replaceScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[Game sceneGame]]];
}

- (void) onInstructions:(id)sender {
	[[CCDirector sharedDirector] replaceScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[Game sceneInstructions]]];
}

- (void) onOptions:(id)sender {
	[[CCDirector sharedDirector] pushScene:
	 [CCFadeBLTransition transitionWithDuration:0.5 scene:
	  [OptionsMenu sceneWithOptions:[(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) options] music:@"Menu.mp3" startPaused:NO]]];
}

- (void) onLeaderboards:(id)sender {
	[OpenFeint launchDashboardWithListLeaderboardsPage];
}

- (void) onAchievements:(id)sender {
	// if OF is enabled
	if([OpenFeint hasUserApprovedFeint]) {
		[OpenFeint launchDashboardWithAchievementsPage];
	}
	// OF is not enabled, so use my own achievements
	else {
		NSLog(@"Loading my own custom achievements");
		[[CCDirector sharedDirector] pushScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[AchievementsScene scene]]];
	}
}

- (void) onOtherGames:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://othergames.insurgentgames.com/teh-internets/"]];
}

- (void) onCredits:(id)sender {
	[[CCDirector sharedDirector] replaceScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[Credits scene]]];
}

@end
