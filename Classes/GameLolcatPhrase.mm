#import "GameLolcatPhrase.h"
#import "GameLolcat.h"

@implementation GameLolcatPhrase

@synthesize lolcat;

- (void) initWithLolcat:(GameLolcat*)_lolcat {
	lolcat = _lolcat;
	
	// schedule tick
	[self schedule:@selector(tick:) interval:0.03f];
}

- (void) tick:(id)sender {
	if(lolcat != nil) {
		float y;
		// bottom half of screen
		if(lolcat.position.y < 160)
			y = lolcat.position.y+GameLolcatPhraseDistance;
		// top half of screen
		else
			y = lolcat.position.y-GameLolcatPhraseDistance;
		self.position = ccp(lolcat.position.x, y);
	}
	
	CGRect largerThanScreen = CGRectMake(-100, -100, 980, 520);
	if(!CGRectContainsPoint(largerThanScreen, self.position)) {
		// remove myself
		NSLog(@"GameLolcatPhrase removing myself");
		[self die];
	}
}

- (void) die {
	NSLog(@"GameLolcatPhrase die");
	if(lolcat != nil)
		lolcat.lolcatPhrase = nil;
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
