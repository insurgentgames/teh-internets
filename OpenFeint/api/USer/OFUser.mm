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

#import "OFDependencies.h"
#import "OFUser.h"
#import "OFResourceDataMap.h"
#import "OpenFeint+UserOptions.h"

#define FORCE_ONLINE 0

@implementation OFUser

@synthesize name;
@synthesize profilePictureUrl;
@synthesize profilePictureSource;
@synthesize usesFacebookProfilePicture;
@synthesize lastPlayedGameId;
@synthesize lastPlayedGameName;
@synthesize gamerScore;
@synthesize followsLocalUser;
@synthesize followedByLocalUser;
@synthesize online;
@synthesize latitude;
@synthesize longitude;

- (id)initWithLocalSQL:(OFSqlQuery*)queryRow
{
	self = [super init];
	if (self != nil)
	{	
		resourceId = [[NSString stringWithFormat:@"%s", queryRow->getText("id")] retain];
		name = [[NSString stringWithUTF8String:queryRow->getText("name")] retain];
		profilePictureUrl = [[NSString stringWithFormat:@"%s", queryRow->getText("profile_picture_url")] retain];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self != nil)
	{
		resourceId = [[aDecoder decodeObjectForKey:@"resourceId"] retain];
		name = [[aDecoder decodeObjectForKey:@"name"] retain];
		profilePictureUrl = [[aDecoder decodeObjectForKey:@"profilePictureUrl"] retain];
		profilePictureSource = [[aDecoder decodeObjectForKey:@"profilePictureSource"] retain];
		usesFacebookProfilePicture = [(NSNumber*)[aDecoder decodeObjectForKey:@"usesFacebookProfilePicture"] boolValue];
		lastPlayedGameId = [[aDecoder decodeObjectForKey:@"lastPlayedGameId"] retain];
		lastPlayedGameName = [[aDecoder decodeObjectForKey:@"lastPlayedGameName"] retain];
		followsLocalUser = [(NSNumber*)[aDecoder decodeObjectForKey:@"followsLocalUser"] boolValue];
		followedByLocalUser = [(NSNumber*)[aDecoder decodeObjectForKey:@"followedByLocalUser"] boolValue];
		gamerScore = [(NSNumber*)[aDecoder decodeObjectForKey:@"gamerScore"] intValue];
		online = [(NSNumber*)[aDecoder decodeObjectForKey:@"online"] boolValue];
		latitude = [(NSNumber*)[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
		longitude = [(NSNumber*)[aDecoder decodeObjectForKey:@"longitude"] doubleValue];

	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:resourceId forKey:@"resourceId"];
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:profilePictureUrl forKey:@"profilePictureUrl"];
	[aCoder encodeObject:profilePictureSource forKey:@"profilePictureSource"];
	[aCoder encodeObject:[NSNumber numberWithBool:usesFacebookProfilePicture] forKey:@"usesFacebookProfilePicture"];
	[aCoder encodeObject:lastPlayedGameId forKey:@"lastPlayedGameId"];
	[aCoder encodeObject:lastPlayedGameName forKey:@"lastPlayedGameName"];
	[aCoder encodeObject:[NSNumber numberWithBool:followsLocalUser] forKey:@"followsLocalUser"];
	[aCoder encodeObject:[NSNumber numberWithBool:followedByLocalUser] forKey:@"followedByLocalUser"];
	[aCoder encodeObject:[NSNumber numberWithInt:gamerScore] forKey:@"gamerScore"];
	[aCoder encodeObject:[NSNumber numberWithBool:online] forKey:@"online"];
	[aCoder encodeObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
	[aCoder encodeObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];

}

- (void)setName:(NSString*)value
{
	OFSafeRelease(name);
	name = [value retain];
}

- (void)setProfilePictureUrl:(NSString*)value
{
	OFSafeRelease(profilePictureUrl);
	if (![value isEqualToString:@""])
	{
		profilePictureUrl = [value retain];
	}
}

- (void)setProfilePictureSource:(NSString*)value
{
	OFSafeRelease(profilePictureSource);
	if (![value isEqualToString:@""])
	{
		profilePictureSource = [value retain];
	}
}

- (void)setUsesFacebookProfilePicture:(NSString*)value
{
	usesFacebookProfilePicture = [value boolValue];
}

- (NSString*)getUsesFacebookProfilePictureAsString
{
	return [NSString stringWithFormat:@"%u", (uint)usesFacebookProfilePicture];
}

- (NSString*)getFollowsLocalUserAsString
{
	return [NSString stringWithFormat:@"%u", (uint)followsLocalUser];
}

- (NSString*)getFollowedByLocalUserAsString
{
	return [NSString stringWithFormat:@"%u", (uint)followedByLocalUser];
}

- (NSString*)getOnlineAsString
{
	return [NSString stringWithFormat:@"%u", (uint)online];
}

- (NSString*)getGamerScoreAsString
{
	return [NSString stringWithFormat:@"%u", (uint)gamerScore];
}

- (void)setLastPlayedGameId:(NSString*)value
{
	OFSafeRelease(lastPlayedGameId);
	lastPlayedGameId = [value retain];
}

- (void)setLastPlayedGameName:(NSString*)value
{
	OFSafeRelease(lastPlayedGameName);
	lastPlayedGameName = [value retain];
}

- (void)setGamerScore:(NSString*)value
{
	gamerScore = [value intValue];
}

- (void)setFollowsLocalUserAsString:(NSString*)value
{
	followsLocalUser = [value boolValue];
}

- (void)setFollowedByLocalUserAsString:(NSString*)value
{
	followedByLocalUser = [value boolValue];
}

- (void)setOnlineAsString:(NSString*)value
{
	online = [value boolValue];
}

- (void) setLatitude:(NSString*)value
{
	latitude = [value doubleValue];
}

- (NSString*)getLatitudeAsString
{
	return [NSString stringWithFormat:@"%f", latitude];
}

- (void) setLongitude:(NSString*)value
{
	longitude = [value doubleValue];
}

- (NSString*)getLongitudeAsString
{
	return [NSString stringWithFormat:@"%f", longitude];
}

+ (id)invalidUser
{
	OFUser* user = [[[OFUser alloc] init] autorelease];
	user->resourceId = @"0";
	user->name = @"Not Logged In";
	user->lastPlayedGameName = @"OpenFeint Game";
	
	return user;
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name",							@selector(setName:), @selector(name));
		dataMap->addField(@"profile_picture_url",			@selector(setProfilePictureUrl:), @selector(profilePictureUrl));
		dataMap->addField(@"profile_picture_source",		@selector(setProfilePictureSource:), @selector(profilePictureSource));
		dataMap->addField(@"uses_facebook_profile_picture",	@selector(setUsesFacebookProfilePicture:), @selector(getUsesFacebookProfilePictureAsString));
		dataMap->addField(@"last_played_game_id",			@selector(setLastPlayedGameId:), @selector(lastPlayedGameId));
		dataMap->addField(@"last_played_game_name",			@selector(setLastPlayedGameName:), @selector(lastPlayedGameName));
		dataMap->addField(@"gamer_score",					@selector(setGamerScore:), @selector(getGamerScoreAsString));
		dataMap->addField(@"following_local_user",			@selector(setFollowsLocalUserAsString:), @selector(getFollowsLocalUserAsString));
		dataMap->addField(@"followed_by_local_user",		@selector(setFollowedByLocalUserAsString:), @selector(getFollowedByLocalUserAsString));
		dataMap->addField(@"online",						@selector(setOnlineAsString:), @selector(getOnlineAsString));
		dataMap->addField(@"lat",							@selector(setLatitude:), @selector(getLatitudeAsString));
		dataMap->addField(@"lng",							@selector(setLongitude:), @selector(getLongitudeAsString));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"user";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"user_discovered";
}

- (bool)isLocalUser
{
	return [self.resourceId isEqualToString:[OpenFeint lastLoggedInUserId]] || [self.resourceId isEqualToString:@"0"];
}

#if FORCE_ONLINE
- (BOOL)online
{
    return YES;
}
#endif

- (void)adjustGamerscore:(int)gamerscoreAdjustment
{
	gamerScore += gamerscoreAdjustment;
}

- (void)changeProfilePictureUrl:(NSString*)url facebook:(BOOL)isFacebook twitter:(BOOL)isTwitter uploaded:(BOOL)isUploaded
{
	[self setProfilePictureUrl:url];
	usesFacebookProfilePicture = isFacebook;

	if (isFacebook)
	{
		[self setProfilePictureSource:@"FbconnectCredential"];
	}
	else if (isTwitter)
	{
		[self setProfilePictureSource:@"TwitterCredential"];
	}
    else if (isUploaded)
    {
        [self setProfilePictureSource:@"Upload"];
    }
	else
	{
		[self setProfilePictureSource:nil];
	}
}

- (void) dealloc
{
	OFSafeRelease(name);
	OFSafeRelease(profilePictureUrl);
	OFSafeRelease(profilePictureSource);
	OFSafeRelease(lastPlayedGameName);
	OFSafeRelease(lastPlayedGameId);
	[super dealloc];
}

@end