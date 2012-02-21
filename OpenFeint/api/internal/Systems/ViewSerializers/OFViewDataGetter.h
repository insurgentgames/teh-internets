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

class OFOutputSerializer;
class OFViewDataMap;

class OFViewDataGetter
{
public:
	OFViewDataGetter(UIView* rootView, OFViewDataMap* viewData);
	~OFViewDataGetter();

	void serialize(OFOutputSerializer* stream) const;
	
private:
	void serializeView(UIView* namedView, NSString* name, OFOutputSerializer* stream) const;

	typedef void (OFViewDataGetter::*UIViewValueGetter)(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;
	
	struct UITypeAndGetter
	{
		Class uiClassType;
		UIViewValueGetter getter;
	};

#if defined(_UNITTEST)
	static const unsigned int sNumGetters = 5;
#else
	static const unsigned int sNumGetters = 4;
#endif

	static const UITypeAndGetter sAvailableGetters[sNumGetters];

	void writeValueUILabel(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;
	void writeValueUITextField(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;
	void writeValueUITextView(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;

	void writeValueUISwitch(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;
#if defined(_UNITTEST)
	void writeValueUIMockLabel(UIView* targetView, NSString* name, OFOutputSerializer* stream) const;
#endif
	
	OFRetainedPtr<UIView> mRootView;
	OFPointer<OFViewDataMap> mViewData;
};