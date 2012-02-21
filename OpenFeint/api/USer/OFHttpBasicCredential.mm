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
#import "OFHttpBasicCredential.h"
#import "OFResourceDataMap.h"
#import "OpenFeint+UserOptions.h"

@implementation OFHttpBasicCredential

@synthesize userId;
@synthesize email;
@synthesize cryptedPassword;
@synthesize salt;
@synthesize rememberToken;
@synthesize verified;
@synthesize rememberTokenExpiresAt;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize lastLoginAt;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self != nil)
	{
		resourceId = [[aDecoder decodeObjectForKey:@"resourceId"] retain];
		userId = [[aDecoder decodeObjectForKey:@"userId"] retain];
		email = [[aDecoder decodeObjectForKey:@"email"] retain];
		cryptedPassword = [[aDecoder decodeObjectForKey:@"cryptedPassword"] retain];
		salt = [[aDecoder decodeObjectForKey:@"salt"] retain];
		rememberToken = [(NSNumber*)[aDecoder decodeObjectForKey:@"rememberToken"] boolValue];
		verified = [(NSNumber*)[aDecoder decodeObjectForKey:@"verified"] boolValue];
		rememberTokenExpiresAt = [[aDecoder decodeObjectForKey:@"rememberTokenExpiresAt"] retain];
		createdAt = [[aDecoder decodeObjectForKey:@"createdAt"] retain];
		updatedAt = [[aDecoder decodeObjectForKey:@"updatedAt"] retain];
		lastLoginAt = [[aDecoder decodeObjectForKey:@"lastLoginAt"] retain];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:resourceId forKey:@"resourceId"];
	[aCoder encodeObject:userId forKey:@"userId"];
	[aCoder encodeObject:email forKey:@"email"];
	[aCoder encodeObject:cryptedPassword forKey:@"cryptedPassword"];
	[aCoder encodeObject:salt forKey:@"salt"];
	[aCoder encodeObject:[NSNumber numberWithBool:rememberToken] forKey:@"rememberToken"];
	[aCoder encodeObject:[NSNumber numberWithBool:verified] forKey:@"verified"];
	[aCoder encodeObject:rememberTokenExpiresAt forKey:@"rememberTokenExpiresAt"];
	[aCoder encodeObject:createdAt forKey:@"createdAt"];
	[aCoder encodeObject:updatedAt forKey:@"updatedAt"];
	[aCoder encodeObject:lastLoginAt forKey:@"lastLoginAt"];
}

- (void)setUserId:(NSString*)value
{
	OFSafeRelease(userId);
	userId = [value retain];
}

- (void)setEmail:(NSString*)value
{
	OFSafeRelease(email);
	email = [value retain];
}

- (void)setCryptedPassword:(NSString*)value
{
	OFSafeRelease(cryptedPassword);
	cryptedPassword = [value retain];
}

- (void)setSalt:(NSString*)value
{
	OFSafeRelease(salt);
	salt = [value retain];
}

- (void)setRememberTokenExpiresAt:(NSString*)value
{
	OFSafeRelease(rememberTokenExpiresAt);
	rememberTokenExpiresAt = [value retain];
}

- (void)setCreatedAt:(NSString*)value
{
	OFSafeRelease(createdAt);
	createdAt = [value retain];
}

- (void)setUpdatedAt:(NSString*)value
{
	OFSafeRelease(updatedAt);
	updatedAt = [value retain];
}

- (void)setLastLoginAt:(NSString*)value
{
	OFSafeRelease(lastLoginAt);
	lastLoginAt = [value retain];
}

- (NSString*)getRememberTokenAsString
{
	return [NSString stringWithFormat:@"%u", (uint)rememberToken];
}

- (NSString*)getVerifiedAsString
{
	return [NSString stringWithFormat:@"%u", (uint)verified];
}

- (void)setRememberTokenAsString:(NSString*)value
{
	rememberToken = [value boolValue];
}

- (void)setVerifiedAsString:(NSString*)value
{
	verified = [value boolValue];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"user_id",							@selector(setUserId:), @selector(userId));
		dataMap->addField(@"email",			@selector(setEmail:), @selector(email));
		dataMap->addField(@"crypted_password",	@selector(setCryptedPassword:), @selector(cryptedPassword));
		dataMap->addField(@"salt",			@selector(setSalt:), @selector(salt));
		dataMap->addField(@"remember_token",			@selector(setRememberTokenAsString:), @selector(getRememberTokenAsString));
		dataMap->addField(@"verified",					@selector(setVerified:), @selector(getVerifiedAsString));
		dataMap->addField(@"remember_token_expires_at",			@selector(setRememberTokenExpiresAt:), @selector(rememberTokenExpiresAt));
		dataMap->addField(@"created_at",		@selector(setCreatedAt:), @selector(createdAt));
		dataMap->addField(@"updated_at",		@selector(setUpdatedAt:), @selector(updatedAt));
		dataMap->addField(@"last_login_at",		@selector(setLastLoginAt:), @selector(lastLoginAt));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"http_basic_credential";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(userId);
	OFSafeRelease(email);
	OFSafeRelease(cryptedPassword);
	OFSafeRelease(salt);

	OFSafeRelease(rememberTokenExpiresAt);
	OFSafeRelease(createdAt);
	OFSafeRelease(updatedAt);
	OFSafeRelease(lastLoginAt);
	[super dealloc];
}

@end