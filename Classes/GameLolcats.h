//
//  GameLolcats.h
//  tehinternets
//
//  Created by micah on 10/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface GameLolcats : Layer {
	NSMutableArray* phrases;
	AtlasSpriteManager* lolcatManager;
}

- (NSString*) getPhrase;

@end
