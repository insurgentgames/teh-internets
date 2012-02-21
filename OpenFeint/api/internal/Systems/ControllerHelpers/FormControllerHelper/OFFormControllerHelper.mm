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
#import "OFFormControllerHelper.h"
#import "OFViewHelper.h"
#import "OFViewDataMap.h"
#import "OFHttpService.h"
#import "OFFormControllerHelper+Overridables.h"
#import "OFProvider.h"
#import "OFViewHelper.h"
#import "OFFormControllerHelper+Submit.h"
#import "OpenFeint+Private.h"

@implementation OFFormControllerHelper

/////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{	
	mHttpService = [OFProvider createHttpService];
	
	mTagActions.clear();
	[self registerActionsNow];
	
	mViewDataMap = new OFViewDataMap;
	[self populateViewDataMap:mViewDataMap.get()];
	
	OFViewHelper::setAsDelegateForAllTextFields((id)self, self.view);
	OFViewHelper::setReturnKeyForAllTextFields(UIReturnKeySend, self.view);	
	
	mScrollContainerView = [OFViewHelper::findFirstScrollView(self.view) retain];
	
	CGSize contentSize = OFViewHelper::sizeThatFitsTight(mScrollContainerView);
	contentSize.height += 20.f;
	mScrollContainerView.contentSize = contentSize;
}

- (void)viewDidAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_KeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	mHttpService->cancelAllRequests();
	OFViewHelper::resignFirstResponder(self.view);
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self hideLoadingScreen];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];	
}

- (bool)canReceiveCallbacksNow
{
	return [self navigationController] != nil;
}

- (void)dealloc
{
	[mScrollContainerView release]; mScrollContainerView = NULL;
	[super dealloc];
}


- (IBAction)onTriggerAction:(UIView*)sender
{
	TagActionMap::const_iterator sit = mTagActions.find(sender.tag);
	if(sit == mTagActions.end())
	{
		OFAssert(0, "Attempting to trigger action for tag %d. No action has been registered.", sender.tag); 
		return;
	}
	
	sit->second.invoke();
}
- (IBAction)onTriggerBarAction:(UIBarButtonItem*)sender
{
	[self onTriggerAction:(UIView*)sender]; //UIBarButtonItem isn't a UIView, but we're pretending it is for triggering actions
}

- (void)registerAction:(OFDelegate)action forTag:(int)tag
{
	mTagActions.insert(TagActionMap::value_type(tag, action));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == [OpenFeint getDashboardOrientation];
}

@end
