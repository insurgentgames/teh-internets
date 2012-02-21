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

#import "OFDefaultTextField.h"
#import "OpenFeint+Private.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Delegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// jkw: When a text field is its own delegate it goes into an infinite loop somewhere in apple land. This is an ugly workaround.
@interface OFDefaultTextFieldDelegate : NSObject<UITextFieldDelegate>
{
	BOOL closeKeyboardOnReturn;
	BOOL manageScrollViewOnFocus;
	OFDefaultTextField* owner;
	float mViewHeightWithoutKeyboard;
	BOOL mIsKeyboardShown;
}

@property (nonatomic, assign) BOOL closeKeyboardOnReturn;
@property (nonatomic, assign) BOOL manageScrollViewOnFocus;
@property (nonatomic, assign) OFDefaultTextField* owner;

@end

@implementation OFDefaultTextFieldDelegate

@synthesize closeKeyboardOnReturn, manageScrollViewOnFocus, owner;

- (id)init
{
	self = [super init];
	if (self)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];	
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[super dealloc];
}

- (UIScrollView*)getScrollView
{
	const int kMaxIterations = 2;
	UIView* curView = owner.superview;
	for (int i = 0; i < kMaxIterations; i++) 
	{
		if ([curView isKindOfClass:[UIScrollView class]])
		{
			return (UIScrollView*)curView;
		}
		curView = curView.superview;
	}
	return nil;
}

- (void)_KeyboardDidShow:(NSNotification*)notification
{
    if (mIsKeyboardShown)
	{
		return;
	}
	else
	{
		UIScrollView* scrollView = [self getScrollView];
		if (manageScrollViewOnFocus && scrollView)
		{
			NSDictionary* info = [notification userInfo];
			
			NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
			CGSize keyboardSize = [aValue CGRectValue].size;
			
			CGRect viewFrame = [scrollView frame];
			CGPoint screenSpaceOrigin = [scrollView convertPoint:viewFrame.origin toView:[OpenFeint getTopLevelView]];
			mViewHeightWithoutKeyboard = viewFrame.size.height;
			float bottomOfView = [OpenFeint getDashboardBounds].size.height - keyboardSize.height;
			viewFrame.size.height = bottomOfView - screenSpaceOrigin.y;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3f];		
			scrollView.frame = viewFrame;
			[UIView commitAnimations];
			
			CGRect rectToMakeVisible = owner.frame;
			if (owner.superview != scrollView)
			{
				rectToMakeVisible.origin.x += owner.superview.frame.origin.x;
				rectToMakeVisible.origin.y += owner.superview.frame.origin.y;
			}
			[scrollView scrollRectToVisible:rectToMakeVisible animated:YES];
		}
	}
	mIsKeyboardShown = YES;
}

- (void)_KeyboardDidHide:(NSNotification*)notification
{
	if (!mIsKeyboardShown)
	{
		return;
	}
	
	UIScrollView* scrollView = [self getScrollView];
	if (manageScrollViewOnFocus && scrollView)
	{
		CGRect viewFrame = [scrollView frame];
		viewFrame.size.height = mViewHeightWithoutKeyboard;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3f];		
		scrollView.frame = viewFrame;
		[UIView commitAnimations];
	}
	mIsKeyboardShown = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (manageScrollViewOnFocus)
	{
		UIScrollView* scrollView = [self getScrollView];
		if (scrollView)
		{
			CGRect rectToMakeVisible = owner.frame;
			if (textField.superview != scrollView)
			{
				rectToMakeVisible.origin.x += owner.superview.frame.origin.x;
				rectToMakeVisible.origin.y += owner.superview.frame.origin.y;
			}
			[scrollView scrollRectToVisible:rectToMakeVisible animated:YES];
		}
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (closeKeyboardOnReturn)
	{
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Text Field
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation OFDefaultTextField

- (void)createIntermediateDelegate
{
	if (!intermediateDelegate)
	{
		intermediateDelegate = [OFDefaultTextFieldDelegate new];
		intermediateDelegate.owner = self;
		self.delegate = intermediateDelegate;
	}
}

- (void)setDelegateDependantAttribute:(SEL)setter value:(BOOL)_value
{	
	if (_value)
	{
		[self createIntermediateDelegate];
	}
	[intermediateDelegate performSelector:setter withObject:(id)_value];
}

- (void)setCloseKeyboardOnReturn:(BOOL)_value
{
	[self setDelegateDependantAttribute:@selector(setCloseKeyboardOnReturn:) value:_value];
}

- (BOOL)closeKeyboardOnReturn
{
	return intermediateDelegate.closeKeyboardOnReturn;
}

- (void)setManageScrollViewOnFocus:(BOOL)_value
{
	[self setDelegateDependantAttribute:@selector(setManageScrollViewOnFocus:) value:_value];
}

- (BOOL)manageScrollViewOnFocus
{
	return intermediateDelegate.manageScrollViewOnFocus;
}

- (void)_commonInit
{
	
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[self _commonInit];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self _commonInit];
	}
	
	return self;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self _commonInit];
	}
	return self;
}

- (void)dealloc
{
	OFSafeRelease(intermediateDelegate);
	[super dealloc];
}

@end