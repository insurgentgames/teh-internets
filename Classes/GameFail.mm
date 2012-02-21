#import "GameFail.h"

@implementation GameFail

+ (GameFail*) fail {
	NSLog(@"GameFail creating a new fail");
	GameFail* fail = [GameFail spriteWithFile:@"GameFail.png"];
	fail.position = ccp(240, 160);
	[fail runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.2], 
					 [CCFadeTo actionWithDuration:0.1 opacity:0], 
					 [CCCallFunc actionWithTarget:fail selector:@selector(die:)], 
					 nil]];
	return fail;
}

- (void) die:(id)sender {
	[self.parent removeChild:self cleanup:YES];
}

@end
