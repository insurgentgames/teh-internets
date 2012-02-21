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

#include "OFHashedString.h"

namespace
{
	// http://www.cse.yorku.ca/~oz/hash.html
	unsigned int Sdbm(const char *cStr)
	{
		unsigned int hashVal = 0;
		if (cStr)
		{
			unsigned char c;
			while ((c = *cStr++) != 0)
			{
				hashVal = (hashVal<<6) + (hashVal<<16) - hashVal + c;
			}
		}
		return hashVal;
	}
}

const OFSdbmHashedString OFSdbmHashedString::sNullHash;

OFHashedString::OFHashedString(unsigned int OFHashedString, const char* str)
: mHashedString(OFHashedString)
{
}	

OFSdbmHashedString::OFSdbmHashedString(const char* str)
: OFHashedString(Sdbm(str), str)
{
}

OFSdbmHashedString::OFSdbmHashedString()
: OFHashedString(0, "")
{
}
	
bool OFSdbmHashedString::operator ==(const OFSdbmHashedString& rhv) const
{
	return mHashedString == rhv.mHashedString;
}

bool OFSdbmHashedString::operator <(const OFSdbmHashedString& rhv) const
{
	return mHashedString < rhv.mHashedString;
}

bool OFSdbmHashedString::operator !=(const OFSdbmHashedString& rhv) const
{
	return mHashedString != rhv.mHashedString;
}