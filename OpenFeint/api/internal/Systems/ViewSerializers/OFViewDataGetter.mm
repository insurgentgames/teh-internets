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

#include "OFViewDataGetter.h"
#include "OFViewDataMap.h"
#include "OFOutputSerializer.h"
#if defined(_UNITTEST)
#include "UIMockLabel.h"
#endif
#include "OFViewHelper.h"
#include <objc/runtime.h>

const OFViewDataGetter::UITypeAndGetter OFViewDataGetter::sAvailableGetters[OFViewDataGetter::sNumGetters] = 
{
#if defined(_UNITTEST)
	{ [UIMockLabel class],			&OFViewDataGetter::writeValueUIMockLabel		},
#endif
	{ [UILabel class],				&OFViewDataGetter::writeValueUILabel			},
	{ [UITextField class],			&OFViewDataGetter::writeValueUITextField		},
	{ [UITextView class],			&OFViewDataGetter::writeValueUITextView		},

	{ [UISwitch class],				&OFViewDataGetter::writeValueUISwitch			}
};

OFViewDataGetter::OFViewDataGetter(UIView* rootView, OFViewDataMap* viewData)
: mRootView(rootView)
, mViewData(viewData)
{
}

OFViewDataGetter::~OFViewDataGetter()
{
}

void OFViewDataGetter::serialize(OFOutputSerializer* stream) const
{
	OFViewDataMap::FieldReferenceSeries::const_iterator it = mViewData->begin();
	OFViewDataMap::FieldReferenceSeries::const_iterator itEnd = mViewData->end();	
	for(; it != itEnd; ++it)
	{
		const OFViewDataMap::FieldReference& field = *it;
		UIView* namedView = OFViewHelper::findViewByTag(mRootView.get(), field.tag);
		serializeView(namedView, field.name, stream);
	}
}

void OFViewDataGetter::serializeView(UIView* namedView, NSString* name, OFOutputSerializer* stream) const
{
	Class targetViewClass = [namedView class];
	UIViewValueGetter getter = NULL;
	for(unsigned int i = 0; i < sNumGetters; ++i)
	{
		if(sAvailableGetters[i].uiClassType == targetViewClass)
		{
			getter = sAvailableGetters[i].getter;
			break;
		}
	} 
	
	if(!getter)
	{
		OFAssert(0, "Attempting to get a value on an unsupported view class (%s)", class_getName(targetViewClass));
		return;
	}
	
	(this->*getter)(namedView, name, stream);	
}

void OFViewDataGetter::writeValueUILabel(UIView* targetView, NSString* name, OFOutputSerializer* stream) const
{
	UILabel* label = (UILabel*)targetView;
	OFRetainedPtr<NSString> text = label.text;
	stream->io([name UTF8String], text);
}

void OFViewDataGetter::writeValueUITextField(UIView* targetView, NSString* name, OFOutputSerializer* stream) const
{
	UITextField* textField = (UITextField*)targetView;
	OFRetainedPtr<NSString> text = textField.text;
	stream->io([name UTF8String], text);	
}


void OFViewDataGetter::writeValueUITextView(UIView* targetView, NSString* name, OFOutputSerializer* stream) const
{
	UITextView* textView = (UITextView*)targetView;
	OFRetainedPtr<NSString> text = textView.text;
	stream->io([name UTF8String], text);	
}

void OFViewDataGetter::writeValueUISwitch(UIView* targetView, NSString* name, OFOutputSerializer* stream) const
{
	UISwitch* toggleSwitch = (UISwitch*)targetView;
	bool value = toggleSwitch.on;
	stream->io([name UTF8String], value);
}

#if defined(_UNITTEST)
void OFViewDataGetter::writeValueUIMockLabel(UIView* targetView, NSString* name, OFOutputSerializer* stream) const
{
	UIMockLabel* label = (UIMockLabel*)targetView;
	OFRetainedPtr<NSString> text = label.text;
	stream->io([name UTF8String], text);
}
#endif