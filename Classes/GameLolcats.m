//
//  GameLolcats.m
//  tehinternets
//
//  Created by micah on 10/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameLolcats.h"

@implementation GameLolcats

- (id)init {
	if((self = [super init])) {
		NSLog(@"GameLolcats init");
		
		// lolcat manager
		lolcatManager = [AtlasSpriteManager spriteManagerWithFile:@"GameLolcats.png"];
		[self addChild:lolcatManager];
		
		// init phrases array
		phrases = [NSMutableArray array];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"GameLolcats dealloc");
	[super dealloc];
}

- (NSString*) getPhrase {
	// if there are no phrases in the queue, come up with new phrase
	if([phrases count] == 0) {
		switch((int)(arc4random()%15)) {
			case 0:
				[phrases addObject:@"planning ur doom"];
				return @"in ur gamez";
				break;
			case 1:
				[phrases addObject:@"lisnin 2 ur t00nz"];
				return @"in ur ipod";
				break;
			case 2:
				[phrases addObject:@"sniffing ur packitz"];
				return @"serfing ur internets";
				break;
			case 3:
				[phrases addObject:@"reeding ur txtz"];
				return @"in urz fone";
				break;
			case 4:
				[phrases addObject:@"in ur if0wn"];
				return @"i chays bugz";
				break;
			case 5:
				[phrases addObject:@"iz teh lulz"];
				return @"insurgent games";
				break;
			case 6:
				return @"ai eated ur pakitz";
				break;
			case 7:
				return @"ai pwnz de intrewebz";
				break;
			case 8:
				return @"yuz fingerz iz stiky";
				break;
			case 9:
				return @"u plz can haz downlowed me?";
				break;
			case 10:
				return @"iz srsly dizzzie";
				break;
			case 11:
				return @"git me. kthxbai.";
				break;
			case 12:
				return @"ctrl-alt-deleet";
				break;
			case 13:
				return @"uz fingrz iz hyewge";
				break;
			case 14:
				return @"i can haz cheezburgr?";
				break;
		}
	}
	// otherwise, return the first item on the queue
	else {
		NSString* ret = (NSString*)[phrases objectAtIndex:0];
		[phrases removeObjectAtIndex:0];
		return ret;
	}
}

@end
