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

#include "OFSmartObject.h"

class OFXmlElement : public OFSmartObject
{
public: 
	OFXmlElement(NSString* _name);

	bool getValueWithName(const char* name, NSString*& outString, bool markChildAsRead = false);
	OFPointer<OFXmlElement> getChildWithName(NSString* name, bool getNextUnreadChild = false);
	OFPointer<OFXmlElement> getChildWithName(const char* name, bool getNextUnreadChild = false);

	OFPointer<OFXmlElement> dequeueNextUnreadChild();
	OFPointer<OFXmlElement> dequeueNextUnreadChild(NSString* nameToFind);
	OFPointer<OFXmlElement> dequeueNextUnreadChild(const char* nameToFind);	
	
	void addChild(OFXmlElement* childNode)			{ mChildren.push_back(childNode); }
	OFXmlElement* getChildAt(unsigned int index) const{ return mChildren.at(index); }
	bool hasChildren() const						{ return !mChildren.empty(); }
	
	void setName(NSString* name)					{ mName = name; }
	NSString* getName() const						{ return mName; }
	
	void setAttributes(NSDictionary* attributes)	{ mAttributes = attributes; }
	NSString* getAttributeNamed(NSString* name)		{ return [mAttributes.get() valueForKey:name]; }
	
	void setValue(NSString* value)					{ mValue = value; }
	NSString* getValue() const						{ return mValue; } 
	bool hasNilValue() const						{ return mValue.get() == nil; }
	bool hasValue() const							{ return !hasNilValue(); }

private:	
	OFRetainedPtr<NSString> mValue;
	OFRetainedPtr<NSString> mName;
	std::vector<OFPointer<OFXmlElement> > mChildren;
	OFRetainedPtr<NSDictionary> mAttributes;
	bool mHasBeenRead;	
};