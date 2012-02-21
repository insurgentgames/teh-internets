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

#import "OFViewDataSetter.h"
#import "OFViewDataMap.h"
#if defined(_UNITTEST)
#import "UIMockLabel.h"
#endif
#import <objc/runtime.h>

const OFViewDataSetter::UITypeAndSetter OFViewDataSetter::sAvailableSetters[OFViewDataSetter::sNumSetters] = 
{
#if defined(_UNITTEST)
	{ [UIMockLabel class],			&OFViewDataSetter::setValueUIMockLabel		},
#endif
	{ [UILabel class],				&OFViewDataSetter::setValueUILabel			}	
};

OFViewDataSetter::OFViewDataSetter(UIView* targetView, OFViewDataMap* fieldMap)
: mTargetView(targetView)
, mFieldMap(fieldMap)
{
}

void OFViewDataSetter::setField(NSString* fieldName, NSString* value)
{
	UIView* targetView = mFieldMap->findViewByName(mTargetView.get(), fieldName);
	if(!targetView)
	{
		OFAssert(0, "View with name %fieldName not found in target views map", fieldName);
		return;
	}
	
	Class targetViewClass = [targetView class];
	UIViewValueSetter setter = NULL;
	for(unsigned int i = 0; i < sNumSetters; ++i)
	{
		if(sAvailableSetters[i].uiClassType == targetViewClass)
		{
			setter = sAvailableSetters[i].setter;
			break;
		}
	} 
	
	if(!setter)
	{
		OFAssert(0, "Attempting to set a value on an unsupported view class (%s)", class_getName(targetViewClass));
		return;
	}
	
	(this->*setter)(targetView, value);
}

void OFViewDataSetter::setValueUILabel(UIView* targetView, NSString* value) const
{
	UILabel* label = static_cast<UILabel*>(targetView);
	label.text = value;
}

#if defined(_UNITTEST)
void OFViewDataSetter::setValueUIMockLabel(UIView* targetView, NSString* value) const
{
	UIMockLabel* label = static_cast<UIMockLabel*>(targetView);
	label.text = value;
}
#endif

bool OFViewDataSetter::isValidField(NSString* fieldName) const
{
	return mFieldMap->isValidField(fieldName);
}
