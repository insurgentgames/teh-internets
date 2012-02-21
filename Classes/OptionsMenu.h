#import "cocos2d.h"
@class Options;

@interface OptionsMenu : CCScene {
	Options* options;
	NSString* music;
	BOOL paused;
	
	CCMenuItemFont* itemMusic;
	CCMenuItemFont* itemSound;
	CCMenuItemFont* itemRickTolld;
}

+ (id) sceneWithOptions:(Options*)_options music:(NSString*)_music startPaused:(BOOL)_paused;
- (void) initWithOptions:(Options*)_options music:(NSString*)_music startPaused:(BOOL)_paused;
- (void) doMusic:(id)sender;
- (void) doSound:(id)sender;
- (void) doRickRolld:(id)sender;
- (void) doBack:(id)sender;

@end
