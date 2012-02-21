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

#pragma once

@class OFXmlDocument;
@class OFPaginatedSeries;
class OFXmlElement;
class OFResourceNameMap;
class OFResourceDataMap;

@interface OFResource : NSObject 
{
@package
	NSString* resourceId;
}

- (id)initWithId:(NSString*)_resourceId;

+ (OFPaginatedSeries*)resourcesFromXml:(OFXmlDocument*)data withMap:(OFResourceNameMap*)resourceNameMap;
+ (NSString*)resourcesToXml:(NSArray*)resources;
- (NSString*)toResourceArrayXml;
- (void)populateFromXml:(OFXmlElement*)root withMap:(OFResourceNameMap*)resourceNameMap;

@property (nonatomic, readonly, assign) NSString* resourceId;

@end
