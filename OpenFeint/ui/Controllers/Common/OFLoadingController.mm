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
#import "OFLoadingController.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OpenFeint+Private.h"
#import "OFPatternedGradientView.h"

@interface OFLoadingView (Internal)
- (void)_appearTransitionDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)_disappearTransitionDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
- (void)playAppearTransition:(BOOL)animated;
- (void)playDisappearTransition:(OFDelegate const)didDisappearDelegate;
@end

@implementation OFLoadingView

@synthesize contentContainer, backgroundView, centerImage, leftView, rightView;

- (void)dealloc
{
	self.contentContainer = nil;
	self.backgroundView = nil;
	self.centerImage = nil;
	self.leftView = nil;
	self.rightView = nil;
	[super dealloc];
}

- (void)setFrame:(CGRect)_frame
{
	[super setFrame:_frame];

	CGSize edgeSize = leftView.patternImage.size;

	float leftWidth = centerImage.frame.origin.x;
	float rightWidth = self.frame.size.width - CGRectGetMaxX(centerImage.frame);
	
	leftWidth = ceilf(leftWidth / edgeSize.width) * edgeSize.width;
	rightWidth = ceilf(rightWidth / edgeSize.width) * edgeSize.width;
	
	float leftOriginX = centerImage.frame.origin.x - leftWidth;

	leftView.frame = CGRectMake(leftOriginX, 0.f, leftWidth, edgeSize.height);
	rightView.frame = CGRectMake(CGRectGetMaxX(centerImage.frame), 0.f, rightWidth, edgeSize.height);
}

- (void)playAppearTransition:(BOOL)animated
{
	if (appearingAnimationInProgress)
		return;
		
	float midX = CGRectGetMidX(self.superview.frame) - self.superview.frame.origin.x;

	if(animated)
	{
		contentContainer.frame = CGRectMake(midX - contentContainer.frame.size.width * 0.5f, 
											self.superview.frame.size.height,
											contentContainer.frame.size.width,
											contentContainer.frame.size.height);

		backgroundView.alpha = 0.0f;

		appearingAnimationInProgress = YES;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(_appearTransitionDidStop:finished:context:)];		
	}
	
	contentContainer.frame = CGRectMake(midX - contentContainer.frame.size.width * 0.5f, 
										self.superview.frame.size.height - contentContainer.frame.size.height,
										contentContainer.frame.size.width,
										contentContainer.frame.size.height);
	backgroundView.alpha = 0.75f;

	if(animated)
	{
		[UIView commitAnimations];
	}
}

- (void)playDisappearTransition:(OFDelegate const)didDisappearDelegate
{
	if (disappearingAnimationInProgress || disappearIsQueued)
	{
		return;
	}
		
	disappearDelegate = didDisappearDelegate;

	if (appearingAnimationInProgress)
	{
		disappearIsQueued = YES;
		return;
	}
		
	float midX = CGRectGetMidX(self.superview.frame) - self.superview.frame.origin.x - (self.frame.origin.x * 0.5f);

	backgroundView.alpha = 0.75f;
	contentContainer.frame = CGRectMake(midX - contentContainer.frame.size.width * 0.5f, 
										self.superview.frame.size.height - contentContainer.frame.size.height,
										contentContainer.frame.size.width,
										contentContainer.frame.size.height);

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(_disappearTransitionDidStop:finished:context:)];
	contentContainer.frame = CGRectMake(midX - contentContainer.frame.size.width * 0.5f, 
										self.superview.frame.size.height,
										contentContainer.frame.size.width,
										contentContainer.frame.size.height);

	backgroundView.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)_appearTransitionDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	appearingAnimationInProgress = NO;
	if (disappearIsQueued)
	{
		disappearIsQueued = NO;
		[self playDisappearTransition:disappearDelegate];
	}
}

- (void)_disappearTransitionDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	disappearingAnimationInProgress = NO;
	disappearDelegate.invoke(nil);
	disappearDelegate = OFDelegate();
	[self removeFromSuperview];	
}

@end


@implementation OFLoadingController

+ (OFLoadingController*)loadingControllerWithText:(NSString*)loadingText
{
	OFLoadingController* controller = (OFLoadingController*)OFControllerLoader::load(@"Loading");
	[controller setLoadingText:loadingText];
	[controller viewWillAppear:YES];
	return controller;
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)setLoadingText:(NSString*)loadingText
{
/*
	UILabel* submittingText = (UILabel*)OFViewHelper::findViewByTag(self.view, kNoticeTag);
	NSAssert(submittingText != nil, @"Missing UILabel view with tag kNoticeTag from SubmittingForm controller.");
	NSAssert([submittingText isKindOfClass:[UILabel class]], @"View with tag kNoticeTag is not of type UILabel in SubmittingForm controller.");
	
	submittingText.text = loadingText;

	[self.view setNeedsDisplay];
*/
}

- (void)showLoadingScreen:(BOOL)animated
{
	[(OFLoadingView*)self.view playAppearTransition:animated];
}

- (void)showLoadingScreen
{
	[(OFLoadingView*)self.view playAppearTransition:YES];
}

- (void)hide
{
	// adill: 2.x hack -- we're assuming that our only owning object will release their reference
	// to us after this, so just incase we're passing in a _noop delegate to retain the controller.
	// -- it seems that in 2.x when a controller is released / dealloc'd it's view is removedFromSuperview.
	[(OFLoadingView*)self.view playDisappearTransition:OFDelegate(self, @selector(_noop))];
}

- (void)_noop
{
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	OFLoadingView* loadingView = (OFLoadingView*)self.view;

	OFPatternedGradientView* leftView = [[[OFPatternedGradientView alloc] 
		initWithFrame:CGRectZero
		gradient:nil
		patternImage:@"OFLoadingScreenEdge.png"] autorelease];
	leftView.opaque = NO;
	[loadingView.contentContainer addSubview:leftView];
	loadingView.leftView = leftView;

	OFPatternedGradientView* rightView = [[[OFPatternedGradientView alloc] 
		initWithFrame:CGRectZero
		gradient:nil
		patternImage:@"OFLoadingScreenEdge.png"] autorelease];
	rightView.opaque = NO;
	[loadingView.contentContainer addSubview:rightView];
	loadingView.rightView = rightView;

	loadingView.frame = [OpenFeint getDashboardBounds];
}

@end