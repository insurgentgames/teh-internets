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
#import "OFApplicationDescription.h"
#import "OFApplicationDescriptionService.h"
#import "OFResourceDataMap.h"

@implementation OFApplicationDescription

@synthesize name, iconUrl, itunesId, price, currentVersion, briefDescription, extendedDescription, applicationId;

- (void)setName:(NSString*)value
{
	OFSafeRelease(name);
	name = [value retain];
}

- (void)setIconUrl:(NSString*)value
{
	OFSafeRelease(iconUrl);
	if (![value isEqualToString:@""])
	{
		iconUrl = [value retain];
	}
}

- (void)setItunesId:(NSString*)value
{
	OFSafeRelease(itunesId);
	itunesId = [value retain];
}

- (void)setPrice:(NSString*)value
{
	OFSafeRelease(price);
	price = [value retain];
}

- (void)setCurrentVersion:(NSString*)value
{
	OFSafeRelease(currentVersion);
	currentVersion = [value retain];
}

- (void)setBriefDescription:(NSString*)value
{
	OFSafeRelease(briefDescription);
	briefDescription = [value retain];
}

- (void)setExtendedDescription:(NSString*)value
{
	OFSafeRelease(extendedDescription);
	extendedDescription = [value retain];
}

- (void)setApplicationId:(NSString*)value
{
	OFSafeRelease(applicationId);
	applicationId = [value retain];
}

+ (OFService*)getService;
{
	return [OFApplicationDescriptionService sharedInstance];
}

+ (OFResourceDataMap*)getDataMap
{
	static OFPointer<OFResourceDataMap> dataMap;
	
	if(dataMap.get() == NULL)
	{
		dataMap = new OFResourceDataMap;
		dataMap->addField(@"name",					@selector(setName:));
		dataMap->addField(@"icon_url",				@selector(setIconUrl:));
		dataMap->addField(@"price",					@selector(setPrice:));
		dataMap->addField(@"itunes_id",				@selector(setItunesId:));
		dataMap->addField(@"current_version",		@selector(setCurrentVersion:));
		dataMap->addField(@"description_brief",		@selector(setBriefDescription:));
		dataMap->addField(@"description_extended",	@selector(setExtendedDescription:));
		dataMap->addField(@"client_application_id",	@selector(setApplicationId:));
	}
	
	return dataMap.get();
}

+ (NSString*)getResourceName
{
	return @"application_description";
}

+ (NSString*)getResourceDiscoveredNotification
{
	return nil;
}

- (void) dealloc
{
	OFSafeRelease(name);
	OFSafeRelease(iconUrl);
	OFSafeRelease(itunesId);
	OFSafeRelease(price);
	OFSafeRelease(currentVersion);
	OFSafeRelease(briefDescription);
	OFSafeRelease(extendedDescription);
	[super dealloc];
}

@end