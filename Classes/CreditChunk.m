#import "CreditChunk.h"

@implementation CreditChunk

- (void) initStr1:(NSString*)str1 str2:(NSString*)str2 str3:(NSString*)str3 {
	// label1
	CCLabel* label1 = [CCLabel labelWithString:str1 fontName:@"AmericanTypewriter-Bold" fontSize:40];
	label1.position = ccp(680,CreditChunkY1);
	label1.opacity = 0;
	[label1 runAction:[CCSequence actions:
					[CCFadeTo actionWithDuration:0.5f opacity:255], 
					[CCDelayTime actionWithDuration:2.5f], 
					[CCFadeTo actionWithDuration:0.5f opacity:0], 
					nil]];
	[label1 runAction:[CCSequence actions:
					[CCMoveTo actionWithDuration:0.5f position:ccp(240,CreditChunkY1)], 
					[CCDelayTime actionWithDuration:2.5f], 
					[CCMoveTo actionWithDuration:0.5f position:ccp(-200,CreditChunkY1)], 
					nil]];
	[self addChild:label1];
	
	// label2
	CCLabel* label2 = [CCLabel labelWithString:str2 fontName:@"AmericanTypewriter-Bold" fontSize:30];
	label2.position = ccp(680,CreditChunkY2);
	label2.opacity = 0;
	[label2 runAction:[CCSequence actions:
					[CCDelayTime actionWithDuration:0.5f], 
					[CCFadeTo actionWithDuration:0.5f opacity:255], 
					[CCDelayTime actionWithDuration:2.0f], 
					[CCFadeTo actionWithDuration:0.5f opacity:0], 
					nil]];
	[label2 runAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.5f], 
					   [CCMoveTo actionWithDuration:0.5f position:ccp(240,CreditChunkY2)], 
					   [CCDelayTime actionWithDuration:2.0f], 
					   [CCMoveTo actionWithDuration:0.5f position:ccp(-200,CreditChunkY2)], 
					   nil]];
	[self addChild:label2];
	
	// label3
	CCLabel* label3 = [CCLabel labelWithString:str3 fontName:@"AmericanTypewriter-Bold" fontSize:30];
	label3.position = ccp(680,CreditChunkY3);
	label3.opacity = 0;
	[label3 runAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.8f], 
					   [CCFadeTo actionWithDuration:0.5f opacity:255], 
					   [CCDelayTime actionWithDuration:1.7f], 
					   [CCFadeTo actionWithDuration:0.5f opacity:0], 
					   nil]];
	[label3 runAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.8f], 
					   [CCMoveTo actionWithDuration:0.5f position:ccp(240,CreditChunkY3)], 
					   [CCDelayTime actionWithDuration:1.7f], 
					   [CCMoveTo actionWithDuration:0.5f position:ccp(-200,CreditChunkY3)], 
					   nil]];
	[self addChild:label3];
	
	// remove myself
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:4.0f],
					 [CCCallFunc actionWithTarget:self selector:@selector(die)],
					 nil]];
}

- (void) die {
	[self.parent removeChild:self cleanup:YES];
}

@end
