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
#import "OFUsersCredential.h"
#import "OFUsersCredentialService.h"
#import "OFResourceDataMap.h"



struct OFKnownCredentialDisplayName
{
	OFKnownCredentialDisplayName(NSString* _credentialType, NSString* _displayName)
	: credentialType(_credentialType)
	, displayName(_displayName)
	{
	}
	
	OFRetainedPtr<NSString> credentialType;
	OFRetainedPtr<NSString> displayName;
};

namespace  
{
	static OFKnownCredentialDisplayName sKnownCredentials[] = 
	{
	OFKnownCredentialDisplayName(@"twitter", @"Twitter"),
	OFKnownCredentialDisplayName(@"fbconnect", @"Facebook"),
	OFKnownCredentialDisplayName(@"http_basic", @"Email & Password"),
	};
}

@implementation OFUsersCredential

@synthesize credentialType;
@synthesize credentialProfilePictureUrl;
@synthesize profilePictureUpdatedAt;
@synthesize hasGlobalPermissions;
@synthesize isLinked;

- (void)setCredentialType:(NSString*)_value
{
	OFSafeRelease(credentialType);
	credentialType = [_value retain];
}

- (void)setCredentialProfilePictureUrl:(NSString*)_value
{
	OFSafeRelease(credentialProfilePictureUrl);
	credentialProfilePictureUrl = [_value retain];
}

- (void)setProfilePictureUpdatedAt:(NSString*)_value
{
	OFSafeRelease(profilePictureUpdatedAt);
	profilePictureUpdatedAt = [_value retain];
}

- (void)setHasGlobalPermissions:(NSString*)_value
{
	if([_value isEqualToString:@"true"])
	{
		hasGlobalPermissions = YES;
	}
	else
	{
		hasGlobalPermissions = NO;
	}
}

- (void)setIsLinked:(NSString*)_value
{
	isLinked = [_value boolValue];
}

+ (OFService*)getService;
{
	return [OFUsersCredentialService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"credential_type",	@selector(setCredentialType:));		
		dataMap->addField(@"profile_picture_url", @selector(setCredentialProfilePictureUrl:));
		dataMap->addField(@"profile_picture_updated_at", @selector(setProfilePictureUpdatedAt:));
		dataMap->addField(@"has_global_permissions", @selector(setHasGlobalPermissions:));
		dataMap->addField(@"is_linked", @selector(setIsLinked:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"users_credential";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_users_credential_discovered";
}

+ (NSString*)getDisplayNameForCredentialType:(NSString*)credentialType
{
	for (unsigned int i = 0; i < sizeof(sKnownCredentials) / sizeof(OFKnownCredentialDisplayName); i++)
	{
		if ([sKnownCredentials[i].credentialType.get() isEqualToString:credentialType])
		{
			return sKnownCredentials[i].displayName;
		}
	}
	return nil;
}

- (BOOL)isFacebook
{
	return [credentialType isEqualToString:@"fbconnect"];
}

- (BOOL)isTwitter
{
	return [credentialType isEqualToString:@"twitter"];
}

- (BOOL)isHttpBasic
{
	return [credentialType isEqualToString:@"http_basic"];
}

- (void) dealloc
{
	OFSafeRelease(credentialType);
	OFSafeRelease(credentialProfilePictureUrl);
	[super dealloc];
}

@end
