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

#import "OFDependencies.h"
#import "OFFormControllerHelper+EditingSupport.h"
#import "OFFormControllerHelper+Submit.h"
#import "OFViewHelper.h"
#import "OFFormControllerHelper+Overridables.h"
#import "OpenFeint+Private.h"

@implementation OFFormControllerHelper ( EditingSupport )

- (void)_scrollToActiveTextField
{
	if (!mActiveTextField)
		return;
	
	CGRect rectToMakeVisible = mActiveTextField.frame;
	if ([mActiveTextField superview] != mScrollContainerView)
	{
		rectToMakeVisible.origin.x += [[mActiveTextField superview] frame].origin.x;
		rectToMakeVisible.origin.y += [[mActiveTextField superview] frame].origin.y;
	}
	[mScrollContainerView scrollRectToVisible:rectToMakeVisible animated:YES];
}

- (void)_KeyboardDidShow:(NSNotification*)notification
{
    if (mIsKeyboardShown)
	{
		return;
	}

	NSDictionary* info = [notification userInfo];

	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;

	// If this form is being presented in a modal, it might not belong to the OpenFeint
	// root controller.  So, we basically have to find the view that's just under the window
	// for screenspace coordinates that respect rotation.
	UIView* topLevelView = mScrollContainerView;

	while (topLevelView && ![topLevelView.superview isKindOfClass:[UIWindow class]])
	{
		topLevelView = topLevelView.superview;
	}

	if (topLevelView)
	{
		CGRect usableRect = CGRectMake(0, 0, topLevelView.bounds.size.width, topLevelView.bounds.size.height - keyboardSize.height);			
		
		CGRect viewFrame = [mScrollContainerView frame];
			
		CGPoint screenSpaceOrigin = [mScrollContainerView convertPoint:mScrollContainerView.contentOffset toView:topLevelView];
		mViewHeightWithoutKeyboard = viewFrame.size.height;
		float bottomOfView = topLevelView.bounds.size.height - keyboardSize.height;
		viewFrame.size.height = bottomOfView - screenSpaceOrigin.y;

		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3f];		
		mScrollContainerView.frame = viewFrame;
		[self _scrollToActiveTextField];
		[UIView commitAnimations];
	}

	mIsKeyboardShown = YES;
}

- (void)_KeyboardDidHide:(NSNotification*)notification
{
    if (!mIsKeyboardShown)
	{
		return;
	}

    CGRect viewFrame = [mScrollContainerView frame];
    viewFrame.size.height = mViewHeightWithoutKeyboard;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];		
    mScrollContainerView.frame = viewFrame;
	[UIView commitAnimations];
	
    mIsKeyboardShown = NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	mActiveTextField = textView;
	[self _scrollToActiveTextField];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if (mActiveTextField == textView)
		mActiveTextField = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	mActiveTextField = textField;
	[self _scrollToActiveTextField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (mActiveTextField == textField)
		mActiveTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	UIResponder* nextView = OFViewHelper::findViewByTag(self.view, textField.tag + 1);

	if(nextView != nil)
	{
		if([nextView isKindOfClass:[UITextField class]] || [nextView isKindOfClass:[UITextView class]])
		{
			[nextView becomeFirstResponder];
		}
		else
		{
			[textField resignFirstResponder];
		}
	}
	else
	{		
		[self onSubmitForm:textField];
	}
	
	return YES;
}

@end
