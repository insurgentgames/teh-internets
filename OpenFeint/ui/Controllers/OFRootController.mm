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
#import "OFRootController.h"
#import "OpenFeint+Private.h"

#import <QuartzCore/QuartzCore.h>

@implementation OFRootController

@synthesize contentController, transitionIn, transitionOut;

- (void)animationDidStop:(CAAnimation*)_animation finished:(BOOL)_finished
{
	if (contentController.view.hidden)
	{
		[contentController viewDidDisappear:YES];
		[contentController.view removeFromSuperview];
		contentController.view = nil;
		OFSafeRelease(contentController);
	}
	else
	{
		[contentController viewDidAppear:YES];
	}
	
	[OpenFeint animationDidStop:_animation finished:_finished];
}

- (void)showController:(UIViewController*)_controller
{
	OFSafeRelease(contentController);
	contentController = [_controller retain];
	[contentController viewWillAppear:YES];
	
	[containerView addSubview:contentController.view];

	CATransition* animation = [CATransition animation];
	animation.type = kCATransitionMoveIn;
	animation.subtype = transitionIn;
	animation.duration = 0.5f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[[contentController.view layer] addAnimation:animation forKey:nil];
}

- (void)hideController
{
	if (contentController == nil)
		return;
		
	[contentController viewWillDisappear:YES];

	CATransition* animation = [CATransition animation];
	animation.type = kCATransitionReveal;
	animation.subtype = transitionOut;
	animation.duration = 0.5f;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[[contentController.view layer] addAnimation:animation forKey:nil];

	contentController.view.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == [OpenFeint getDashboardOrientation];
}

- (void)dealloc
{
	OFSafeRelease(contentController);
	OFSafeRelease(containerView);

	self.transitionIn = nil;
	self.transitionOut = nil;

	[super dealloc];
}

@end