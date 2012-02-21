#import "Notification.h"
#import "OpenFeint.h"

@implementation Notification

- (void) initWithText:(NSString*)text {
	// the OF background
	CCSprite* background;
	if([OpenFeint hasUserApprovedFeint])
		background = [CCSprite spriteWithFile:@"Notification.png"];
	else
		background = [CCSprite spriteWithFile:@"NotificationNoOF.png"];
	background.position = ccp(240,348);
	[self addChild:background z:0];
	
	// the text
	CCLabel* label = [CCLabel labelWithString:text fontName:@"AmericanTypewriter-Bold" fontSize:15];
	label.position = ccp(272,354);
	[self addChild:label z:1];
	
	// animate them
	[background runAction:[CCSequence actions:
						   [CCMoveTo actionWithDuration:0.5f position:ccp(240,292)], 
						   [CCDelayTime actionWithDuration:1.5f],
						   [CCFadeTo actionWithDuration:0.5f opacity:0],
						   [CCCallFunc actionWithTarget:self selector:@selector(die:)],
						   nil]];
	[label runAction:[CCSequence actions:
					 [CCMoveTo actionWithDuration:0.5f position:ccp(272,298)], 
					 [CCDelayTime actionWithDuration:1.5f],
					 [CCFadeTo actionWithDuration:0.5f opacity:0],
					 nil]];
}

- (void) die:(id)sender {
	[self.parent removeChild:self cleanup:YES];
}

@end
