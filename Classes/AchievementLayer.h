#import "cocos2d.h"

@interface AchievementLayer : CCLayer {

}

- (id) init;
- (void) addAchievement:(NSString*)achievementId position:(CGPoint)p;

@end
