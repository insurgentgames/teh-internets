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

#include "OFISerializerKey.h"
#include "OFHashedString.h"

class OFSdbmSerializerKey : public OFISerializerKey
{
public:
	explicit OFSdbmSerializerKey(const char* keyName) : value(keyName) {}
	explicit OFSdbmSerializerKey(const OFSdbmHashedString& hashedName) : value(hashedName) {}

	bool equals(const OFISerializerKey* rhv) const			{ return value == ((const OFSdbmSerializerKey*)rhv)->value; }
	bool lessthan(const OFISerializerKey* rhv) const		{ return value <	((const OFSdbmSerializerKey*)rhv)->value; }
	const char* getAsString() const							
	{
		if(!mLazyString.get()) 
		{
			mLazyString.reset([NSString stringWithFormat:@"%x", value.valueForSerialization()]);
		}
		
		return [mLazyString.get() UTF8String];
	}

	OFSdbmHashedString value;
	
private:
	mutable OFRetainedPtr<NSString> mLazyString;
};