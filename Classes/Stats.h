#import <Foundation/Foundation.h>

@interface Stats : NSObject {
	NSArray* stats;
	int totalTimeWasted;
	int totalScore;
	int totalLolcats;
	int totalLollerskaters;
	int totalCheezburgersEaten;
	int totalTrollsKilled;
}

@property (nonatomic,retain) NSArray* stats;
@property (readwrite) int totalTimeWasted;
@property (readwrite) int totalScore;
@property (readwrite) int totalLolcats;
@property (readwrite) int totalLollerskaters;
@property (readwrite) int totalCheezburgersEaten;
@property (readwrite) int totalTrollsKilled;

- (NSString*)getFilePath;
- (void) load;
- (void) save;
- (void) display;

@end
