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
#import "OFResourceDataMap.h"
#import <algorithm>

void OFResourceDataMap::addField(NSString* name, SEL setter, SEL getter)
{
	FieldDescription desc;
	desc.setter = setter;
	desc.dataFieldName = name;
	desc.resourceClass = nil;
	desc.isResourceArray = false;
	desc.getter = getter;
	mFields.push_back(desc);
}

void OFResourceDataMap::addNestedResourceField(NSString* name, SEL setter, SEL getter, Class resourceClass)
{
	FieldDescription desc;
	desc.setter = setter;
	desc.dataFieldName = name;
	desc.resourceClass = resourceClass;
	desc.isResourceArray = false;
	desc.getter = getter;
	mFields.push_back(desc);
}

void OFResourceDataMap::addNestedResourceArrayField(NSString* name, SEL setter, SEL getter)
{
	FieldDescription desc;
	desc.setter = setter;
	desc.dataFieldName = name;
	desc.resourceClass = nil;
	desc.isResourceArray = true;
	desc.getter = getter;
	mFields.push_back(desc);
}

const OFResourceDataMap::FieldDescription* OFResourceDataMap::getFieldDescription(NSString* name) const
{
	FieldDescriptionSeries::const_iterator sit = std::find(mFields.begin(), mFields.end(), name);
	if(sit == mFields.end())
	{
		return nil;
	}
	return &(*sit);
}

