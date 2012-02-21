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
#import "OFCloudStorageBlob.h"
#import "OFCloudStorageService.h"
#import "OFResourceDataMap.h"

@implementation OFCloudStorageBlob

@synthesize user, keyStr, payload;


- (void)setUser:(OFUser*)value
{
	OFSafeRelease(user);
	user = [value retain];
}


- (void)setKeyStr:(NSString*)value
{
	OFSafeRelease(keyStr);
	keyStr = [value retain];
}


- (void)setPayload:(NSData*)value
{
	OFSafeRelease(payload);
	payload = [value retain];
}


+ (OFService*)getService;
{
	return [OFCloudStorageService sharedInstance];
}


+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"user", @selector(setUser:));
		dataMap->addField(@"keyStr", @selector(setKeyStr:));
		dataMap->addField(@"payload", @selector(setPayload:));
	}
	
	return dataMap.get();
}


+ (NSString*)getResourceName
{
	//return @"cloud_storage_blob";
	return @"cloud_store";
}


+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_cloud_storage_blob_discovered";
}


- (void) dealloc
{
	self.user = nil;
	self.keyStr = nil;
	self.payload = nil;
	
	[super dealloc];
}


@end
