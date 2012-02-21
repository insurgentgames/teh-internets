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

#include "OFPointer.h"

OFImplementRootRTTI(OFSmartObject)

// OFSmartObject
OFSmartObject::OFSmartObject()
{
	m_iRefCount = 0;
}

// ~OFSmartObject
OFSmartObject::~OFSmartObject()
{
	m_iRefCount = 0;
}

void OFSmartObject::Release() const
{
	OFAssert(m_iRefCount > 0, "If this fails, there is a serious problem. This should never happen!");

	if (--m_iRefCount == 0)
	{
		delete this;
	}
}

// Release
void OFSmartObject::Release()
{
	OFAssert(m_iRefCount > 0, "If this fails, there is a serious problem. This should never happen!");

	if (--m_iRefCount == 0)
	{
		delete this;
	}
}