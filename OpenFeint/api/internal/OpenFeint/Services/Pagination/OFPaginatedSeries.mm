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
#import "OFPaginatedSeries.h"
#import "OFPaginatedSeriesHeader.h"

@implementation OFPaginatedSeries

@dynamic objects;
@synthesize tableMetaDataObjects;
@synthesize header;
@synthesize httpResponseStatusCode;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)stackbufLength 
{
	unsigned int offset = state->state;
	unsigned int count = self.count;
	
	unsigned int index;
	for(index = 0; (index < stackbufLength) && (offset + index < count); index++) 
	{
		stackbuf[index] = [self objectAtIndex:offset + index];
	}
	
	state->state = offset + index;
	state->itemsPtr = stackbuf;
	state->mutationsPtr = (unsigned long*)self;
	
	return index;
}

- (NSMutableArray*)objects
{
	return objects;
}

- (void)setObjects:(NSMutableArray*)value
{
	self.header = nil;
	[objects release];
	objects = [value retain];
}

+ (OFPaginatedSeries*)paginatedSeries
{
	return [[[OFPaginatedSeries alloc] init] autorelease];
}

+ (OFPaginatedSeries*)paginatedSeriesWithObject:(id)object
{
	OFPaginatedSeries* page = [OFPaginatedSeries paginatedSeries];
	[page addObject:object];
	return page;
}

- (OFPaginatedSeries*) init
{
	self = [super init];
	if (self != nil)
	{
		self.header = nil;
		self.objects = [NSMutableArray arrayWithCapacity:8];
		self.tableMetaDataObjects = nil;
		httpResponseStatusCode = -1;
	}
	return self;	
}

- (void)prependObject:(id)objectToPrepend
{
    [self.objects insertObject:objectToPrepend atIndex:0];
}

- (void)addObject:(id)object
{
	[self.objects addObject:object];
}

- (void)dealloc
{
	self.header = nil;
	self.objects = nil;
	self.tableMetaDataObjects = nil;
	[super dealloc];
}

- (unsigned int)count
{
	return [self.objects count];
}

- (id)objectAtIndex:(unsigned int)index
{
	return [self.objects objectAtIndex:index];
}

+ (OFPaginatedSeries*)paginatedSeriesFromSeries:(OFPaginatedSeries*)seriesToCopy
{
	OFPaginatedSeries* copiedSeries = [OFPaginatedSeries paginatedSeries];

	copiedSeries.objects = [NSMutableArray arrayWithCapacity:[seriesToCopy.objects count]];
	[copiedSeries.objects addObjectsFromArray:seriesToCopy.objects];

	copiedSeries.header = [OFPaginatedSeriesHeader paginationHeaderClonedFrom:seriesToCopy.header];

	return copiedSeries;
}

+ (OFPaginatedSeries*)paginatedSeriesFromArray:(NSArray*)array
{
	OFPaginatedSeries* series = [OFPaginatedSeries paginatedSeries];
	[series.objects addObjectsFromArray:array];
	return series;
}

@end
