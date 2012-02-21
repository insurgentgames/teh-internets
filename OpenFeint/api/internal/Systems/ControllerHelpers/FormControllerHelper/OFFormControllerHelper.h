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

#include "OFDelegate.h"
#include "OFPointer.h"
#import "OFViewController.h"

typedef std::map<int, OFDelegate> TagActionMap;
class OFViewDataMap;
class OFHttpService;

@interface OFFormControllerHelper : OFViewController<OFCallbackable, UITextFieldDelegate, UITextViewDelegate>
{
@package
	TagActionMap mTagActions;
	UIScrollView* mScrollContainerView;
	UIView* mActiveTextField;	
	OFPointer<OFViewDataMap> mViewDataMap;
	OFPointer<OFHttpService> mHttpService;
	bool mIsKeyboardShown;
	float mViewHeightWithoutKeyboard;
	BOOL mIsSubmitting;
}

- (void)registerAction:(OFDelegate)action forTag:(int)tag;
- (IBAction)onTriggerAction:(UIView*)sender;
- (IBAction)onTriggerBarAction:(UIBarButtonItem*)sender;

@end
