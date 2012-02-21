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
#import "OFTableControllerHelper+Overridables.h"
#import "OFTableSingleControllerHelper.h"
#import "OFTableSingleController+ViewDelegate.h"
#import "OFControllerLoader.h"
#import "OFTableCellHelper.h"
#import <objc/runtime.h>
#import "OFTableSectionDescription.h"
#import "OFTableSectionCellDescription.h"

@implementation OFTableSingleControllerHelper (ViewDelegate)

- (OFResource*) getResourceFromSection:(NSArray*)sectionCells atRow:(NSUInteger)row
{
	OFTableSectionCellDescription* cellDescription = (OFTableSectionCellDescription*)[sectionCells objectAtIndex:row];	
	return cellDescription.resource;
}

- (NSString*) getCellControllerNameFromSection:(NSArray*)sectionCells atRow:(NSUInteger)row
{
	OFTableSectionCellDescription* cellDescription = (OFTableSectionCellDescription*)[sectionCells objectAtIndex:row];	
	return cellDescription.controllerName;
}

@end