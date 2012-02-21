#import "Stats.h"
#import "OFAchievementService.h"
#import "Achievements.h"
#import "tehinternetsAppDelegate.h"

@implementation Stats

@synthesize stats;
@synthesize totalTimeWasted;
@synthesize totalScore;
@synthesize totalLolcats;
@synthesize totalLollerskaters;
@synthesize totalCheezburgersEaten;
@synthesize totalTrollsKilled;

- (id) init {
	if((self = [super init])) {
		NSLog(@"Stats init");
		[self load];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"Stats dealloc");
	[super dealloc];
}

- (NSString*)getFilePath {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Stats.plist"];
}

- (void) load {
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getFilePath]]) {
		NSLog(@"Loading stats");
		stats = [NSArray arrayWithContentsOfFile:[self getFilePath]];
		totalTimeWasted			= [[stats objectAtIndex:0] intValue];
		totalScore				= [[stats objectAtIndex:1] intValue];
		totalLolcats			= [[stats objectAtIndex:2] intValue];
		totalLollerskaters		= [[stats objectAtIndex:3] intValue];
		totalCheezburgersEaten	= [[stats objectAtIndex:4] intValue];
		totalTrollsKilled		= [[stats objectAtIndex:5] intValue];
	} else {
		NSLog(@"Create new stats files");
		totalTimeWasted			= 0;
		totalScore				= 0;
		totalLolcats			= 0;
		totalLollerskaters		= 0;
		totalCheezburgersEaten	= 0;
		totalTrollsKilled		= 0;
		[self save];
	}
}

- (void) save {
	NSLog(@"Saving stats");
	stats = [NSArray arrayWithObjects:
			 [NSNumber numberWithInt:totalTimeWasted], 
			 [NSNumber numberWithInt:totalScore],
			 [NSNumber numberWithInt:totalLolcats],
			 [NSNumber numberWithInt:totalLollerskaters],
			 [NSNumber numberWithInt:totalCheezburgersEaten], 
			 [NSNumber numberWithInt:totalTrollsKilled],
			   nil];
	[stats writeToFile:[self getFilePath] atomically:YES];
	
	[self display];
	
	// submit total achievements
	[((tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate)) submitTotals];
	
	// 12 hours?
	if(totalTimeWasted >= 43200)
		[OFAchievementService unlockAchievement:ACHIEVEMENT_IS_THIS_GONNA_BE_FOREVER];
}

- (void) display {
	NSLog(@"Stats totalTimeWasted: %i", totalTimeWasted);
	NSLog(@"Stats totalScore: %i", totalScore);
	NSLog(@"Stats totalLolcats: %i", totalLolcats);
	NSLog(@"Stats totalLollerskaters: %i", totalLollerskaters);
	NSLog(@"Stats totalCheezburgersEaten: %i", totalCheezburgersEaten);
	NSLog(@"Stats totalTrollsKilled: %i", totalTrollsKilled);
}

@end
