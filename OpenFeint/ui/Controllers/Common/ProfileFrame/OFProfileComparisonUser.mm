////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// 
///  Copyright 2009 Aurora Feint, Inc.
/// 
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///  
///  	http://www.apache.org/licenses/LICENSE-2.0
///  	
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
/// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "OFProfileComparisonUser.h"
#import "OFUser.h"
#import "OFImageView.h"

#import "OpenFeint+Private.h"

@implementation OFProfileComparisonUser

@synthesize user;

- (void)awakeFromNib
{
	if ([OpenFeint isInLandscapeMode])
	{
		avatar.transform = CGAffineTransformMake(0.f, 1.f, -1.f, 0.f, 0.f, 0.f);
	}
}

- (void)setUser:(OFUser*)_user
{
	OFSafeRelease(user);
	user = [_user retain];
	
	[avatar useProfilePictureFromUser:user];
	avatar.useFacebookOverlay = NO;
	score.text = [NSString stringWithFormat:@"%d", user.gamerScore];
}

- (void)dealloc
{
	OFSafeRelease(user);
	OFSafeRelease(avatar);
	OFSafeRelease(score);
	[super dealloc];
}

@end