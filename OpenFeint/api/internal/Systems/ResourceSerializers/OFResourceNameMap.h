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

#import "OFRetainedPtr.h"
#import "OFSmartObject.h"

class OFResourceNameMap : public OFSmartObject
{
public:
	struct ResourceDescription
	{
		OFRetainedPtr<NSString> resourceName;
		Class klass;
		
		bool operator==(NSString* nameString) const
		{
			return [resourceName.get() isEqualToString:nameString];
		}
	};
	
	void addResource(NSString* name, Class klass);
	Class getTypeNamed(NSString* name) const;
	
private:
	typedef std::vector<ResourceDescription> ResourceDescriptionSeries;
	ResourceDescriptionSeries mResources;
};