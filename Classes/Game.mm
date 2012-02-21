#import "Game.h"
#import "GameBackground.h"
#import "GameHUD.h"
#import "GamePopup.h"
#import "GamePopupParticle.h"
#import "GameLolcat.h"
#import "GameLolcatPhrase.h"
#import "GameLollerskater.h"
#import "GameTroll.h"
#import "GameCheezburger.h"
#import "GameInsult.h"
#import "GameVirus.h"
#import "GameFirewall.h"
#import "GameBluescreen.h"
#import "GameNote.h"
#import "GameScoreNote.h"
#import "GameMessage.h"
#import "GameCountdown.h"
#import "GameFail.h"
#import "MainMenu.h"
#import "OptionsMenu.h"
#import "Stats.h"
#import "tehinternetsAppDelegate.h"

// OpenFeint
#import "OpenFeint.h"
#import "OpenFeint+Dashboard.h"
#import "Achievements.h"
#import "AchievementsScene.h"

@implementation Game

@synthesize player;
@synthesize trollLayer;
@synthesize activeObjects;
@synthesize inactiveObjectPool;
@synthesize objectSpeed;
@synthesize lives;
@synthesize score;
@synthesize lolcats;
@synthesize trollsKilled;
@synthesize firewallsPassed;
@synthesize paused;
@synthesize instructions;

+ (id) sceneGame {
	Game* s = [Game node];
	[s initGame];
	return s;
}

+ (id) sceneInstructions {
	Game* s = [Game node];
	[s initInstructions];
	return s;
}

- (void) initGame {
	NSLog(@"Game starting game");
	
	// not instructions
	instructions = NO;
	
	// player stats
	lives = GameStartingLives;
	[headsUpDisplay updateLives];
	score = 0;
	lolcats = 0;
	lollerskatersCollected = 0;
	cheezburgersEaten = 0;
	trollsKilled = 0;
	firewallDeaths = 0;
	firewallsPassed = 0;
	deaths = 0;
	
	// game timing
	time = 0;
	timeStart = [[NSDate date] timeIntervalSince1970];
	timeOffsetStart = 0;
	timeOffset = 0;
	
	// game objects
	self.activeObjects = [NSMutableArray arrayWithCapacity:GameObjectTotal];
	[self.activeObjects addObject:[NSNumber numberWithInt:GameObjectLolcat]];
	[self.activeObjects addObject:[NSNumber numberWithInt:GameObjectPopup]];
	launchInterval = 2.5;
	newObjectInterval = GameNewObjectIntervalStart;
	objectSpeed = 1.0;
	
	// inactive object pool, based on achievements
	self.inactiveObjectPool = [NSMutableArray arrayWithCapacity:GameObjectTotal];
	if([appDelegate isAchievementUnlocked:ACHIEVEMENT_AVERAGE])
		[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollAverage]];
	if([appDelegate isAchievementUnlocked:ACHIEVEMENT_OMG_A_VIRUS_])
		[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectVirus]];
	if([appDelegate isAchievementUnlocked:ACHIEVEMENT_RUTHLESS])
		[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollRuthless]];
	if([appDelegate isAchievementUnlocked:ACHIEVEMENT_FLAMING_])
		[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollFlaming]];
	if([appDelegate isAchievementUnlocked:ACHIEVEMENT_THE_OPEN_PORT])
		[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectFirewall]];
	
	// start the timer
	[self schedule: @selector(tick:) interval:0.03f];
	[stuff schedule: @selector(checkAchievements) interval:5];
	
	// start countdown, and set the gameplay in 5 seconds, play modem sound
	GameCountdown* countdown = [GameCountdown countdown];
	[self addChild:countdown z:10];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:3.0], 
					 [CCCallFunc actionWithTarget:self selector:@selector(startGameplay:)], 
					 nil]];
	[appDelegate playSound:@"Modem.wav"];
	
	// paused
	paused = NO;
	gameplayStarted = NO;
}

- (void) initInstructions {
	NSLog(@"Game starting instructions");
	
	instructions = YES;
	
	// player stats
	lives = GameStartingLives;
	[headsUpDisplay updateLives];
	score = 0;
	
	// game timing
	time = 0;
	timeStart = [[NSDate date] timeIntervalSince1970];
	timeOffsetStart = 0;
	timeOffset = 0;
	
	// objects
	self.activeObjects = [NSMutableArray arrayWithCapacity:GameObjectTotal];
	objectSpeed = 1.0;
	
	// instructions stage
	instructionsStage = 0;
	
	// prairie dog
	CCSpriteSheet* instructionsPrairieDogSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"InstructionsPrairieDog.png"];
	instructionsPrairieDog = [CCSprite spriteWithSpriteSheet:instructionsPrairieDogSpriteSheet rect:CGRectMake(0, 0, 115, 162)];
	[self addChild:instructionsPrairieDog z:100];
	CCAnimation* anim = [CCAnimation animationWithName:@"PrairieDogRight" delay:0.1f];
	for(int i=0; i<6; i++)
		[anim addFrameWithTexture:instructionsPrairieDogSpriteSheet.texture rect:CGRectMake(i*115, 0, 115, 162)];
	
	// speech bubble
	CCSpriteSheet* instructionsSpeechSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"InstructionsSpeech.png"];
	instructionsSpeech = [CCSprite spriteWithSpriteSheet:instructionsSpeechSpriteSheet rect:CGRectMake(0, 0, 314, 152)];
	[instructionsSpeechSpriteSheet addChild:instructionsSpeech z:0];
	instructionsSpeechBottom = [CCSprite spriteWithSpriteSheet:instructionsSpeechSpriteSheet rect:CGRectMake(314, 608, 314, 42)];
	[instructionsSpeechSpriteSheet addChild:instructionsSpeechBottom z:0];
	[self addChild:instructionsSpeechSpriteSheet z:100];
	
	// menu
	CCSpriteSheet* instructionsMenuSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"InstructionsSpeech.png"];
	CCSprite* itemNextSprite = [CCSprite spriteWithSpriteSheet:instructionsMenuSpriteSheet rect:CGRectMake(208, 650, 104, 44)];
	CCSprite* itemNextSelectedSprite = [CCSprite spriteWithSpriteSheet:instructionsMenuSpriteSheet rect:CGRectMake(312, 650, 104, 44)];
	CCSprite* itemQuitSprite = [CCSprite spriteWithSpriteSheet:instructionsMenuSpriteSheet rect:CGRectMake(0, 650, 104, 44)];
	CCSprite* itemQuitSelectedSprite = [CCSprite spriteWithSpriteSheet:instructionsMenuSpriteSheet rect:CGRectMake(104, 650, 104, 44)];
	CCMenuItemSprite* itemNext = [CCMenuItemSprite itemFromNormalSprite:itemNextSprite selectedSprite:itemNextSelectedSprite target:self selector:@selector(instructionsNext:)];
	CCMenuItemSprite* itemQuit = [CCMenuItemSprite itemFromNormalSprite:itemQuitSprite selectedSprite:itemQuitSelectedSprite target:self selector:@selector(doQuit:)];
	CCMenu* instructionsMenu = [CCMenu menuWithItems:itemNext, itemQuit, nil];
	[instructionsMenu alignItemsHorizontallyWithPadding:16];
	instructionsMenu.position = ccp(240, 30);
	[self addChild:instructionsMenu z:101];
	[self addChild:instructionsMenuSpriteSheet z:101];

	// initialize the first stage
	[appDelegate pauseMusic];
	[appDelegate playSound:@"PrairieDog.wav"];
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:3.0], 
					 [CCCallFunc actionWithTarget:appDelegate selector:@selector(resumeMusic)], 
					 nil]];
	headsUpDisplay.visible = NO;
	player.visible = NO;
	[instructionsSpeech setTextureRect:CGRectMake(0, 0, 314, 152)];
	instructionsSpeech.position = ccp(315,236);
	instructionsSpeech.opacity = 0;
	[instructionsSpeechBottom setTextureRect:CGRectMake(314, 608, 314, 42)];
	instructionsSpeechBottom.position = ccp(315,139);
	instructionsSpeechBottom.opacity = 0;
	instructionsPrairieDog.position = ccp(595, 81);
	[instructionsPrairieDog runAction:[CCSequence actions:
									   [CCMoveTo actionWithDuration:1.0 position:ccp(210, 81)],
									   [CCAnimate actionWithAnimation:anim],
									   nil]];
	[instructionsSpeech runAction:[CCSequence actions:
								   [CCDelayTime actionWithDuration:1.0],
								   [CCFadeTo actionWithDuration:1.0 opacity:255], 
								   nil]];
	[instructionsSpeechBottom runAction:[CCSequence actions:
										 [CCDelayTime actionWithDuration:1.0],
										 [CCFadeTo actionWithDuration:1.0 opacity:255], 
										 nil]];
}

- (id) init {
	if((self = [super init])) {
		NSLog(@"Game init");
		
		// app delegate
		appDelegate = (tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate);
		
		// background
		background = [GameBackground node];
		[background initBackground];
		[self addChild:background z:0];
		
		// stuff
		stuff = [GameStuff node];
		stuff.game = self;
		[self addChild:stuff z:2];
		
		// heads up display
		headsUpDisplay = [GameHUD node];
		[self addChild:headsUpDisplay z:10];
		
		// initialize the player
		CCSpriteSheet* playerSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"GameRoflcopter.png"];
		CCAnimation* playerAnimation = [CCAnimation animationWithName:@"GamePlayer" delay:0.1f];
		for(int i=0;i<5;i++)
			[playerAnimation addFrameWithTexture:playerSpriteSheet.texture rect:CGRectMake(0, i*74, 102, 74)];
		player = [GamePlayer spriteWithSpriteSheet:playerSpriteSheet rect:CGRectMake(0, 0, 102, 74)];
		[playerSpriteSheet addChild:player];
		[stuff addChild:playerSpriteSheet z:10 tag:GameTagPlayer];
		[player initPlayer];
		[player runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:playerAnimation]]];
		pushingDPad = NO;
		
		// initialize lollerskaters
		lollerskaterLayer = [CCLayer node];
		[stuff addChild:lollerskaterLayer z:0 tag:GameTagLollerskater];
		
		// pop up windows
		popupLayer = [CCLayer node];
		[stuff addChild:popupLayer z:0 tag:GameTagPopup];
		popupParticleLayer = [CCLayer node];
		[stuff addChild:popupParticleLayer z:1 tag:GameTagPopup];
		
		// lolcats
		lolcatLayer = [CCLayer node];
		//lolcatManager = [AtlasSpriteManager spriteManagerWithFile:@"GameLolcats.png"];
		[stuff addChild:lolcatLayer z:0 tag:GameTagLolcat];
		lolcatPhraseLayer = [CCLayer node];
		[stuff addChild:lolcatPhraseLayer z:1 tag:GameTagLolcatPhrase];
		lolcatNextPhrase = nil;
		
		// trolls
		trollLayer = [CCLayer node];
		//trollManager = [AtlasSpriteManager spriteManagerWithFile:@"GameTroll.png" capacity:5];
		[stuff addChild:trollLayer z:0];
		
		// cheezburgers
		canHasCheezburger = YES;
		[self schedule:@selector(canHasCheezburgerYes:) interval:GameCanHasCheezburgerInterval];
		cheezburgerLayer = [CCLayer node];
		//cheezburgerManager = [AtlasSpriteManager spriteManagerWithFile:@"GameCheezburger.png" capacity:5];
		[stuff addChild:cheezburgerLayer z:1];
		
		// insults
		insultLayer = [CCLayer node];
		//insultManager = [AtlasSpriteManager spriteManagerWithFile:@"GameTroll.png" capacity:5];
		[stuff addChild:insultLayer z:1];
		
		// virii
		virusLayer = [CCLayer node];
		//virusManager = [AtlasSpriteManager spriteManagerWithFile:@"GameVirus.png" capacity:5];
		[stuff addChild:virusLayer z:0];
		
		// firewalls
		firewallLayer = [CCLayer node];
		[stuff addChild:firewallLayer z:0];
		
		// explosions
		explosionLayer = [CCLayer node];
		[stuff addChild:explosionLayer z:0];
		
		// notes layer
		notes = [CCLayer node];
		[stuff addChild:notes z:10];
		scoreNoteLayer = [CCLayer node];
		//scoreNoteManager = [AtlasSpriteManager spriteManagerWithFile:@"GameScoreNote.png" capacity:10];
		[stuff addChild:scoreNoteLayer z:10];
		messageLayer = [CCLayer node];
		[stuff addChild:messageLayer z:10];
		
		// stats
		stats = appDelegate.stats;
		
		// give app delegate handle to the game
		appDelegate.game = self;
	}
	return self;
}

- (void) dealloc {
	NSLog(@"Game dealloc");
	[super dealloc];
}

- (void) doPushDPad:(CGFloat)angle {
	pushingDPad = YES;
	player.angle = angle;
}

- (void) doLetGo {
	pushingDPad = NO;
}

- (void) tick:(id)sender {
	// update the player
	[player update:pushingDPad];
	
	// check for collisions with popup windows
	GamePopup* popup;
	GamePopup* popupToDelete = nil;
	for(popup in [popupLayer children]) {
		if(ccpDistance(player.position, popup.position) <= GamePlayerRadius + GamePopupRadius) {
			NSLog(@"Game COLLISION with a popup window");
			
			// the player collided with this popup window
			pushingDPad = NO;
			player.angle = 180;
			player.velocity = GamePlayerMaxVelocity;
			
			// play crash sound
			[appDelegate playSound:@"PopupCrash.wav"];
			
			// create popup particles, and delete the popup
			for(int i=0; i<10; i++)
				[self launchPopupParticleWithPosition:popup.position];
			popupToDelete = popup;
			
			// lose the life
			[self loseLife];
		}
	}
	if(popupToDelete != nil) {
		[popupToDelete die];
	}
	
	// check for collisions with lolcats
	GameLolcat* lolcat;
	GameLolcat* lolcatToDelete = nil;
	for(lolcat in [lolcatLayer children]) {
		if(ccpDistance(player.position, lolcat.position) <= GamePlayerRadius + GameLolcatRadius) {
			NSLog(@"Game COLLISION with a lolcat");
			lolcatToDelete = lolcat;
			
			// the player collided with this lolcat
			pushingDPad = NO;
			player.angle = 180;
			player.velocity = GamePlayerMaxVelocity;
			
			// play meow sound
			[appDelegate playSound:[NSString stringWithFormat:@"Meow%i.wav",(int)(arc4random()%3+1)]];
			
			// add a note in its place
			[notes addChild:[GameNote noteWithString:[self thanksString] andPosition:lolcat.position]];
			[self launchScoreNoteScore:GameScoreLolcatHit position:lolcat.position];
			[self addScore:GameScoreLolcatHit];
			
			if(!instructions) {
				// achievements
				lolcats++;
				[appDelegate unlockAchievement:ACHIEVEMENT_N00BS_FIRST_LOLCAT];
				if(lolcats + stats.totalLolcats >= 500)
					[appDelegate unlockAchievement:ACHIEVEMENT_CAT_LADY];
				if(lolcats == 30)
					[appDelegate unlockAchievement:ACHIEVEMENT_KITTENS_INSPIRED_BY_KITTENS];
			}
		}
	}
	if(lolcatToDelete != nil) {
		[lolcatToDelete die];
	}
	
	// check for collisions with lollerskaters
	if([[lollerskaterLayer children] count] > 0) {
		GameLollerskater* lollerskater;
		GameLollerskater* lollerskaterToDelete = nil;
		for(lollerskater in [lollerskaterLayer children]) {
			if(ccpDistance(player.position, lollerskater.position) <= GamePlayerRadius + GameLollerskaterRadius) {
				NSLog(@"Game COLLISION with a lollerskater");
				if(!instructions) {
					[appDelegate unlockAchievement:ACHIEVEMENT_LOLLERSKATER_SOS];
				}
				
				// achievements
				if(!instructions) {
					lollerskatersCollected++;
					if(lollerskatersCollected + stats.totalLollerskaters >= 20)
						[appDelegate unlockAchievement:ACHIEVEMENT_ITS_PEANUT_BUTTER_JELLY_TIME];
				}
				
				// play lollerskater sound
				[appDelegate playSound:@"Lollerskater.wav"];
				
				// if lives are not full, add a life
				if(lives < GameMaxLives) {
					lives++;
					[headsUpDisplay updateLives];
				}
				// if lives are full, add score instead
				else {
					[self launchScoreNoteScore:GameScoreLollerskaterHit position:lollerskater.position];
					[self addScore:GameScoreLollerskaterHit];
				}
				
				// add a note in its place
				[notes addChild:[GameNote noteWithString:[self thanksString] andPosition:lollerskater.position]];
				
				// delete the lollerskater
				lollerskaterToDelete = lollerskater;
			}
		}
		if(lollerskaterToDelete != nil)
			[lollerskaterToDelete die];
	}
	
	// check for collisions with trolls
	GameTroll* troll;
	GameTroll* trollToDelete = nil;
	for(troll in [trollLayer children]) {
		if(ccpDistance(player.position, troll.position) <= GamePlayerRadius + troll.radius) {
			NSLog(@"Game COLLISION with a troll");
			
			// the player collided with this troll
			pushingDPad = NO;
			player.angle = 180;
			player.velocity = GamePlayerMaxVelocity;
			
			// play crash sound
			[appDelegate playSound:[NSString stringWithFormat:@"TrollDie%i.wav", (int)(arc4random()%2)+1]];
			
			// delete troll
			trollToDelete = troll;
			
			// lose the life
			[self loseLife];
		}
	}
	if(trollToDelete != nil) {
		[self launchExplosion:trollToDelete.position];
		[trollToDelete die];
	}
	
	// check for collisions with virii
	GameVirus* virus;
	GameVirus* virusToDelete = nil;
	for(virus in [virusLayer children]) {
		if(ccpDistance(player.position, virus.position) <= GamePlayerRadius + GameVirusRadius) {
			NSLog(@"Game COLLISION with a virus");
			
			// hit this virus
			virus.hit = YES;
			
			// the player collided with this virus
			pushingDPad = NO;
			player.angle = 0;
			player.velocity = GamePlayerMaxVelocity;
			
			// play crash sound
			[appDelegate playSound:@"Virus.wav"];
			
			// delete virus
			virusToDelete = virus;
			
			// lose the life
			[self loseLife];
		}
	}
	if(virusToDelete != nil) {
		[virusToDelete die];
	}
	
	// check for collisions with firewall
	GameFirewall* firewall;
	for(firewall in [firewallLayer children]) {
		if([firewall collideWith:player.position radius:GamePlayerRadius]) {
			NSLog(@"Game COLLISION with a firewall");
			
			// the player collided with this firewall
			pushingDPad = NO;
			player.angle = 0;
			player.velocity = GamePlayerMaxVelocity;
			
			// play crash sound
			[appDelegate playSound:@"Firewall.wav"];
			
			// lose the life
			[self loseLife];
			
			// 3 firewall deaths?
			if(!instructions) {
				if(firewall.hit == NO) {
					firewallDeaths++;
					if(firewallDeaths == 3)
						[appDelegate unlockAchievement:ACHIEVEMENT_DONT_TAZE_ME_BRO];
				}
			}
			
			// hit this firewall
			firewall.hit = YES;

		}
	}
	
	// check for collisions with insults
	GameInsult* insult;
	GameInsult* insultToDelete = nil;
	for(insult in [insultLayer children]) {
		if(ccpDistance(player.position, insult.position) <= GamePlayerRadius + GameInsultRadius) {
			NSLog(@"Game COLLISION with an insult");
			
			// the player collided with this insult
			pushingDPad = NO;
			player.angle = 180;
			player.velocity = GamePlayerMaxVelocity;
			
			// play sound
			[appDelegate playSound:@"Bleep.wav"];
			
			// delete insult
			insultToDelete = insult;
			
			// lose the life
			[self loseLife];
		}
	}
	if(insultToDelete != nil) {
		[insultToDelete die];
	}
	
	// check for collisions between cheezburgers and trolls
	GameCheezburger* cheezburger;
	GameCheezburger* cheezburgerToDelete = nil;
	for(cheezburger in [cheezburgerLayer children]) {
		GameTroll* trollToFeed = nil;
		for(troll in [trollLayer children]) {
			if(ccpDistance(cheezburger.position, troll.position) <= GameCheezburgerRadius + troll.radius) {
				NSLog(@"Game COLLISION between a cheezburger and a troll");
				
				// play sound
				[appDelegate playSound:@"Eat.wav"];
				
				// feed troll
				trollToFeed = troll;
				
				// achievement
				if(!instructions) {
					cheezburgersEaten++;
					if(cheezburgersEaten + stats.totalCheezburgersEaten >= 400)
						[appDelegate unlockAchievement:ACHIEVEMENT_GODWINS_LAW];
				}
			}
		}
		if(trollToFeed != nil) {
			// is the troll dying?
			if(trollToFeed.level == 2) {
				[self launchExplosion:trollToFeed.position];
				
				// update trolls killed
				trollsKilled++;
				if(trollsKilled == 20)
					[appDelegate unlockAchievement:ACHIEVEMENT_SOMEBODY_SET_US_UP_THE_BOMB];
				
				// play sound
				[appDelegate playSound:[NSString stringWithFormat:@"TrollDie%i.wav", (int)(arc4random()%2)+1]];
			}
			
			// feed the troll
			int scoreToAdd = [trollToFeed feed];
			cheezburgerToDelete = cheezburger;
			
			// add the score note
			[self launchScoreNoteScore:scoreToAdd position:cheezburgerToDelete.position];
			[self addScore:scoreToAdd];

		}
	}
	if(cheezburgerToDelete != nil) {
		[cheezburgerToDelete die];
	}
	
	// check for collisions between cheezburgers and lolcats
	cheezburgerToDelete = nil;
	for(cheezburger in [cheezburgerLayer children]) {
		GameLolcat* lolcatToFeed = nil;
		for(lolcat in [lolcatLayer children]) {
			if(ccpDistance(cheezburger.position, lolcat.position) <= GameCheezburgerRadius + GameLolcatRadius) {
				NSLog(@"Game COLLISION between a cheezburger and a lolcat");
				
				if(!instructions) {
					// achievement
					[appDelegate unlockAchievement:ACHIEVEMENT_I_CAN_HAS_CHEEZBURGER];
				}
				
				// play munch sound
				[appDelegate playSound:@"Eat.wav"];
				
				// feed troll
				lolcatToFeed = lolcat;
			}
		}
		if(lolcatToFeed != nil) {
			// feed the lolcat
			cheezburgerToDelete = cheezburger;
			[lolcatToFeed die];
			
			// add the score note
			[self launchScoreNoteScore:GameScoreLolcatFed position:cheezburgerToDelete.position];
			[self addScore:GameScoreLolcatFed];
		}
	}
	if(cheezburgerToDelete != nil) {
		[cheezburgerToDelete die];
	}
}

- (void) launch {
	if(paused)
		return;
	
	int rand = (int)(arc4random()%[self.activeObjects count]);
	switch([[self.activeObjects objectAtIndex:rand] intValue]) {
		case GameObjectLolcat:
			[self launchLolcat];
			break;
		case GameObjectPopup:
			[self launchPopup];
			break;
		case GameObjectTrollAverage:
			[self launchTroll:GameTrollTypeAverage];
			break;
		case GameObjectVirus:
			[self launchVirus];
			break;
		case GameObjectTrollRuthless:
			[self launchTroll:GameTrollTypeRuthless];
			break;
		case GameObjectTrollFlaming:
			[self launchTroll:GameTrollTypeFlaming];
			break;
		case GameObjectFirewall:
			[self launchFirewall];
			break;
	}
	
	// random chance to launch a lollerskater
	if((int)(arc4random() % 50) == 0) {
		[self launchLollerskater];
	}
}

- (void) newObject {
	NSLog(@"Game adding new object to activeObjects");
	
	// if the activeObjects array is full, do nothing
	if([self.activeObjects count] == GameObjectTotal) {
		NSLog(@"Can't launch an object, all are already in play");
		return;
	}
	
	// if the inactive object pool is empty, add one
	if([self.inactiveObjectPool count] == 0) {
		NSLog(@"inactiveObjectPool is empty, so adding a new object to it");
		BOOL objectAdded = NO;
		
		// add average troll?
		if([appDelegate isAchievementUnlocked:ACHIEVEMENT_AVERAGE] == NO) {
			[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollAverage]];
			[appDelegate unlockAchievement:ACHIEVEMENT_AVERAGE];
			objectAdded = YES;
			NSLog(@"Added Average Trolls to inactiveObjectPool");
		}
		if(!objectAdded) {
			// add virus?
			if([appDelegate isAchievementUnlocked:ACHIEVEMENT_OMG_A_VIRUS_] == NO) {
				[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectVirus]];
				[appDelegate unlockAchievement:ACHIEVEMENT_OMG_A_VIRUS_];
				objectAdded = YES;
				NSLog(@"Added Viruses to inactiveObjectPool");
			}
			if(!objectAdded) {
				// add ruthless troll?
				if([appDelegate isAchievementUnlocked:ACHIEVEMENT_RUTHLESS] == NO) {
					[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollRuthless]];
					[appDelegate unlockAchievement:ACHIEVEMENT_RUTHLESS];
					objectAdded = YES;
					NSLog(@"Added Ruthless Trolls to inactiveObjectPool");
				}
				if(!objectAdded) {
					// add flaming troll?
					if([appDelegate isAchievementUnlocked:ACHIEVEMENT_FLAMING_] == NO) {
						[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectTrollFlaming]];
						[appDelegate unlockAchievement:ACHIEVEMENT_FLAMING_];
						objectAdded = YES;
						NSLog(@"Added Flaming Trolls to inactiveObjectPool");
					}
					if(!objectAdded) {
						// add firewall?
						if([appDelegate isAchievementUnlocked:ACHIEVEMENT_THE_OPEN_PORT] == NO) {
							[self.inactiveObjectPool addObject:[NSNumber numberWithInt:GameObjectFirewall]];
							[appDelegate unlockAchievement:ACHIEVEMENT_THE_OPEN_PORT];
							objectAdded = YES;
							NSLog(@"Added Firewalls to inactiveObjectPool");
						}
						// no more objects to add, so return
						if(!objectAdded) {
							NSLog(@"All objects should be in the active pool now");
							return;
						}
					}
				}
			}
		}
	}
	
	NSLog(@"inactiveObjectPool has %i objects; activeObjects has %i objects", [inactiveObjectPool count], [activeObjects count]);
	
	// add a random object to activeObjects
	NSUInteger rand = (int)(arc4random() % [self.inactiveObjectPool count]);
	NSNumber* object = [self.inactiveObjectPool objectAtIndex:rand];
	[self.activeObjects addObject:object];
	[self.inactiveObjectPool removeObject:object];
	
	// hammer time?
	if([self.activeObjects count] == GameObjectTotal) {
		[appDelegate unlockAchievement:ACHIEVEMENT_HAMMER_TIME];
	}	
	
	// send a message about it
	GameMessage* message = [GameMessage spriteWithFile:@"GameMessage.png" rect:CGRectMake(0, 0, 100, 100)];
	switch([object intValue]) {
		case GameObjectTrollAverage:
			[message initMessageWithType:GameMessageTypeAverageTrolls];
			break;
		case GameObjectVirus:
			[message initMessageWithType:GameMessageTypeVirii];
			break;
		case GameObjectTrollRuthless:
			[message initMessageWithType:GameMessageTypeRuthlessTrolls];
			break;
		case GameObjectTrollFlaming:
			[message initMessageWithType:GameMessageTypeFlamingTrolls];
			break;
		case GameObjectFirewall:
			[message initMessageWithType:GameMessageTypeFirewalls];
			break;
	}
	[messageLayer addChild:message];
	
	NSLog(@"inactiveObjectPool has %i objects; activeObjects has %i objects", [inactiveObjectPool count], [activeObjects count]);
	
	// increase the new object interval, run again
	newObjectInterval += GameNewObjectIntervalInc;
	[stuff runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:newObjectInterval], 
					 [CCCallFunc actionWithTarget:stuff selector:@selector(newObject)], 
					 nil]];
}

- (void) speedIncrease {
	NSLog(@"Game increasing speed");
	objectSpeed = objectSpeed*1.05;
	launchInterval = launchInterval * 0.95;
	background.speed = background.speed * 1.15;
	[stuff unschedule:@selector(launch)];
	[stuff schedule:@selector(launch) interval:launchInterval];
	
	// send a message about it
	GameMessage* message = [GameMessage spriteWithFile:@"GameMessage.png" rect:CGRectMake(0, 0, 100, 100)];
	[message initMessageWithType:GameMessageTypeSpeedIncrease];
	[messageLayer addChild:message];
	
	// canHasCheezburger
	[self unschedule:@selector(canHasCheezburgerYes:)];
	[self schedule:@selector(canHasCheezburgerYes:) interval:GameCanHasCheezburgerInterval/objectSpeed];
}

- (void) checkAchievements {
	double timeEnd = [[NSDate date] timeIntervalSince1970];
	time = timeEnd - timeStart - timeOffset;
	
	// god mode
	if(time >= 240 && deaths == 0) {
		// 4 minutes without dying
		[appDelegate unlockAchievement:ACHIEVEMENT_GOD_MODE];
	}
	
	// imma let you fininsh!
	if(time >= 600) {
		// survive for 10 minutes
		[appDelegate unlockAchievement:ACHIEVEMENT_IMMA_LET_YOU_FINISH_];
	}
}

- (void) launchLollerskater {
	NSLog(@"Launching a lollerskater");
	GameLollerskater* lollerskater = [GameLollerskater spriteWithFile:@"GameLollerskater.png" rect:CGRectMake(0, 0, 39, 48)];
	[lollerskater initLollerskaterWithGame:self];
	[lollerskaterLayer addChild:lollerskater];
}

- (void) launchPopup {
	NSLog(@"Launching a popup window");
	int rand = (int)(arc4random() % 5);
	GamePopup* popup = [GamePopup spriteWithFile:@"GamePopup.png" rect:CGRectMake(rand*100, 0, 100, 86)];
	[popup initPopupWithGame:self];
	[popupLayer addChild:popup];
}

- (void) launchPopupParticleWithPosition:(CGPoint)p {
	NSLog(@"Launching a popup window particle");
	int rand = (int)(arc4random() % 14);
	CGRect rect;
	switch(rand) {
		case 0:		rect = CGRectMake(0, 0, 50, 58); break;
		case 1:		rect = CGRectMake(0, 58, 50, 28); break;
		case 2:		rect = CGRectMake(50, 0, 58, 24); break;
		case 3:		rect = CGRectMake(50, 24, 58, 51); break;
		case 4:		rect = CGRectMake(108, 0, 65, 67); break;
		case 5:		rect = CGRectMake(108, 67, 42, 19); break;
		case 6:		rect = CGRectMake(173, 0, 39, 48); break;
		case 7:		rect = CGRectMake(173, 48, 51, 38); break;
		case 8:		rect = CGRectMake(212, 0, 23, 40); break;
		case 9:		rect = CGRectMake(235, 0, 53, 67); break;
		case 10:	rect = CGRectMake(288, 0, 67, 48); break;
		case 11:	rect = CGRectMake(288, 48, 67, 38); break;
		case 12:	rect = CGRectMake(355, 0, 45, 40); break;
		case 13:	rect = CGRectMake(355, 48, 45, 38); break;
	}
	GamePopupParticle* popupParticle = [GamePopupParticle spriteWithFile:@"GamePopupParticle.png" rect:rect];
	[popupParticle initPopupParticleWithPosition:p];
	[popupParticleLayer addChild:popupParticle];
}

- (void) launchLolcat {
	NSLog(@"Launching a lolcat");
	NSString* phrase;
	
	// if there are no phrases in the queue, come up with new phrase
	if(lolcatNextPhrase == nil) {
		switch((int)(arc4random()%15)) {
			case 0:
				phrase = @"in ur gamez";
				lolcatNextPhrase = @"planning ur doom";
				break;
			case 1:
				phrase = @"in ur ipod";
				lolcatNextPhrase = @"lisnin 2 ur t00nz";
				break;
			case 2:
				phrase = @"serfing ur internets";
				lolcatNextPhrase = @"sniffing ur packitz";

				break;
			case 3:
				phrase = @"in urz fone";
				lolcatNextPhrase = @"reeding ur txtz";
				break;
			case 4:
				phrase = @"i chays bugz";
				lolcatNextPhrase = @"in ur if0wn";
				break;
			case 5:
				phrase = @"insurgent games";
				lolcatNextPhrase = @"iz teh lulz";
				break;
			case 6:
				phrase = @"ai eated ur pakitz";
				break;
			case 7:
				phrase = @"ai pwnz de intrewebz";
				break;
			case 8:
				phrase = @"yuz fingerz iz stiky";
				break;
			case 9:
				phrase = @"u plz can haz downlowed me?";
				break;
			case 10:
				phrase = @"iz srsly dizzzie";
				break;
			case 11:
				phrase = @"git me. kthxbai.";
				break;
			case 12:
				phrase = @"ctrl-alt-deleet";
				break;
			case 13:
				phrase = @"uz fingrz iz hyewge";
				break;
			case 14:
				phrase = @"i can haz cheezburgr?";
				break;
		}
	}
	// otherwise, return the first item on the queue
	else {
		phrase = lolcatNextPhrase;
		lolcatNextPhrase = nil;
	}
	
	// launch the lolcat
	int rand = (int)(arc4random() % 15);
	GameLolcat* lolcat = [GameLolcat spriteWithFile:@"GameLolcats.png" rect:CGRectMake((rand%10)*50, (rand/10)*50, 50, 50)];
	[lolcat initLolcatWithGame:self];
	[lolcatLayer addChild:lolcat];
	
	// launch lolcat phrase
	GameLolcatPhrase* lolcatPhrase = [GameLolcatPhrase labelWithString:phrase fontName:@"Arial-BoldMT" fontSize:14];
	[lolcatPhrase initWithLolcat:lolcat];
	[lolcatPhraseLayer addChild:lolcatPhrase];
	lolcat.lolcatPhrase = lolcatPhrase;
}

- (void) launchTroll:(GameTrollType)type {
	NSLog(@"Launching a troll");
	GameTroll* troll = [GameTroll spriteWithFile:@"GameTroll.png" rect:CGRectMake(0, 0, 300, 300)];
	[troll initTrollWithGame:self andType:type];
	[trollLayer addChild:troll];
	
	// play sound
	[appDelegate playSound:[NSString stringWithFormat:@"Troll%i.wav", (int)(arc4random()%3)+1]];
}

- (void) launchExplosion:(CGPoint)p {
	NSLog(@"Launching an explosion");
	CCParticleExplosion* emitter = [CCParticleExplosion node];
	emitter.life = 0.1;
	emitter.position = p;
	[explosionLayer addChild:emitter];
}

- (void) launchCheezburgerTowards:(CGPoint)p {
	if(!canHasCheezburger)
		return;
	
	NSLog(@"Launching a cheezburger");
	
	// calculate the angle
	float angle = atan2(p.y - player.position.y, p.x - player.position.x) * 180 / M_PI;
	if(angle < 0)
		angle += 360;
	
	GameCheezburger* cheezburger = [GameCheezburger spriteWithFile:@"GameCheezburger.png" rect:CGRectMake(0, 0, 20, 16)];
	[cheezburger initCheezburgerWithGame:self position:player.position angle:angle];
	[cheezburgerLayer addChild:cheezburger];
	
	canHasCheezburger = NO;
}

- (void) canHasCheezburgerYes:(id)sender {
	canHasCheezburger = YES;
}

- (void) launchInsultFrom:(CGPoint)src {
	NSLog(@"Launching an insult");
	
	// calculate the angle
	float angle = atan2(src.y - player.position.y, src.x - player.position.x) * 180 / M_PI;
	if(angle < 0)
		angle += 360;
	angle += 180;
	if(angle >= 360)
		angle -= 360;
	NSLog(@"Angle: %f", angle);
	
	GameInsult* insult = [GameInsult spriteWithFile:@"GameTroll.png" rect:CGRectMake(0, 600, 50, 25)];
	[insult initInsultWithGame:self position:src angle:angle];
	[insultLayer addChild:insult];
}

- (void) launchVirus {
	NSLog(@"Launching a virus");
	GameVirus* virus = [GameVirus spriteWithFile:@"GameVirus.png" rect:CGRectMake(0, 0, 40, 40)];
	[virus initVirusWithGame:self];
	[virusLayer addChild:virus];
}

- (void) launchFirewall {
	NSLog(@"Launching a firwall");
	GameFirewall* firewall = [GameFirewall node];
	[firewall initFirewallWithGame:self];
	[firewallLayer addChild:firewall];
}

- (void) launchScoreNoteScore:(NSUInteger)s position:(CGPoint)p {
	GameScoreNote* scoreNote = [GameScoreNote spriteWithFile:@"GameScoreNote.png" rect:CGRectMake(0, 0, 80, 30)];
	[scoreNote initWithScore:s andPosition:p];
	[scoreNoteLayer addChild:scoreNote];
}

- (void) loseLife {
	if(instructions)
		return;
	
	if(player.invincible == YES) {
		NSLog(@"Would have lost a life, but player is invincible");
		return;
	}
	
	NSLog(@"Lost a life!");
	
	// first, lose the life
	lives--;
	[headsUpDisplay updateLives];
	
	if(lives > 0) {
		// display FAIL and pause the game for a bit
		GameFail* fail = [GameFail fail];
		[self addChild:fail z:100];
		[player becomeInvincible:3];
	} else {
		// completely dead, blue screen then EPIC FAIL
		[appDelegate stopMusic];
		(appDelegate).game = nil;
		[[CCDirector sharedDirector] replaceScene:[GameBluescreen scene]];
		
		// submit score to OpenFeint
		[self endGameplay];
		[appDelegate submitHighScore:score time:(time) lolcats:lolcats];
	}
}

- (void) addScore:(NSUInteger)num {
	score += num;
	[headsUpDisplay.score setString:[NSString stringWithFormat:@"Score: %i", score]];
	
	if(!instructions) {
		// achievements
		if(score + stats.totalScore > 9000)
			[appDelegate unlockAchievement:ACHIEVEMENT_OVER_9000];
	
		if(score >= 500 && cheezburgersEaten == 0)
			[appDelegate unlockAchievement:ACHIEVEMENT_DNFTT];
	}
}

- (NSString*) thanksString {
	NSString* string;
	switch((int)(arc4random()%3)) {
		case 0: string = @"omg thx!!"; break;
		case 1: string = @"thx lulz"; break;
		case 2: string = @"k thx bai"; break;
	}
	return string;
}

- (void) doPause {
	if(instructions == NO && gameplayStarted == NO)
		return;
	if(instructions == YES && (headsUpDisplay.visible == NO || headsUpDisplay.brb.visible == NO))
		return;
	
	paused = YES;
	timeOffsetStart = [[NSDate date] timeIntervalSince1970];
	
	// pause the game and HUD
	[stuff pause];
	headsUpDisplay.paused = YES;
	
	// pause the music
	[appDelegate pauseMusic];
	
	// dim everything out
	CCColorLayer* solid = [CCColorLayer layerWithColor:ccc4(0,0,0,255)];
	solid.opacity = 200;
	[self addChild:solid z:200 tag:GameTagPauseSolid];
	
	// add the time
	double timeEnd = [[NSDate date] timeIntervalSince1970];
	time = timeEnd - timeStart - timeOffset;
	CCLabel* timeLabel = [CCLabel labelWithString:[NSString stringWithFormat:@"Wasted this game: %.2f seconds", time] 
									 fontName:@"Courier-Bold" fontSize:15];
	timeLabel.position = ccp(240,20);
	[self addChild:timeLabel z:201 tag:GameTagPauseTime];
	
	// add the pause menu
	[CCMenuItemFont setFontSize:40];
	[CCMenuItemFont setFontName:@"AmericanTypewriter-Bold"];
	CCMenuItemFont* itemResume = [CCMenuItemFont itemFromString:@"k, im back" target:self selector:@selector(doResume:)];
	CCMenuItemFont* itemAchievements = [CCMenuItemFont itemFromString:@"achievements" target:self selector:@selector(doAchievements:)];
	CCMenuItemFont* itemOptions = [CCMenuItemFont itemFromString:@"options" target:self selector:@selector(doOptions:)];
	CCMenuItemFont* itemQuit = [CCMenuItemFont itemFromString:@"g2g laterz" target:self selector:@selector(doQuit:)];
	CCMenu* pauseMenu = [CCMenu menuWithItems:itemResume, itemAchievements, itemOptions, itemQuit, nil];
	pauseMenu.position = ccp(240, 190);
	[pauseMenu alignItemsVerticallyWithPadding:10];
	[self addChild:pauseMenu z:201 tag:GameTagPauseMenu];
}

- (void) doResume:(id)sender {
	paused = NO;
	double timeOffsetEnd = [[NSDate date] timeIntervalSince1970];
	timeOffset += (timeOffsetEnd - timeOffsetStart);
	
	// delete the pause layers
	[self removeChildByTag:GameTagPauseSolid cleanup:YES];
	[self removeChildByTag:GameTagPauseMenu cleanup:YES];
	[self removeChildByTag:GameTagPauseTime cleanup:YES];
	[self removeChildByTag:GameTagPauseOf cleanup:YES];
	
	// resume the music
	[appDelegate resumeMusic];
	
	// resume the game
	[stuff resume];
	headsUpDisplay.paused = NO;
}

- (void) doAchievements:(id)sender {
	// if OF is enabled
	if([OpenFeint hasUserApprovedFeint]) {
		[OpenFeint launchDashboardWithAchievementsPage];
	}
	// OF is not enabled, so use my own achievements
	else {
		NSLog(@"Loading my own custom achievements");
		[[CCDirector sharedDirector] pushScene:[CCFadeBLTransition transitionWithDuration:0.5 scene:[AchievementsScene scene]]];
	}
}

- (void) doOptions:(id)sender {
	[[CCDirector sharedDirector] pushScene:
	 [CCFadeBLTransition transitionWithDuration:0.5 scene:
	  [OptionsMenu sceneWithOptions:appDelegate.options music:@"Gameplay.mp3" startPaused:YES]]];
	[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6], [CCCallFunc actionWithTarget:self selector:@selector(doResume:)], nil]];
}

- (void) doQuit:(id)sender {
	if(!instructions) {
		double timeOffsetEnd = [[NSDate date] timeIntervalSince1970];
		timeOffset += (timeOffsetEnd - timeOffsetStart);
		[self endGameplay];
	}
	
	(appDelegate).game = nil;
	[appDelegate stopMusic];
	[appDelegate startMusic:@"Menu.mp3"];
	[[CCDirector sharedDirector] replaceScene:[CCFadeTRTransition transitionWithDuration:0.5 scene:[MainMenu scene]]];
}

- (void) startGameplay:(id)sender {
	gameplayStarted = YES;
	
	// play background music
	[appDelegate startMusic:@"Gameplay.mp3"];
	
	// start the timers
	[stuff schedule: @selector(launch) interval:launchInterval];
	[stuff schedule: @selector(speedIncrease) interval:GameSpeedIncInterval];
	[stuff runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:newObjectInterval], 
					 [CCCallFunc actionWithTarget:stuff selector:@selector(newObject)], 
					 nil]];
}

- (void) endGameplay {
	double timeEnd = [[NSDate date] timeIntervalSince1970];
	time = timeEnd - timeStart - timeOffset;
	
	// update the stats
	stats.totalTimeWasted += time;
	stats.totalScore += score;
	stats.totalLolcats += lolcats;
	stats.totalLollerskaters += lollerskatersCollected;
	stats.totalCheezburgersEaten += cheezburgersEaten;
	stats.totalTrollsKilled += trollsKilled;
	[stats save];
}

- (void) instructionsNext:(id)sender {
	CCSpriteSheet* animSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"InstructionsPrairieDog.png"];
	CCAnimation* anim;
	instructionsStage++;
	
	CCLabel* freeplayLabel1;
	CCLabel* freeplayLabel2;
	
	switch (instructionsStage) {
		case 1:
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCFadeTo actionWithDuration:0.5 opacity:0], 
										   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
										   [CCFadeTo actionWithDuration:0.5 opacity:255], 
										   nil]];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCFadeTo actionWithDuration:0.5 opacity:0], 
												 [CCFadeTo actionWithDuration:0.5 opacity:255], 
												 nil]];
			break;
			
		case 2:
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCFadeTo actionWithDuration:0.5 opacity:0], 
										   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
										   [CCFadeTo actionWithDuration:0.5 opacity:255], 
										   nil]];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCFadeTo actionWithDuration:0.5 opacity:0], 
												 [CCFadeTo actionWithDuration:0.5 opacity:255], 
												 nil]];
			break;
			
		case 3:
			[instructionsSpeech runAction:[CCFadeTo actionWithDuration:0.5 opacity:0]];
			[instructionsSpeechBottom runAction:[CCFadeTo actionWithDuration:0.5 opacity:0]];
			[instructionsPrairieDog runAction:[CCSequence actions:
											   [CCMoveTo actionWithDuration:1.0 position:ccp(595,81)], 
											   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
											   nil]];
			break;
			
		case 4:
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCFadeTo actionWithDuration:0.5 opacity:0], 
										   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
										   [CCFadeTo actionWithDuration:0.5 opacity:255], 
										   nil]];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCFadeTo actionWithDuration:0.5 opacity:0], 
												 [CCFadeTo actionWithDuration:0.5 opacity:255], 
												 nil]];
			break;
			
		case 5:
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCFadeTo actionWithDuration:0.5 opacity:0], 
										   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
										   [CCFadeTo actionWithDuration:0.5 opacity:255], 
										   nil]];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCFadeTo actionWithDuration:0.5 opacity:0], 
												 [CCFadeTo actionWithDuration:0.5 opacity:255], 
												 nil]];
			break;
		
		case 6:
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCFadeTo actionWithDuration:0.5 opacity:0], 
										   [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)], 
										   [CCFadeTo actionWithDuration:0.5 opacity:255], 
										   nil]];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCFadeTo actionWithDuration:0.5 opacity:0], 
												 [CCFadeTo actionWithDuration:0.5 opacity:255], 
												 nil]];
			break;
		
		case 7:
			[instructionsSpeech runAction:[CCFadeTo actionWithDuration:0.5 opacity:0]];
			[instructionsSpeechBottom runAction:[CCFadeTo actionWithDuration:0.5 opacity:0]];
			[instructionsPrairieDog runAction:[CCMoveTo actionWithDuration:1.0 position:ccp(-115,81)]];
			
			freeplayLabel1 = [CCLabel labelWithString:@"tap NEXT when you are done" fontName:@"AmericanTypewriter-Bold" fontSize:20];
			freeplayLabel1.position = ccp(240,260);
			freeplayLabel1.opacity = 0;
			[freeplayLabel1 runAction:[CCFadeTo actionWithDuration:3.0f opacity:255]];
			[self addChild:freeplayLabel1 z:20 tag:GameTagInstructionsFreeplay1];
			freeplayLabel2 = [CCLabel labelWithString:@"to finish with the instructions" fontName:@"AmericanTypewriter-Bold" fontSize:20];
			freeplayLabel2.position = ccp(240,230);
			freeplayLabel2.opacity = 0;
			[freeplayLabel2 runAction:[CCFadeTo actionWithDuration:3.0f opacity:255]];
			[self addChild:freeplayLabel2 z:20 tag:GameTagInstructionsFreeplay2];
			break;
		
		case 8:
			[stuff unschedule:@selector(instructionsLaunch)];
			[self removeChildByTag:GameTagInstructionsFreeplay1 cleanup:YES];
			[self removeChildByTag:GameTagInstructionsFreeplay2 cleanup:YES];
			
			anim = [CCAnimation animationWithName:@"PrairieDogRight" delay:0.1];
			for(int i=0; i<6; i++)
				[anim addFrameWithTexture:animSpriteSheet.texture rect:CGRectMake(i*115, 0, 115, 162)];
			
			instructionsPrairieDog.position = ccp(595, 81);
			[instructionsPrairieDog runAction:[CCSequence actions:
											   [CCMoveTo actionWithDuration:1.0 position:ccp(210, 81)],
											   [CCAnimate actionWithAnimation:anim],
											   nil]];
			instructionsSpeech.position = ccp(315,236);
			[instructionsSpeech setTextureRect:CGRectMake(314, 456, 314, 152)];
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCDelayTime actionWithDuration:1.0],
										   [CCFadeTo actionWithDuration:1.0 opacity:255], 
										   nil]];
			instructionsSpeechBottom.position = ccp(315,139);
			[instructionsSpeechBottom setTextureRect:CGRectMake(314, 608, 314, 42)];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCDelayTime actionWithDuration:1.0],
												 [CCFadeTo actionWithDuration:1.0 opacity:255], 
												 nil]];
			break;
		
		case 9:
			[appDelegate unlockAchievement:ACHIEVEMENT_RTFM];
			[self runAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:0.5], 
							 [CCCallFunc actionWithTarget:self selector:@selector(instructionsBubbleSetRect:)],
							 nil]];
			break;
	}
}

- (void) instructionsBubbleSetRect:(id)sender {
	GameMessage* message;
	CCSpriteSheet* animSpriteSheet = [CCSpriteSheet spriteSheetWithFile:@"InstructionsPrairieDog.png"];
	CCAnimation* anim;
	
	switch(instructionsStage) {
		case 1:
			[instructionsSpeech setTextureRect:CGRectMake(0, 152, 314, 152)];
			player.visible = YES;
			headsUpDisplay.visible = YES;
			headsUpDisplay.dPadLayer.visible = NO;
			headsUpDisplay.brb.visible = NO;
			headsUpDisplay.score.visible = NO;
			break;
			
		case 2:
			[instructionsSpeech setTextureRect:CGRectMake(0, 304, 314, 152)];
			headsUpDisplay.dPadLayer.visible = NO;
			[self schedule:@selector(tick:) interval:0.03f];
			break;
			
		case 3:
			headsUpDisplay.brb.visible = YES;
			instructionsPrairieDog.position = ccp(-115,81);
			[instructionsPrairieDog setTextureRect:CGRectMake(0, 162, 115, 162)];
			anim = [CCAnimation animationWithName:@"PrairieDogLeft" delay:0.1];
			for(int i=0; i<6; i++)
				[anim addFrameWithTexture:animSpriteSheet.texture rect:CGRectMake(i*115, 162, 115, 162)];
			[instructionsPrairieDog runAction:[CCSequence actions:
											   [CCMoveTo actionWithDuration:1.0 position:ccp(274,81)], 
											   [CCAnimate actionWithAnimation:anim], 
											   nil]];
			instructionsSpeech.position = ccp(165,236);
			[instructionsSpeech setTextureRect:CGRectMake(0, 456, 314, 152)];
			[instructionsSpeech runAction:[CCSequence actions:
										   [CCDelayTime actionWithDuration:1.0],
										   [CCFadeTo actionWithDuration:1.0 opacity:255], 
										   nil]];
			instructionsSpeechBottom.position = ccp(165,139);
			[instructionsSpeechBottom setTextureRect:CGRectMake(0, 608, 314, 42)];
			[instructionsSpeechBottom runAction:[CCSequence actions:
												 [CCDelayTime actionWithDuration:1.0],
												 [CCFadeTo actionWithDuration:1.0 opacity:255], 
												 nil]];
			break;
		
		case 4:
			[instructionsSpeech setTextureRect:CGRectMake(314, 0, 314, 152)];
			[stuff schedule:@selector(instructionsLaunch) interval:2.5];
			
			message = [GameMessage spriteWithFile:@"GameMessage.png" rect:CGRectMake(0, 0, 100, 100)];
			[message initMessageWithType:GameMessageTypeLolcats];
			[messageLayer addChild:message];
			break;
			
		case 5:
			[instructionsSpeech setTextureRect:CGRectMake(314, 152, 314, 152)];
			
			message = [GameMessage spriteWithFile:@"GameMessage.png" rect:CGRectMake(0, 0, 100, 100)];
			[message initMessageWithType:GameMessageTypePopups];
			[messageLayer addChild:message];
			break;
		
		case 6:
			[instructionsSpeech setTextureRect:CGRectMake(314, 304, 314, 152)];
			
			message = [GameMessage spriteWithFile:@"GameMessage.png" rect:CGRectMake(0, 0, 100, 100)];
			[message initMessageWithType:GameMessageTypeFlamingTrolls];
			[messageLayer addChild:message];
			break;
		
		case 9:
			[self doQuit:self];
			break;
	}
}

- (void) instructionsLaunch {
	switch(instructionsStage) {
		case 4:
			[self launchLolcat];
			break;
			
		case 5:
			[self launchPopup];
			break;
			
		case 6:
			[self launchTroll:GameTrollTypeFlaming];
			break;
			
		case 7:
			switch((int)(arc4random()%3)) {
				case 0:
					[self launchLolcat];
					break;
				case 1:
					[self launchPopup];
					break;
				case 2:
					[self launchTroll:GameTrollTypeFlaming];
					break;
			}
			break;
	}
}

@end
