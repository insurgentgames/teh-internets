#import "cocos2d.h"
@class GameLolcat;

#define GameLolcatPhraseDistance (GameLolcatRadius+5)

@interface GameLolcatPhrase : CCLabel {
	GameLolcat* lolcat;
}

@property (nonatomic,retain) GameLolcat* lolcat;

- (void) initWithLolcat:(GameLolcat*)_lolcat;
- (void) tick:(id)sender;
- (void) die;

@end
