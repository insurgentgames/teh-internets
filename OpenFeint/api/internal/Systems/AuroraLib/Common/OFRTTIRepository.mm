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

#include "OFRTTIRepository.h"
#include "OFRTTI.h"

// The serializer micro-architecture should be moved into Common
#include "OFISerializer.h"

OFRTTIRepository::OFRTTIRepository()
{
}

void OFRTTIRepository::RegisterType(OFRTTI* type)
{
	mTypeIds.insert(TypeIdMap::value_type(type->GetTypeId(), type));
}

void* OFRTTIRepository::DeserializeObject(OFISerializer* stream, const OFSdbmHashedString& typeId) const
{
	const OFRTTI* type = getType(typeId);
	if(type == NULL)
	{
		return NULL;
	}
	
	return type->DeserializeObject(stream);
}

const OFRTTI* OFRTTIRepository::getType(const char* name) const
{
	return getType(OFSdbmHashedString(name));
}

const OFRTTI* OFRTTIRepository::getType(const OFSdbmHashedString& typeId) const
{
	TypeIdMap::const_iterator sit = mTypeIds.find(typeId);
	if(sit == mTypeIds.end())
	{
		OFAssert(0, "This is probably an error in your code. Did you setup your hierarchy's RTTI properly?"); 
		return NULL;
	}
	
	return sit->second;
}