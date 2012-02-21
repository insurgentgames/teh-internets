#import "cocos2d.h"
#import "GamePlayer.h"
#import "GameBackground.h"
#import "GameHUD.h"
#import "GameStuff.h"
#import "GameTroll.h"
@class Stats;
@class tehinternetsAppDelegate;

#define GameMaxLives 5
#define GameStartingLives 3
#define GameSpeedIncInterval 28
#define GameCanHasCheezburgerInterval 0.5f
#define GameNewObjectIntervalStart 30
#define GameNewObjectIntervalInc 15

// tags
typedef enum {
	GameTagPlayer = 0,
	GameTagPopup = 1,
	GameTagLolcat = 2,
	GameTagLolcatPhrase = 3,
	GameTagLollerskater = 4,
	GameTagPauseSolid = 5,
	GameTagPauseMenu = 6,
	GameTagPauseTime = 7,
	GameTagPauseOf = 8,
	GameTagInstructionsFreeplay1 = 9,
	GameTagInstructionsFreeplay2 = 10
} GameTag;

// objects
typedef enum {
	GameObjectLolcat = 0,
	GameObjectPopup = 1,
	GameObjectTrollAverage = 2,
	GameObjectVirus = 3,
	GameObjectTrollRuthless = 4,
	GameObjectTrollFlaming = 5,
	GameObjectFirewall = 6
} GameObject;
#define GameObjectTotal 7

// how much score you get for things
#define GameScorePopupMiss 1
#define GameScoreLolcatHit 3
#define GameScoreLolcatFed 9
#define GameScoreLollerskaterHit 5
#define GameScoreTrollHitL1 1
#define GameScoreTrollHitL2 3
#define GameScoreTrollHitL3 5
#define GameScoreVirusMiss 2
#define GameScoreFirewallMiss 4

@interface Game : CCScene {
	// application delegate, that does lots of overall app stuff
	tehinternetsAppDelegate* appDelegate;
	
	// all the layers
	GameBackground* background;
	GameStuff* stuff;
	GameHUD* headsUpDisplay;
	
	// player
	GamePlayer* player;
	BOOL pushingDPad;
	
	// player stats
	Stats* stats;
	int lives;
	int score;
	int lolcats;
	int lollerskatersCollected;
	int cheezburgersEaten;
	int trollsKilled;
	int firewallDeaths;
	int firewallsPassed;
	int deaths;
	
	// timing the game
	double time;
	double timeStart;
	double timeOffsetStart;
	double timeOffset;
	
	// game objects
	NSMutableArray* inactiveObjectPool;
	NSMutableArray* activeObjects;
	float launchInterval;
	float newObjectInterval;
	float objectSpeed;
	
	// lollerskaters
	CCLayer* lollerskaterLayer;
	
	// popup windows
	CCLayer* popupLayer;
	CCLayer* popupParticleLayer;
	
	// lolcats
	CCLayer* lolcatLayer;
	CCLayer* lolcatPhraseLayer;
	NSString* lolcatNextPhrase;
	
	// trolls
	CCLayer* trollLayer;
	
	// cheezburgers
	BOOL canHasCheezburger;
	CCLayer* cheezburgerLayer;
	
	// insults
	CCLayer* insultLayer;
	
	// virii
	CCLayer* virusLayer;
	
	// firewalls
	CCLayer* firewallLayer;
	
	// explosions
	CCLayer* explosionLayer;
	
	// notes layer
	CCLayer* notes;
	CCLayer* scoreNoteLayer;
	CCLayer* messageLayer;
	
	// paused
	BOOL paused;
	
	// gameplay
	BOOL gameplayStarted;
	
	// instructions
	BOOL instructions;
	int instructionsStage;
	CCSprite* instructionsPrairieDog;
	CCSprite* instructionsSpeech;
	CCSprite* instructionsSpeechBottom;
}

@property (nonatomic,retain) GamePlayer* player;
@property (nonatomic,retain) CCLayer* trollLayer;
@property (nonatomic,retain) NSMutableArray* inactiveObjectPool;
@property (nonatomic,retain) NSMutableArray* activeObjects;
@property (readonly) float objectSpeed;
@property (readonly) int lives;
@property (readonly) int score;
@property (readonly) int lolcats;
@property (readwrite) int trollsKilled;
@property (readwrite) int firewallsPassed;
@property (readwrite) BOOL paused;
@property (readonly) BOOL instructions;

+ (id) sceneGame;
+ (id) sceneInstructions;
- (void) initGame;
- (void) initInstructions;

- (void) doPushDPad:(CGFloat)angle;
- (void) doLetGo;
- (void) tick:(id)sender;

- (void) launch;
- (void) newObject;
- (void) speedIncrease;
- (void) checkAchievements;

- (void) launchLollerskater;
- (void) launchPopup;
- (void) launchPopupParticleWithPosition:(CGPoint)p;
- (void) launchLolcat;
- (void) launchTroll:(GameTrollType)type;
- (void) launchExplosion:(CGPoint)p;
- (void) launchCheezburgerTowards:(CGPoint)p;
- (void) canHasCheezburgerYes:(id)sender;
- (void) launchInsultFrom:(CGPoint)src;
- (void) launchVirus;
- (void) launchFirewall;
- (void) launchScoreNoteScore:(NSUInteger)s position:(CGPoint)p;

- (void) loseLife;
- (void) addScore:(NSUInteger)num;

- (NSString*) thanksString;

- (void) doPause;
- (void) doResume:(id)sender;
- (void) doAchievements:(id)sender;
- (void) doOptions:(id)sender;
- (void) doQuit:(id)sender;

- (void) startGameplay:(id)sender;
- (void) endGameplay;

// instructions
- (void) instructionsNext:(id)sender;
- (void) instructionsBubbleSetRect:(id)sender;
- (void) instructionsLaunch;

@end
