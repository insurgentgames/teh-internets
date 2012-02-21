#import <Foundation/Foundation.h>

@interface Options : NSObject {
	NSArray* options;
	BOOL musicEnabled;
	BOOL soundEnabled;
}

@property (nonatomic,retain) NSArray* options;
@property (readwrite) BOOL musicEnabled;
@property (readwrite) BOOL soundEnabled;

- (NSString*)getFilePath;
- (void) load;
- (void) save;

@end
