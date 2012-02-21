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

#include "OFViewHelper.h"

UIView* OFViewHelper::findSuperviewByClass(UIView* rootView, Class viewClass)
{
	UIView* returnView = nil;
	UIView* view = rootView;

	while (view && !returnView)
	{
		if ([view isKindOfClass:viewClass])
			returnView = view;
		
		view = [view superview];
	}

	return returnView;
}

UIView* OFViewHelper::findViewByClass(UIView* rootView, Class viewClass)
{
	if ([rootView isKindOfClass:viewClass])
	{
		return rootView;
	}
	
	for (UIView* view in rootView.subviews)
	{
		UIView* viewOfType = findViewByClass(view, viewClass);
		if(viewOfType != nil)
		{
			return viewOfType;
		}
	}
	
	return nil;
}

bool OFViewHelper::resignFirstResponder(UIView* rootView)
{
	if([rootView isKindOfClass:[UIResponder class]])
	{
		UIResponder* responder = (UIResponder*)rootView;
		if([responder isFirstResponder])
		{
			[responder resignFirstResponder];
			return true;
		}
	}
	
	for(UIView* view in rootView.subviews)
	{
		if(resignFirstResponder(view))
		{
			return true;
		}
	}
	
	return false;
}

UIScrollView* OFViewHelper::findFirstScrollView(UIView* rootView)
{
	if([rootView isKindOfClass:[UIScrollView class]])
	{
		return (UIScrollView*)rootView;
	}
	
	for(UIView* view in rootView.subviews)
	{
		UIScrollView* targetView = findFirstScrollView(view);
		if(targetView != nil)
		{
			return targetView;
		}
	}
			
	return nil;
}

void OFViewHelper::setReturnKeyForAllTextFields(UIReturnKeyType lastKey, UIView* rootView)
{
	unsigned int i = 1;
	UITextField* textField = nil;
		
	while(true)
	{
		UIView* view = [rootView viewWithTag:i];
		++i;
				
		if(!view)
		{
			break;
		}
		
		if(![view isKindOfClass:[UITextField class]])
		{			
			textField = nil;
			continue;
		}
		
		textField = (UITextField*)view;
		textField.returnKeyType = UIReturnKeyNext;
	}
	
	if(textField)
	{
		textField.returnKeyType = lastKey;
	}
}

void OFViewHelper::setAsDelegateForAllTextFields(id<UITextFieldDelegate, UITextViewDelegate> delegate, UIView* rootView)
{
	for(UIView* view in rootView.subviews)
	{
		if([view isKindOfClass:[UITextField class]])
		{
			UITextField* textField = (UITextField*)view;

			if(textField.delegate == nil)
			{
				textField.delegate = delegate;
			}
		}
		else if ([view isKindOfClass:[UITextView class]])
		{
			UITextView* textView = (UITextView*)view;
			
			if (textView.delegate == nil)
			{
				textView.delegate = delegate;
			}
		}
		
		setAsDelegateForAllTextFields(delegate, view);
	}
}

CGSize OFViewHelper::sizeThatFitsTight(UIView* rootView)
{
	CGSize sizeThatFits = CGSizeZero;

	if (!rootView)
		return sizeThatFits;
	
	for(UIView* view in rootView.subviews)
	{
		float right = view.frame.origin.x + view.frame.size.width;
		float bottom = view.frame.origin.y + view.frame.size.height;
		if(right > sizeThatFits.width)
		{
			sizeThatFits.width = right;
		}
		
		if(bottom > sizeThatFits.height)
		{
			sizeThatFits.height = bottom;
		}		
	}
	
	return sizeThatFits;
}

UIView* OFViewHelper::findViewByTag(UIView* rootView, int targetTag)
{
	if(rootView.tag == targetTag)
	{
		return rootView;
	}

	for(UIView* view in rootView.subviews)
	{
		UIView* targetView = findViewByTag(view, targetTag);
		if(targetView != nil)
		{
			return targetView;
		}
	}
	
	return NULL;
}

void OFViewHelper::enableAllControls(UIView* rootView, bool isEnabled)
{
	if([rootView isKindOfClass:[UIControl class]])
	{
		UIControl* control = (UIControl*)rootView;
		control.enabled = isEnabled;
	}
	
	for(UIView* view in rootView.subviews)
	{
		enableAllControls(view, isEnabled);
	}
}
