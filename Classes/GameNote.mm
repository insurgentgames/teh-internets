#import "GameNote.h"

@implementation GameNote

+ (GameNote*)noteWithString:(NSString*)string andPosition:(CGPoint)p {
	// init the note
	GameNote* note = [GameNote labelWithString:string fontName:@"AmericanTypewriter" fontSize:20];
	note.position = p;
	
	// set the actions
	CCDelayTime* delayTime = [CCDelayTime actionWithDuration:1.0];
	CCFadeTo* fadeTo = [CCFadeTo actionWithDuration:0.5 opacity:0];
	CCCallFunc* callFunc = [CCCallFunc actionWithTarget:note selector:@selector(die:)];
	[note runAction:[CCSequence actions:delayTime, fadeTo, callFunc, nil]];
	
	// return
	return note;
}

- (void) die:(id)sender {
	[self unschedule:@selector(tick:)];
	[self.parent removeChild:self cleanup:YES];
}

@end
