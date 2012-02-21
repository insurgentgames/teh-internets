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
#import "OFPaginatedSeriesHeader.h"
#import "OFXmlElement.h"

namespace 
{
	NSUInteger readValueAsInteger(const char* name, OFXmlElement* element)
	{
		OFPointer<OFXmlElement> elementToRead = element->dequeueNextUnreadChild(name);
		if (elementToRead)
		{
			return [elementToRead->getValue() integerValue];
		}
		return 0;
	}
}

@implementation OFPaginatedSeriesHeader

@synthesize currentOffset;
@synthesize currentPage;
@synthesize totalPages;
@synthesize perPage;
@synthesize totalObjects;

+ (NSString*)getElementName
{
	return @"pagination_header";
}

+ (OFPaginatedSeriesHeader*)paginationHeaderWithXmlElement:(OFXmlElement*)element
{
	return [[[OFPaginatedSeriesHeader alloc] initWithXmlElement:element] autorelease];
}

- (OFPaginatedSeriesHeader*)initWithPaginationSeriesHeader:(OFPaginatedSeriesHeader*)otherHeader
{
	self = [super init];
	if (self != nil)
	{
		currentOffset = otherHeader.currentOffset;
		currentPage = otherHeader.currentPage;
		totalPages = otherHeader.totalPages;
		perPage = otherHeader.perPage;
		totalObjects = otherHeader.totalObjects;		
	}
	return self;
	
}

- (OFPaginatedSeriesHeader*)initWithXmlElement:(OFXmlElement*)element
{
	self = [super init];
	if (self != nil)
	{
		currentOffset	= readValueAsInteger("current_offset", element);
		currentPage		= readValueAsInteger("current_page", element);
		totalPages		= readValueAsInteger("total_pages", element);
		perPage			= readValueAsInteger("per_page", element);
		totalObjects	= readValueAsInteger("total_entries", element);					
	}
	return self;
}


+ (OFPaginatedSeriesHeader*)paginationHeaderClonedFrom:(OFPaginatedSeriesHeader*)otherHeader
{
	if(otherHeader == nil)
	{
		return nil;
	}
	
	return [[[OFPaginatedSeriesHeader alloc] initWithPaginationSeriesHeader:otherHeader] autorelease];
}

- (bool)isLastPageLoaded
{
	return currentPage >= totalPages;
}

@end
