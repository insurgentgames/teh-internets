//
//  MPOAuthAPI+KeychainAdditionsiPhoneSimulator.mm
//  OpenFeint
//
//  Created by Jason Citron on 2/22/09.
//  Copyright 2009 Aurora Feint Inc.. All rights reserved.
//

#if TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR

#import "MPOAuthAPI+KeychainAdditions.h"
#import "OFTransactionalSaveFile.h"

namespace
{
	NSMutableDictionary* gFakeKeychain = nil;
	
	NSString* getFakeKeychainPath()
	{
		return OFTransactionalSaveFile::getSavePathForFile(@"FakeKeychain.plist");
	}
}

@interface MPOAuthAPI (KeychainAdditionsiPhoneSimulator)
@end

@implementation MPOAuthAPI (KeychainAdditionsiPhoneSimulator)

- (void)loadFakeKeychain
{	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:getFakeKeychainPath()];
	NSString* errorDesc;
	NSPropertyListFormat format;
 
	gFakeKeychain = (NSMutableDictionary *)[NSPropertyListSerialization 
			propertyListFromData:plistXML
            mutabilityOption:NSPropertyListMutableContainers
            format:&format 
			errorDescription:&errorDesc];
	
	if(!gFakeKeychain)
	{
		gFakeKeychain = [NSMutableDictionary dictionaryWithCapacity:2];
		OFLog(@"Unable to load fake keychain: %s", [errorDesc UTF8String]);
		[errorDesc release];
	}
}

- (void)saveFakeKeychain
{	
	NSString* errorDesc;
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:gFakeKeychain format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorDesc];
	if(plistData)
	{
		[plistData writeToFile:getFakeKeychainPath() atomically:YES];
	}
	else
	{
		OFAssert(0, "Error saving fake keychain: %s", [errorDesc UTF8String]);
		[errorDesc release];
	}
}

- (NSString*)getUniqueNameForKey:(NSString*)inName
{
	NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
	NSString *uniqueName = [NSString stringWithFormat:@"%@.%@", bundleID, inName];
	return uniqueName;
}

- (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue
{	
	[self loadFakeKeychain];

	id valueToSet = inValue;
	if(valueToSet == nil)
	{
		valueToSet = @"";
	}

	NSString* uniqueName = [self getUniqueNameForKey:inName];	
	[gFakeKeychain setObject:valueToSet forKey:uniqueName];

	[self saveFakeKeychain];
}

- (NSString *)findValueFromKeychainUsingName:(NSString *)inName
{
	[self loadFakeKeychain];

	NSString* uniqueName = [self getUniqueNameForKey:inName];	
	return (NSString*)[gFakeKeychain objectForKey:uniqueName];
}

- (void)removeValueFromKeychainUsingName:(NSString *)inName
{
	[self loadFakeKeychain];

	NSString* uniqueName = [self getUniqueNameForKey:inName];
	[gFakeKeychain removeObjectForKey:uniqueName];

	[self saveFakeKeychain];
}

@end

#endif