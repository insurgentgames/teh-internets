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
#import "OFResourceNameMap.h"
#import <algorithm>

void OFResourceNameMap::addResource(NSString* name, Class klass)
{
	ResourceDescription desc;
	desc.klass = klass;
	desc.resourceName = name;
	mResources.push_back(desc);
}

Class OFResourceNameMap::getTypeNamed(NSString* name) const
{
	ResourceDescriptionSeries::const_iterator sit = std::find(mResources.begin(), mResources.end(), name);
	if(sit == mResources.end())
	{
		return nil;
	}
	
	return sit->klass;
}
