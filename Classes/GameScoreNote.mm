#import "GameScoreNote.h"

@implementation GameScoreNote

- (void) initWithScore:(NSUInteger)score andPosition:(CGPoint)p {
	CGRect rect;
	if(score >= 1 && score <= 9)
		rect = CGRectMake(80*(score-1), 0, 80, 30);
	else
		rect = CGRectMake(0, 0, 80, 30);
	
	[self setTextureRect:rect];
	self.position = p;
	self.scale = 0.3;
	
	// all the actions
	[self runAction:[CCScaleTo actionWithDuration:1.0 scale:1]];
	[self runAction:[CCFadeTo actionWithDuration:1.0 opacity:0.0]];
	[self runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(p.x,p.y+50)]];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:1.0], 
					 [CCCallFunc actionWithTarget:self selector:@selector(die:)], 
					 nil]];
}

- (void) die:(id)sender {
	[self.parent removeChild:self cleanup:YES];
}

@end
