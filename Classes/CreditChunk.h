#import "cocos2d.h"

#define CreditChunkY1 260
#define CreditChunkY2 180
#define CreditChunkY3 140

@interface CreditChunk : CCLayer {

}

- (void) initStr1:(NSString*)str1 str2:(NSString*)str2 str3:(NSString*)str3;
- (void) die;

@end
