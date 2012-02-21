#import "NoOfAchievements.h"
#import "tehinternetsAppDelegate.h"

@implementation NoOfAchievements

@synthesize achievements;

- (id) init {
	if((self = [super init])) {
		NSLog(@"NoOfAchievements init");
		[self load];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"NoOfAchievements dealloc");
	[super dealloc];
}

- (NSString*)getFilePath {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"NoOfAchievements.plist"];
}

- (void) load {
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getFilePath]]) {
		NSLog(@"Loading NoOfAchievements");
		self.achievements = [NSMutableDictionary dictionaryWithContentsOfFile:[self getFilePath]];
		//[self display];
	} else {
		NSLog(@"Create new NoOfAchievements files");
		NSArray* keys = [NSArray arrayWithObjects:[NSString stringWithString:@"64913"], [NSString stringWithString:@"69443"], 
						 [NSString stringWithString:@"69453"], [NSString stringWithString:@"69463"], [NSString stringWithString:@"69473"], 
						 [NSString stringWithString:@"69483"], [NSString stringWithString:@"69503"], [NSString stringWithString:@"69513"], 
						 [NSString stringWithString:@"69533"], [NSString stringWithString:@"69543"], [NSString stringWithString:@"69553"], 
						 [NSString stringWithString:@"69573"], [NSString stringWithString:@"69583"], [NSString stringWithString:@"69593"], 
						 [NSString stringWithString:@"69603"], [NSString stringWithString:@"69613"], [NSString stringWithString:@"69623"], 
						 [NSString stringWithString:@"69633"], [NSString stringWithString:@"69643"], [NSString stringWithString:@"69653"], 
						 [NSString stringWithString:@"69663"], [NSString stringWithString:@"69673"], [NSString stringWithString:@"69683"], 
						 nil];
		NSArray* objects = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], 
							nil];
		self.achievements = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
		[self save];
	}
}

- (void) save {
	NSLog(@"Saving NoOfAchievements");
	[self.achievements writeToFile:[self getFilePath] atomically:YES];
	//[self display];
}

- (void) display {
	NSString* key;
	NSString* title;
	NSString* unlocked;
	for(key in [self.achievements allKeys]) {
		title = [(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) getAchievementTitle:key];
		if([self isAchievementUnlocked:key] == YES)
			unlocked = @"UNLOCKED";
		else
			unlocked = @"LOCKED";
		NSLog(@"%@ Achievement: %@", unlocked, title);
	}
}

- (void) unlockAchievement:(NSString*)achievementId {
	if([self isAchievementUnlocked:achievementId]) {
		NSLog(@"Achievement %@, %@ is already unlocked", achievementId, [(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) getAchievementTitle:achievementId]);
		return;
	}
	
	[self.achievements setValue:[NSNumber numberWithBool:YES] forKey:achievementId];
	[self save];
}

- (BOOL) isAchievementUnlocked:(NSString*)achievementId {
	//NSLog(@"Checking to see if achievement %@, %@ is unlocked", achievementId, [(tehinternetsAppDelegate*)([UIApplication sharedApplication].delegate) getAchievementTitle:achievementId]);
	NSNumber* val = [self.achievements objectForKey:achievementId];
	return [val boolValue];
}

@end
