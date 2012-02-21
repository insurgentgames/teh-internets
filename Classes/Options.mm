#import "Options.h"

@implementation Options

@synthesize options;
@synthesize musicEnabled;
@synthesize soundEnabled;

- (id) init {
	if((self = [super init])) {
		NSLog(@"Options init");
		[self load];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"Options dealloc");
	[super dealloc];
}

- (NSString*)getFilePath {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Options.plist"];
}

- (void) load {
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getFilePath]]) {
		NSLog(@"Loading options");
		options = [NSArray arrayWithContentsOfFile:[self getFilePath]];
		musicEnabled = [[options objectAtIndex:0] boolValue];
		soundEnabled = [[options objectAtIndex:1] boolValue];
	} else {
		NSLog(@"Create new options files");
		musicEnabled = YES;
		soundEnabled = YES;
		[self save];
	}
}

- (void) save {
	NSLog(@"Saving options");
	options = [NSArray arrayWithObjects:
			   [NSNumber numberWithBool:musicEnabled], 
			   [NSNumber numberWithBool:soundEnabled], 
			   nil];
	[options writeToFile:[self getFilePath] atomically:YES];
}


@end
