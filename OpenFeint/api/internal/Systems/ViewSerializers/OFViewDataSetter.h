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
class OFViewDataMap;

class OFViewDataSetter : public OFSmartObject
{
public:
	OFViewDataSetter(UIView* targetView, OFViewDataMap* fieldMap);
	
	void setField(NSString* fieldName, NSString* value);
	bool isValidField(NSString* fieldName) const;
	
private:
	typedef void (OFViewDataSetter::*UIViewValueSetter)(UIView* targetView, NSString* value) const;
	
	struct UITypeAndSetter
	{
		Class uiClassType;
		UIViewValueSetter setter;
	};

#if defined(_UNITTEST)
	static const unsigned int sNumSetters = 2;
#else
	static const unsigned int sNumSetters = 1;
#endif

	static const UITypeAndSetter sAvailableSetters[sNumSetters];

	void setValueUILabel(UIView* targetView, NSString* value) const;
#if defined(_UNITTEST)
	void setValueUIMockLabel(UIView* targetView, NSString* value) const;
#endif
	
	OFRetainedPtr<UIView> mTargetView;
	OFPointer<OFViewDataMap> mFieldMap;
};