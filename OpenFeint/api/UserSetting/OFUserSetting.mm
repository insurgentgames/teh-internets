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
#import "OFUserSetting.h"
#import "OFUserSettingService.h"
#import "OFResourceDataMap.h"

@implementation OFUserSetting

@synthesize name;
@synthesize value;
@synthesize valueType;
@synthesize key;

- (void)setName:(NSString*)_value
{
	OFSafeRelease(name);
	name = [_value retain];
}

- (void)setValueType:(NSString*)_value
{
	OFSafeRelease(valueType);
	valueType = [_value retain];
}

- (void)setKey:(NSString*)_value
{
	OFSafeRelease(key);
	key = [_value retain];
}

+ (OFService*)getService;
{
	return [OFUserSettingService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name",			@selector(setName:));
		dataMap->addField(@"value",			@selector(setValue:));
		dataMap->addField(@"value_type",	@selector(setValueType:));		
		dataMap->addField(@"key",			@selector(setKey:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"user_setting";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return @"openfeint_user_setting_discovered";
}

- (void) dealloc
{
	[name release];
	[value release];
	[valueType release];
	[super dealloc];
}

@end
