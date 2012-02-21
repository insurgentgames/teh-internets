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

#import "OFSmartObject.h"
#import "OFPointer.h"
#import <vector>

@class OFXmlDocument;
@protocol UITextFieldDelegate;

class OFViewDataMap : public OFSmartObject
{
public:
	struct FieldReference
	{
		OFRetainedPtr<NSString> name;
		NSInteger tag;
		SEL resourceGetter;
		
		bool operator==(NSString* nameString) const
		{
			return [nameString isEqualToString:name.get()];
		}
	};
	
	typedef std::vector<FieldReference> FieldReferenceSeries;
	
	static OFPointer<OFViewDataMap> fromXml(OFXmlDocument* xmlData);
	
	void addFieldReference(NSString* fieldName, NSInteger viewTag);
	
	UIView* findViewByName(UIView* rootView, NSString* fieldName) const;
	UIView* findViewByTag(UIView* rootView, int tag) const;
	
	FieldReferenceSeries::const_iterator begin() const;
	FieldReferenceSeries::const_iterator end() const;	
	
	bool isValidField(NSString* name) const;
	unsigned int getFieldCount() const;
		
private:
	FieldReferenceSeries mFields;
};
