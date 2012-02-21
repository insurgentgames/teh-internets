#import "AchievementsScene.h"
#import "AchievementLayer.h"

@implementation AchievementsScene

+ (id) scene {
	AchievementsScene* scene = [AchievementsScene node];
	[scene initAchievementsScene];
	return scene;
}

- (void) initAchievementsScene {
	NSLog(@"AchievementsScene init");
	
	page = 0;
	
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
	CCSprite* header = [CCSprite spriteWithFile:@"Achievements.png"];
	header.position = ccp(120, 295);
	[self addChild:header z:1];
	
	// create the menu
	itemBack = [CCMenuItemImage itemFromNormalImage:@"AchievementsBack.png" selectedImage:@"AchievementsBack.png" target:self selector:@selector(doBack:)];
	itemLeft = [CCMenuItemImage itemFromNormalImage:@"AchievementsLeft.png" selectedImage:@"AchievementsLeft.png" target:self selector:@selector(doLeft:)];
	itemLeft.opacity = 255;
	itemRight = [CCMenuItemImage itemFromNormalImage:@"AchievementsRight.png" selectedImage:@"AchievementsRight.png" target:self selector:@selector(doRight:)];
	itemRight.opacity = 255;
	CCMenu* menu = [CCMenu menuWithItems:itemBack, itemLeft, itemRight, nil];
	[menu alignItemsHorizontallyWithPadding:0];
	menu.position = ccp(360,295);
	[self addChild:menu z:1];
	[self fixOpacity];
	
	// add the achievements
	achievementLayer = [AchievementLayer node];
	[self addChild:achievementLayer z:2];
}

- (void) dealloc {
	NSLog(@"OptionsMenu dealloc");
	[super dealloc];
}

- (void) doBack:(id)sender {
	[[CCDirector sharedDirector] popScene];
}

- (void) doLeft:(id)sender {
	if(page == 0)
		return;
	
	page--;
	[self fixOpacity];
	[achievementLayer runAction:[CCMoveBy actionWithDuration:0.5f position:CGPointMake(480, 0)]];
}

- (void) doRight:(id)sender {
	if(page == 2)
		return;
	
	page++;
	[self fixOpacity];
	[achievementLayer runAction:[CCMoveBy actionWithDuration:0.5f position:CGPointMake(-480, 0)]];
}

- (void) fixOpacity {
	switch(page) {
		case 0:
			itemLeft.opacity = 50;
			itemRight.opacity = 255;
			break;
		case 1:
			itemLeft.opacity = 255;
			itemRight.opacity = 255;
			break;
		case 2:
			itemLeft.opacity = 255;
			itemRight.opacity = 50;
			break;
	}
}

@end
