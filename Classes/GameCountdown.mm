#import "GameCountdown.h"

@implementation GameCountdown

+ (GameCountdown*) countdown {
	GameCountdown* countdown = [GameCountdown labelWithString:@"5" fontName:@"AmericanTypewriter-Bold" fontSize:200];
	[countdown initCountdown];
	return countdown;
}

- (void) initCountdown {
	NSLog(@"GameCountdown init");
	counter = 6;
	self.position = ccp(240,160);
	[self bam:nil];
}

- (void) bam:(id)sender {
	counter--;
	if(counter > 0) {
		[self setString:[NSString stringWithFormat:@"%i", counter]];
		self.scale = 1.5;
		self.opacity = 255;
		[self runAction:[CCFadeTo actionWithDuration:1.0 opacity:0]];
		[self runAction:[CCScaleTo actionWithDuration:1.0 scale:0.5]];
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1.0], 
						 [CCCallFunc actionWithTarget:self selector:@selector(bam:)], 
						 nil]];
	} else {
		[self.parent removeChild:self cleanup:YES];
	}
}

@end
