#import "GameStuff.h"
#import "Game.h"

@implementation GameStuff

@synthesize game;

- (id) init {
	if((self = [super init])) {
		paused = NO;
	}
	return self;
}

- (void) onEnter {
	if(!paused) {
		[super onEnter];
		// schedule selectors here
		//[self schedule:@selector(step:)];
	}
}

- (void) onExit {
	if(!paused) {
		[super onExit];
	}
}

- (void) pause {
	if(paused) {
		return;
	}
	
	[self onExit];
	paused = YES;
}

- (void) resume {
	if(!paused) {
		return;
	}
	
	paused = NO;
	[self onEnter];
}

- (void) launch {
	[game launch];
}

- (void) newObject {
	[game newObject];
}

- (void) speedIncrease {
	[game speedIncrease];
}

- (void) checkAchievements {
	[game checkAchievements];
}

- (void) instructionsLaunch {
	[game instructionsLaunch];
}

@end
