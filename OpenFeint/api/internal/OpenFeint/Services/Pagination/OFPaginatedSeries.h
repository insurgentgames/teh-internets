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
@class OFPaginatedSeriesHeader;

@interface OFPaginatedSeries : NSObject<NSFastEnumeration>
{
	NSMutableArray* tableMetaDataObjects;
	NSMutableArray* objects;
	OFPaginatedSeriesHeader* header;
	NSInteger httpResponseStatusCode;
}

@property (retain, nonatomic) NSMutableArray* tableMetaDataObjects;
@property (retain, nonatomic) NSMutableArray* objects;
@property (retain, nonatomic) OFPaginatedSeriesHeader* header;
@property (assign, nonatomic) NSInteger httpResponseStatusCode;

+ (OFPaginatedSeries*)paginatedSeries;
+ (OFPaginatedSeries*)paginatedSeriesWithObject:(id)objectToAdd;
+ (OFPaginatedSeries*)paginatedSeriesFromArray:(NSArray*)array;
+ (OFPaginatedSeries*)paginatedSeriesFromSeries:(OFPaginatedSeries*)seriesToCopy;

- (void)prependObject:(id)objectToPrepend;
- (void)addObject:(id)objectToAdd;
- (unsigned int)count;
- (id)objectAtIndex:(unsigned int)index;

@end
