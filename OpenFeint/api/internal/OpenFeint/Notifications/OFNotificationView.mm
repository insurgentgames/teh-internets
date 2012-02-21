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
#import "OFNotificationView.h"
#import "OFDelegate.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFDelegateChained.h"
#import "OpenFeint+Private.h"
#import "OFNotificationInputResponse.h"
#import "OFControllerLoader.h"
#import "OFImageLoader.h"
#import <QuartzCore/QuartzCore.h>

static const float gNotificationWaitSeconds = 2.f; 

@interface OFNotificationView()

- (void)_calcFrameAndTransform;
- (CGPoint)_calcOffScreenPosition:(CGPoint)onScreenPosition;

@end

@implementation OFNotificationView

@synthesize notice;
@synthesize statusIndicator;
@synthesize backgroundImage;
@synthesize disclosureIndicator;

- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
{
	if (mPresenting)
	{
		mPresenting = NO;
		[self performSelector:@selector(_dismiss) withObject:nil afterDelay:mNotificationDuration];
	}
	else
	{
		[[self layer] removeAnimationForKey:[theAnimation keyPath]];
		[self removeFromSuperview];
	}
}

- (void)_animateKeypath:(NSString*)keyPath 
			  fromValue:(float)startValue 
				toValue:(float)endValue 
			   overTime:(float)duration
	  animationDelegate:(UIView*)animDelegate
	 removeOnCompletion:(BOOL)removeOnCompletion
			   fillMode:(NSString*)fillMode
{
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:keyPath];
	animation.fromValue = [NSNumber numberWithFloat:startValue];
	animation.toValue = [NSNumber numberWithFloat:endValue];
	animation.duration = duration;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.delegate = animDelegate;
	animation.removedOnCompletion = removeOnCompletion;
	animation.fillMode = fillMode;
	[[self layer] addAnimation:animation forKey:keyPath];
}

- (void)_animateFromPosition:(CGPoint)startPos 
				  toPosition:(CGPoint)endPos 
					overTime:(float)duration
		   animationDelegate:(UIView*)animDelegate
		  removeOnCompletion:(BOOL)removeOnCompletion
					fillMode:(NSString*)fillMode

{
	if (startPos.x != endPos.x)
	{
		[self _animateKeypath:@"position.x" 
					fromValue:startPos.x 
					  toValue:endPos.x
					 overTime:duration 
			animationDelegate:animDelegate 
		   removeOnCompletion:removeOnCompletion 
					 fillMode:fillMode];
	}
	if (startPos.y != endPos.y)
	{
		[self _animateKeypath:@"position.y" 
					fromValue:startPos.y
					  toValue:endPos.y 
					 overTime:duration 
			animationDelegate:animDelegate 
		   removeOnCompletion:removeOnCompletion 
					 fillMode:fillMode];
	}
}

- (void)_dismiss
{
	CGPoint onScreenPosition = self.layer.position;
	[self _animateFromPosition:onScreenPosition
					toPosition:[self _calcOffScreenPosition:onScreenPosition]
					  overTime:0.5f
			 animationDelegate:self
			removeOnCompletion:NO
					  fillMode:kCAFillModeForwards];
}

- (void)_presentForDuration:(float)duration
{
	mPresenting = YES;
	mNotificationDuration = duration;
	
	CGPoint onScreenPosition = self.layer.position;
	[self _animateFromPosition:[self _calcOffScreenPosition:onScreenPosition]
					toPosition:onScreenPosition
					  overTime:0.25f
			 animationDelegate:self
			removeOnCompletion:YES
					  fillMode:kCAFillModeRemoved];

	[presentationView addSubview:self];
	OFSafeRelease(presentationView);
}

- (void)_makeStatusIconActiveAndDismiss:(OFNotificationStatus*)status
{
	[self _presentForDuration:gNotificationWaitSeconds];

	if (status == nil)
	{
		statusIndicator.hidden = YES;

		CGRect noticeFrame = notice.frame;
		noticeFrame.origin.x -= statusIndicator.frame.size.width;
		noticeFrame.size.width += statusIndicator.frame.size.width;
		notice.frame = noticeFrame;
	}
	else
	{	
		statusIndicator.image = [OFImageLoader loadImage:status];
		statusIndicator.hidden = NO;
	}
}

- (void)_requestSucceeded:(MPOAuthAPIRequestLoader*)request nextCall:(OFDelegateChained*)nextCall
{
	[self _makeStatusIconActiveAndDismiss:OFNotificationStatusSuccess];					
	[nextCall invokeWith:request];
}

- (void)_requestFailed:(MPOAuthAPIRequestLoader*)request nextCall:(OFDelegateChained*)nextCall
{
	[self _makeStatusIconActiveAndDismiss:OFNotificationStatusFailure];
	[nextCall invokeWith:request];
}

+ (NSString*)notificationViewName
{
	return @"NotificationView";
}

+ (void)showNotificationWithText:(NSString*)noticeText andStatus:(OFNotificationStatus*)status inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFNotificationView* view = (OFNotificationView*)OFControllerLoader::loadView([self notificationViewName]);

	// ensuring thread-safety by firing the notice on the main thread
	SEL selector = @selector(configureWithText:andStatus:inView:withInputResponse:);
	NSMethodSignature* methodSig = [view methodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSig];
	[invocation setTarget:view];
	[invocation setSelector:selector];
	[invocation setArgument:&noticeText atIndex:2];
	[invocation setArgument:&status atIndex:3];
	[invocation setArgument:&containerView atIndex:4];
	[invocation setArgument:&inputResponse atIndex:5];
	[[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.f invocation:invocation repeats:NO] forMode:NSDefaultRunLoopMode];
}

+ (void)showNotificationWithRequest:(MPOAuthAPIRequestLoader*)request andNotice:(NSString*)noticeText inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFNotificationView* view = (OFNotificationView*)OFControllerLoader::loadView([self notificationViewName]);

	// ensuring thread-safety by firing the notice on the main thread
	SEL selector = @selector(configureWithRequest:andNotice:inView:withInputResponse:);
	NSMethodSignature* methodSig = [view methodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSig];
	[invocation setTarget:view];
	[invocation setSelector:selector];
	[invocation setArgument:&request atIndex:2];
	[invocation setArgument:&noticeText atIndex:3];
	[invocation setArgument:&containerView atIndex:4];
	[invocation setArgument:&inputResponse atIndex:5];
	[[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.f invocation:invocation repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (BOOL)isParentViewRotatedInternally:(UIView*)parentView
{
	CGRect parentBounds = parentView.bounds;
	bool parentIsLandscape = parentBounds.size.width > ([UIScreen mainScreen].bounds.size.height + [UIScreen mainScreen].bounds.size.width) * 0.5f;
	bool dashboardIsLandscape = [OpenFeint isInLandscapeMode];
	return dashboardIsLandscape && !parentIsLandscape;
}

- (CGPoint)_calcOffScreenPosition:(CGPoint)onScreenPosition
{
	CGSize notificationSize = self.bounds.size;
	if (mParentViewIsRotatedInternally)
	{
		UIInterfaceOrientation dashboardOrientation = [OpenFeint getDashboardOrientation];
		float offScreenOffsetX = 0.f;
		float offScreenOffsetY = 0.f;
		
		switch (dashboardOrientation)
		{
			case UIInterfaceOrientationLandscapeRight:		offScreenOffsetX = -notificationSize.height;	break;
			case UIInterfaceOrientationLandscapeLeft:		offScreenOffsetX = notificationSize.height;		break;
			case UIInterfaceOrientationPortraitUpsideDown:	offScreenOffsetY = -notificationSize.height;	break;
			case UIInterfaceOrientationPortrait:			offScreenOffsetY = notificationSize.height;		break;
		}
		
		if ([OpenFeint invertNotifications])
		{
			// We're off the other side, basically.
			offScreenOffsetX *= -1.0f;
			offScreenOffsetY *= -1.0f;
		}
		
		return CGPointMake(onScreenPosition.x + offScreenOffsetX, onScreenPosition.y + offScreenOffsetY);
	}
	else
	{
		if ([OpenFeint invertNotifications])
		{
			return CGPointMake(onScreenPosition.x, onScreenPosition.y - notificationSize.height);
		}
		else
		{
			return CGPointMake(onScreenPosition.x, onScreenPosition.y + notificationSize.height);
		}

	}
}

- (void)_calcFrameAndTransform
{
	OFAssert(presentationView != nil, "You must have called [self _setPresentationView:] before this!");
	
	CGRect parentBounds = presentationView.bounds;
	const float kNotificationHeight = self.frame.size.height;
	CGRect notificationRect = CGRectZero;
	
	// If we are doing inverted notifications, we may need to come in past the UIStatusBar.
	CGSize statusBarOffsetSize = CGSizeZero;
	if (![UIApplication sharedApplication].statusBarHidden) {
		statusBarOffsetSize = [UIApplication sharedApplication].statusBarFrame.size;
	}
	
	UIInterfaceOrientation dashboardOrientation = [OpenFeint getDashboardOrientation];
	mParentViewIsRotatedInternally = [self isParentViewRotatedInternally:presentationView];
	if (mParentViewIsRotatedInternally)
	{	
		CGSize notificationSize = CGSizeMake([OpenFeint isInLandscapeMode] ? parentBounds.size.height : parentBounds.size.width, kNotificationHeight);
		notificationRect = CGRectMake(
									  -notificationSize.width * 0.5f,
									  -notificationSize.height * 0.5f, 
									  notificationSize.width, 
									  notificationSize.height
									  );
		
		CGAffineTransform newTransform = CGAffineTransformIdentity;
		
		if ([OpenFeint invertNotifications])
		{
			switch (dashboardOrientation)
			{
				case UIInterfaceOrientationLandscapeRight:
					newTransform = CGAffineTransformMake(0, 1, -1, 0, 
														 parentBounds.size.width - notificationSize.height * 0.5f - statusBarOffsetSize.width,
														 parentBounds.size.height * 0.5f);
					
					break;
				case UIInterfaceOrientationLandscapeLeft:
					newTransform = CGAffineTransformMake(0, -1, 1, 0, 
														 notificationSize.height * 0.5f + statusBarOffsetSize.width,
														 parentBounds.size.height * 0.5f);
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					newTransform = CGAffineTransformMake(-1, 0, 0, -1, parentBounds.size.width * 0.5f, parentBounds.size.height - notificationSize.height * 0.5f - statusBarOffsetSize.height);
					break;
				default:
					newTransform = CGAffineTransformTranslate(newTransform, notificationSize.width * 0.5f, notificationSize.height * 0.5f + statusBarOffsetSize.height);
					break;
			}
		}
		else
		{
			switch (dashboardOrientation)
			{
				case UIInterfaceOrientationLandscapeRight:
					newTransform = CGAffineTransformMake(0, 1, -1, 0, 
														 notificationSize.height * 0.5f, 
														 parentBounds.size.height * 0.5f);
					
					break;
				case UIInterfaceOrientationLandscapeLeft:
					newTransform = CGAffineTransformMake(0, -1, 1, 0, 
														 parentBounds.size.width - notificationSize.height * 0.5f, 
														 parentBounds.size.height * 0.5f);
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					newTransform = CGAffineTransformMake(-1, 0, 0, -1, parentBounds.size.width * 0.5f, notificationSize.height * 0.5f);
					break;
				default:
					newTransform = CGAffineTransformTranslate(newTransform, notificationSize.width * 0.5f, parentBounds.size.height - notificationSize.height * 0.5f);
					break;
			}			
		}		
		
		self.frame = notificationRect;
		[self setTransform:newTransform];
	}
	else
	{
		if ([OpenFeint invertNotifications])
		{
			CGSize notificationSize = CGSizeMake(parentBounds.size.width, kNotificationHeight);
			notificationRect = CGRectMake(
										  (parentBounds.size.width - notificationSize.width) * 0.5f, 
										  statusBarOffsetSize.height, 
										  notificationSize.width, 
										  notificationSize.height
										  );
			self.frame = notificationRect;			
		}
		else
		{
			CGSize notificationSize = CGSizeMake(parentBounds.size.width, kNotificationHeight);
			notificationRect = CGRectMake(
										  (parentBounds.size.width - notificationSize.width) * 0.5f, 
										  parentBounds.size.height - notificationSize.height, 
										  notificationSize.width, 
										  notificationSize.height
										  );
			self.frame = notificationRect;			
		}
	}
}

- (void)_setPresentationView:(UIView*)_presentationView
{
	OFSafeRelease(presentationView);
	presentationView = [_presentationView retain];	
	[self _calcFrameAndTransform];
}

- (void)_buildViewWithText:(NSString*)noticeText
{
	statusIndicator.hidden = YES;
	notice.text = noticeText;
	[backgroundImage setContentMode:UIViewContentModeScaleToFill];
	[backgroundImage setImage:[backgroundImage.image stretchableImageWithLeftCapWidth:(backgroundImage.image.size.width - 18) topCapHeight:0]];
}

- (void)configureWithText:(NSString*)noticeText andStatus:(OFNotificationStatus*)status inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	mInputResponse = [inputResponse retain];
	[self _setPresentationView:containerView];
	[self _buildViewWithText:noticeText];
	[self _makeStatusIconActiveAndDismiss:status];
	
	disclosureIndicator.hidden = (inputResponse == nil);
}

- (void)configureWithRequest:(MPOAuthAPIRequestLoader*)request andNotice:(NSString*)noticeText inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	mInputResponse = [inputResponse retain];
	[self _setPresentationView:containerView];
	[self _buildViewWithText:noticeText];
	
	[request setOnSuccess:OFDelegate(self, @selector(_requestSucceeded:nextCall:), [request getOnSuccess])]; 
	[request setOnFailure:OFDelegate(self, @selector(_requestFailed:nextCall:), [request getOnFailure])]; 		
	[request loadSynchronously:NO];
	
	disclosureIndicator.hidden = (inputResponse == nil);
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* hitView = [super hitTest:point withEvent:event];
	if (hitView == self)
	{
		[mInputResponse respondToInput];
	}
	return hitView;
}

- (void)dealloc 
{
	self.statusIndicator = nil;
	self.backgroundImage = nil;
	self.disclosureIndicator = nil;
	self.notice = nil;
	OFSafeRelease(presentationView);
	OFSafeRelease(mInputResponse);
    [super dealloc];
}

@end
