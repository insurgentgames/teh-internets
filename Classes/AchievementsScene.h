#import "cocos2d.h"
#import "AchievementLayer.h"

@interface AchievementsScene : CCScene {
	int page;
	AchievementLayer* achievementLayer;
	
	CCMenuItemImage* itemBack;
	CCMenuItemImage* itemLeft;
	CCMenuItemImage* itemRight;
}

+ (id) scene;
- (void) initAchievementsScene;
- (void) doBack:(id)sender;
- (void) doLeft:(id)sender;
- (void) doRight:(id)sender;
- (void) fixOpacity;

@end
