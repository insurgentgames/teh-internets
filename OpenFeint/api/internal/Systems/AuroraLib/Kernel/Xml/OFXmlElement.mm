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

#include "OFXmlElement.h"

OFXmlElement::OFXmlElement(NSString* _name)
: mName(_name)
, mHasBeenRead(false) 
{
}

OFPointer<OFXmlElement> OFXmlElement::dequeueNextUnreadChild(const char* nameToFind)
{			
	return dequeueNextUnreadChild([NSString stringWithUTF8String:nameToFind]);
}

OFPointer<OFXmlElement> OFXmlElement::dequeueNextUnreadChild(NSString* nameToFind)
{
	const unsigned int numChildren = mChildren.size();
	for(unsigned int i = 0; i < numChildren; ++i)
	{
		OFXmlElement* child = mChildren.at(i).get();
		if(!child->mHasBeenRead && [child->mName.get() isEqualToString:nameToFind])
		{
			child->mHasBeenRead = true;
			return child;
		}
	}
	
	return NULL;		
}
		
OFPointer<OFXmlElement> OFXmlElement::dequeueNextUnreadChild()
{
	const unsigned int numChildren = mChildren.size();
	for(unsigned int i = 0; i < numChildren; ++i)
	{
		OFXmlElement* child = mChildren.at(i).get();
		if(!child->mHasBeenRead)
		{
			child->mHasBeenRead = true;
			return child;
		}
	}
	
	return NULL;		
}

OFPointer<OFXmlElement> OFXmlElement::getChildWithName(const char* name, bool getNextUnreadChild)
{
	NSString* nsName = [NSString stringWithUTF8String:name];
	return getChildWithName(nsName, getNextUnreadChild);
}

OFPointer<OFXmlElement> OFXmlElement::getChildWithName(NSString* name, bool getNextUnreadChild)
{
	const unsigned int numChildren = mChildren.size();
	for(unsigned int i = 0; i < numChildren; ++i)
	{
		OFXmlElement* child = mChildren.at(i).get();
		
		if([child->mName.get() isEqualToString:name])
		{
			if(!getNextUnreadChild || (getNextUnreadChild && !child->mHasBeenRead))
			{
				return child;
			}
		}
	}
	
	return NULL;
}

bool OFXmlElement::getValueWithName(const char* name, NSString*& outString, bool markChildAsRead)
{
	OFPointer<OFXmlElement> child = getChildWithName(name, markChildAsRead);
	if(child.get())
	{
		if(markChildAsRead)
		{
			child->mHasBeenRead = true;
		}
		
		outString = child->mValue.get();
		return true;
	}
	
	return false;
}