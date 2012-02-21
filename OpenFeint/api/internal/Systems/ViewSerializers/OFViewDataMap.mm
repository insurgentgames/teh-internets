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

#import "OFViewDataMap.h"
#import "OFXmlDocument.h"
#import "OFXmlElement.h"
#import "OFViewHelper.h"

void OFViewDataMap::addFieldReference(NSString* fieldName, NSInteger viewTag)
{
	FieldReference newField;
	newField.name = fieldName;
	newField.tag = viewTag;
	mFields.push_back(newField);
}

UIView* OFViewDataMap::findViewByTag(UIView* rootView, int tag) const
{
	return OFViewHelper::findViewByTag(rootView, tag);
}

UIView* OFViewDataMap::findViewByName(UIView* rootView, NSString* fieldName) const
{
	FieldReferenceSeries::const_iterator sit = std::find(mFields.begin(), mFields.end(), fieldName);
	if(sit == mFields.end())
	{
		return NULL;
	}
	
	return findViewByTag(rootView, sit->tag);
}

bool OFViewDataMap::isValidField(NSString* name) const
{
	return std::find(mFields.begin(), mFields.end(), name) != mFields.end();
}

unsigned int OFViewDataMap::getFieldCount() const
{
	return mFields.size();
}

OFPointer<OFViewDataMap> OFViewDataMap::fromXml(OFXmlDocument* xmlData)
{
	OFPointer<OFViewDataMap> viewMap = new OFViewDataMap;
	
	[xmlData pushNextScope:"fields"];
	while(OFPointer<OFXmlElement> nextField = [xmlData readNextElement])
	{			
		if(NSString* name = nextField->getAttributeNamed(@"name"))
		{
			if(NSString* tag = nextField->getAttributeNamed(@"tag"))
			{
				viewMap->addFieldReference(name, [tag intValue]);
			}
			else
			{
				OFAssert(0, "Missing tag attribute for view data map entry %@", name);
			}			
		}
		else
		{
			OFAssert(0, "Missing name attribute for view data map.");
		}
	}

	[xmlData popScope];
	return viewMap;
}

OFViewDataMap::FieldReferenceSeries::const_iterator OFViewDataMap::begin() const
{
	return mFields.begin();
}

OFViewDataMap::FieldReferenceSeries::const_iterator OFViewDataMap::end() const
{
	return mFields.end();
}
