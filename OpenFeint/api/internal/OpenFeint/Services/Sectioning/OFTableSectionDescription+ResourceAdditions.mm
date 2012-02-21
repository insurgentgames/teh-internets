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
#import "OFTableSectionDescription+ResourceAdditions.h"
#import "OFResource.h"

@implementation OFTableSectionDescription (ResourceAdditions)

- (NSMutableArray*)arrayWithoutDuplicates:(OFTableSectionDescription*)otherSection areSortedDescending:(BOOL)areSortedDescending
{
	NSMutableArray* adjustedResources = [NSMutableArray arrayWithCapacity:[otherSection.page count]];
	
	for(OFResource* newResource in otherSection.page.objects)
	{
		bool isDuplicate = false;
		
		const unsigned long long newResourceId = [newResource.resourceId longLongValue];
		if (newResourceId != 0)
		{
			for(OFResource* existingResource in self.page.objects)
			{
				const unsigned long long existingResourceId = [existingResource.resourceId longLongValue];
			
				if(areSortedDescending && newResourceId > existingResourceId)
				{
					break;
				}
				else if(newResourceId == existingResourceId)
				{
					isDuplicate = true;
					break;
				}
			}
		}
		
		if(isDuplicate)
		{
			break;
		}
		
		[adjustedResources addObject:newResource];
	}
	
	return adjustedResources;
}

- (unsigned int)addContentsOfSectionWhereUnique:(OFTableSectionDescription*)otherSection areSortedDescending:(BOOL)areSortedDescending shouldPrependContents:(BOOL)shouldPrependContents
{
	unsigned int numNewUniqueResources = 0;
	
	if(!self.page)
	{
		self.page = otherSection.page;
		numNewUniqueResources = [otherSection.page count];
	}
	else
	{
		NSMutableArray* adjustedResources = [self arrayWithoutDuplicates:otherSection areSortedDescending:areSortedDescending];
		numNewUniqueResources = [adjustedResources count];
		if(numNewUniqueResources)
		{
			if(shouldPrependContents)
			{
				[adjustedResources addObjectsFromArray:self.page.objects];
				self.page.objects = adjustedResources;
			}
			else
			{
				[self.page.objects addObjectsFromArray:adjustedResources];
			}			

			// citron note: This allows us to display data about this section with
			//				regards to the most recently added/loaded page.
			self.page.header = otherSection.page.header;
		}
	}
	
	return numNewUniqueResources;	
}

@end