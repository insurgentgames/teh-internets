//
//  MPOAuthAPI+TokenAdditionsiPhone.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.13.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthAPI+KeychainAdditions.h"
#import <Security/Security.h>

#if TARGET_OS_IPHONE && (! TARGET_IPHONE_SIMULATOR)


@implementation MPOAuthAPI (KeychainAdditions)

- (NSMutableDictionary*) _getKeychainFindQuery:(NSString*)inName
{
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];
	NSMutableDictionary *findQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:	
		(id)kSecClassInternetPassword,					kSecClass,
		securityDomain,									kSecAttrSecurityDomain,
		serverName,										kSecAttrServer,
		inName,											kSecAttrAccount,
		kSecAttrAuthenticationTypeDefault,				kSecAttrAuthenticationType,
		[NSNumber numberWithUnsignedLongLong:'oaut'],	kSecAttrType,
		nil
	];												
	
	return findQuery;
}

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue
{
	[self removeValueFromKeychainUsingName:inName];

	if(inValue == nil)
	{
		return;
	}
	
	NSMutableDictionary* addQuery = [self _getKeychainFindQuery:inName];
    [addQuery setObject:[inValue dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];	
	int statusCode = SecItemAdd((CFDictionaryRef)addQuery, NULL);
	NSAssert1(statusCode == noErr, @"Failed adding to keychain: %d", statusCode);
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName
{
	NSMutableDictionary* findQuery = [self _getKeychainFindQuery:inName];
	[findQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[findQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSData *keychainValueData = nil;
	int copyResultCode = SecItemCopyMatching((CFDictionaryRef)findQuery, (CFTypeRef *)&keychainValueData);
	
	NSString* foundValue = nil;
	if(copyResultCode == noErr)
	{
        foundValue = [[[NSString alloc] initWithBytes:[keychainValueData bytes] length:[keychainValueData length]  encoding:NSUTF8StringEncoding] autorelease];
		[keychainValueData release];
	}
	
	return foundValue;
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName
{	
	NSString *serverName = [_baseURL host];
	NSString *securityDomain = [_authenticationURL host];	
	NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassInternetPassword, (id)kSecClass,
																							  securityDomain, (id)kSecAttrSecurityDomain,
																							  serverName, (id)kSecAttrServer,
																							  inName, (id)kSecAttrAccount,
											nil];
	SecItemDelete((CFDictionaryRef)searchDictionary);
}

@end

#endif TARGET_OS_IPHONE
