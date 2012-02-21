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

class OFViewHelper
{
public:
	static UIView* findSuperviewByClass(UIView* rootView, Class viewClass);

	static UIView* findViewByClass(UIView* rootView, Class viewClass);

	static UIView* findViewByTag(UIView* rootView, int targetTag);
	static void setAsDelegateForAllTextFields(id<UITextFieldDelegate> delegate, UIView* rootView);
	static void setReturnKeyForAllTextFields(UIReturnKeyType lastKey, UIView* rootView);
	
	static UIScrollView* findFirstScrollView(UIView* rootView);
	static bool resignFirstResponder(UIView* rootView);
	static void enableAllControls(UIView* rootView, bool isEnabled);
	static CGSize sizeThatFitsTight(UIView* rootView);
};
