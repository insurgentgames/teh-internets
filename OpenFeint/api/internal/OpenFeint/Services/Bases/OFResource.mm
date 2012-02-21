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
#import "OFResource.h"
#import <objc/runtime.h>
#import "OFXmlDocument.h"
#import "OFXmlElement.h"
#import "OFResourceNameMap.h"
#import "OFResourceDataMap.h"
#import "OFResource+Overridables.h"
#import "OFTableSectionDescription+ResourceAdditions.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFPaginatedSeries.h"
#import "OFXmlResourceWriter.h"

@implementation OFResource

@synthesize resourceId;

- (id)initWithId:(NSString*)_resourceId
{
	self = [super init];
	if (self != nil)
	{
		resourceId = [_resourceId retain];
	}
	
	return self;
}

+(OFResource*)buildIdentifiedResource:(OFPointer<OFXmlElement>)element resourceClass:(Class)resourceClass withMap:(OFResourceNameMap*)resourceNameMap
{
	OFResource* resourceInstance = [class_createInstance(resourceClass, 0) init];
	[resourceInstance autorelease];
	
	if(![resourceInstance isKindOfClass:[OFResource class]])
	{
		OFLog(@"'%s' does not inherit from '%s' and cannot be loaded as a resource.", class_getName(resourceClass), class_getName([OFResource class]));
		return nil;
	}
	
	[resourceInstance populateFromXml:element.get() withMap:resourceNameMap];
	return resourceInstance;
}

+ (OFResource*)parseResource:(OFPointer<OFXmlElement>)element withMap:(OFResourceNameMap*)resourceNameMap
{
	NSString* resourceTypeName = element->getName();
	
	Class resourceType = resourceNameMap->getTypeNamed(resourceTypeName);
	
	if(resourceType == nil)
	{
		OFLog(@"'%s' is attempting to read an unknown resource type: '%@'", class_getName([self class]), resourceTypeName);
		return nil;
	}
	
	OFResource* resourceInstance = [OFResource buildIdentifiedResource:element resourceClass:resourceType withMap:resourceNameMap];
	return resourceInstance;
}

+ (NSMutableArray*)parseNestedResourceArrayFromElement:(OFXmlElement*)rootElement withMap:(OFResourceNameMap*)resourceNameMap
{
	NSMutableArray* resources = [NSMutableArray arrayWithCapacity:10];
	
	while(OFPointer<OFXmlElement> element = rootElement->dequeueNextUnreadChild())
	{
		OFResource* resourceInstance = [OFResource parseResource:element withMap:resourceNameMap];
		if (resourceInstance)
		{
			[resources addObject:resourceInstance];
		}
	}
	
	return resources;
}

+ (NSMutableArray*)parseNestedResourceArrayFromDocument:(OFXmlDocument*)data withMap:(OFResourceNameMap*)resourceNameMap
{
	NSMutableArray* resources = [NSMutableArray arrayWithCapacity:1];
	
	while(OFPointer<OFXmlElement> element = [data readNextElement])
	{
		OFResource* resourceInstance = [OFResource parseResource:element withMap:resourceNameMap];
		if (resourceInstance)
		{
			[resources addObject:resourceInstance];
		}
	}
	
	return resources;
}

+ (OFPaginatedSeries*)pagintedSeriesFromXmlDocument:(OFXmlDocument*)data withMap:(OFResourceNameMap*)resourceNameMap
{
	OFPaginatedSeries* resourcePage = [OFPaginatedSeries paginatedSeries];
	
	[data pushNextScope:"resources"];
	while(OFPointer<OFXmlElement> element = [data readNextElement])
	{
		if ([element->getName() isEqualToString:@"table_meta_data"])
		{
			resourcePage.tableMetaDataObjects = [OFResource parseNestedResourceArrayFromElement:element withMap:resourceNameMap];
		}
		else if([element->getName() isEqualToString:[OFPaginatedSeriesHeader getElementName]])
		{
			resourcePage.header = [OFPaginatedSeriesHeader paginationHeaderWithXmlElement:element.get()];
		}
		else
		{
			OFResource* resourceInstance = [OFResource parseResource:element withMap:resourceNameMap];
			if (resourceInstance)
			{
				[resourcePage addObject:resourceInstance];
			}
		}
	}
	[data popScope];
	
	return resourcePage;
}

+ (OFTableSectionDescription*)parseSection:(OFXmlDocument*)data withMap:(OFResourceNameMap*)resourceNameMap
{
	OFTableSectionDescription* section = [[OFTableSectionDescription new] autorelease];
	NSString* sectionName = nil;
	[data nextValueAtCurrentScopeWithKey:"name" outValue:sectionName];
	section.title = sectionName;
	
	NSString* sectionIdentifier = nil;
	[data nextValueAtCurrentScopeWithKey:"identifier" outValue:sectionIdentifier];
	section.identifier = sectionIdentifier;
	
	section.page = [OFResource pagintedSeriesFromXmlDocument:data withMap:resourceNameMap];
	return section;
}

+ (OFPaginatedSeries*)resourcesFromXml:(OFXmlDocument*)data withMap:(OFResourceNameMap*)resourceNameMap
{
	if ([data pushNextUnreadScopeWithNameIfAvailable:"resource_sections"])
	{
		OFPaginatedSeries* sections = [OFPaginatedSeries paginatedSeries];
		if ([data pushNextUnreadScopeWithNameIfAvailable:"table_meta_data"])
		{
			sections.tableMetaDataObjects = [OFResource parseNestedResourceArrayFromDocument:data withMap:resourceNameMap];
			[data popScope];
		}
		
		while([data pushNextUnreadScopeWithNameIfAvailable:"resource_section"])
		{
			[sections addObject:[OFResource parseSection:data withMap:resourceNameMap]];
			[data popScope];
		}
		[data popScope];
		return sections;
	}
	else
	{
		return [OFResource pagintedSeriesFromXmlDocument:data withMap:resourceNameMap];
	}
}

+ (NSString*)resourcesToXml:(NSArray*)resources
{
	return [OFXmlResourceWriter xmlStringFromResources:resources];
}

- (NSString*)toResourceArrayXml
{
	return [OFXmlResourceWriter xmlStringFromResources:[NSArray arrayWithObject:self]];
}

- (void)populateFromXml:(OFXmlElement*)root withMap:(OFResourceNameMap*)resourceNameMap
{
	[self.resourceId release];
	root->getValueWithName("id", resourceId, true);
	[self.resourceId retain];
	
	OFResourceDataMap* myDataMap = [[self class] getDataMap];	
	while(OFPointer<OFXmlElement> child = root->dequeueNextUnreadChild())
	{
		const OFResourceDataMap::FieldDescription* fieldDesc = myDataMap->getFieldDescription(child->getName());
		if(fieldDesc == nil)
		{
			continue;
		}
		
		if (fieldDesc->isResourceArray)
		{
			NSMutableArray* resourceArray = [OFResource parseNestedResourceArrayFromElement:child.get() withMap:resourceNameMap];
			[self performSelector:fieldDesc->setter withObject:resourceArray];
		}
		else if (fieldDesc->resourceClass)
		{
			OFResource* nestedResource = [OFResource buildIdentifiedResource:child resourceClass:fieldDesc->resourceClass withMap:resourceNameMap];
			[self performSelector:fieldDesc->setter withObject:nestedResource];
		}
		else
		{
			[self performSelector:fieldDesc->setter withObject:child->getValue()];
		}
	}
}

- (void) dealloc
{
	[self.resourceId release];
	resourceId = nil;
	[super dealloc];
}

@end
