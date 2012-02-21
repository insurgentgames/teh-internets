#import "AchievementLayer.h"
#import "Achievements.h"
#import "tehinternetsAppDelegate.h"

@implementation AchievementLayer

- (id) init {
	if((self = [super init])) {
		[self addAchievement:@"64913" position:CGPointMake(120, 270)];
		[self addAchievement:@"69443" position:CGPointMake(120, 202.5)];
		[self addAchievement:@"69453" position:CGPointMake(120, 135)];
		[self addAchievement:@"69463" position:CGPointMake(120, 67.5)];
		[self addAchievement:@"69473" position:CGPointMake(360, 270)];
		[self addAchievement:@"69483" position:CGPointMake(360, 202.5)];
		[self addAchievement:@"69503" position:CGPointMake(360, 135)];
		[self addAchievement:@"69513" position:CGPointMake(360, 67.5)];
		[self addAchievement:@"69533" position:CGPointMake(600, 270)];
		[self addAchievement:@"69543" position:CGPointMake(600, 202.5)];
		[self addAchievement:@"69553" position:CGPointMake(600, 135)];
		[self addAchievement:@"69573" position:CGPointMake(600, 67.5)];
		[self addAchievement:@"69583" position:CGPointMake(840, 270)];
		[self addAchievement:@"69593" position:CGPointMake(840, 202.5)];
		[self addAchievement:@"69603" position:CGPointMake(840, 135)];
		[self addAchievement:@"69613" position:CGPointMake(840, 67.5)];
		[self addAchievement:@"69623" position:CGPointMake(1080, 270)];
		[self addAchievement:@"69633" position:CGPointMake(1080, 202.5)];
		[self addAchievement:@"69643" position:CGPointMake(1080, 135)];
		[self addAchievement:@"69653" position:CGPointMake(1080, 67.5)];
		[self addAchievement:@"69663" position:CGPointMake(1320, 270)];
		[self addAchievement:@"69673" position:CGPointMake(1320, 202.5)];
		[self addAchievement:@"69683" position:CGPointMake(1320, 135)];	
	}
	return self;
}

- (void) addAchievement:(NSString*)achievementId position:(CGPoint)p {
	tehinternetsAppDelegate* appDelegate = (tehinternetsAppDelegate*)[UIApplication sharedApplication].delegate;
	
	// icon
	CCSprite* icon;
	if([appDelegate isAchievementUnlocked:achievementId])
		icon = [CCSprite spriteWithFile:@"OFUnlockedAchievementIcon.png"];
	else
		icon = [CCSprite spriteWithFile:@"OFLockedAchievementIcon.png"];
	
	// title ,description
	CCLabel* title = [CCLabel labelWithString:[appDelegate getAchievementTitle:achievementId] fontName:@"AmericanTypewriter-Bold" fontSize:13];
	CCLabel* description = [CCLabel labelWithString:[appDelegate getAchievementDescription:achievementId] fontName:@"AmericanTypewriter" fontSize:9];
	
	// add these things
	icon.position = ccp(p.x - 84, p.y-35);
	[self addChild:icon];
	title.position = ccp(p.x+26, p.y-25);
	[self addChild:title];
	description.position = ccp(p.x+26, p.y-47);
	[self addChild:description];
}

@end
