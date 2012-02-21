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
#import "OFFramedNavigationController.h"
#import "OFFramedNavigationControllerBehavior.h"
#import "OFProfileFrame.h"
#import "OFBannerProvider.h"
#import "OFControllerLoader.h"
#import "OFFramedContentWrapperView.h"
#import "OFContentFrameView.h"
#import "OFLoadingController.h"
#import "OFCustomBottomView.h"
#import "OFTableControllerHelper.h"
#import "OFUser.h"
#import "OFGameProfilePageInfo.h"
#import "OFPlayerBannerCell.h"

#import "IPhoneOSIntrospection.h"

#import "OpenFeint+NSNotification.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Private.h"

#import "OFBannerCell.h"
#import "OFTableCellHelper+Overridables.h"

static const float kfBannerOverlap = 9.f;

#pragma mark OFFramedControllerInfo Interface

@interface OFFramedControllerInfo : NSObject
{
	UIViewController* controller;
	OFBannerCell* banner;
	OFUser* user;
	OFUser* comparedToUser;
	OFGameProfilePageInfo* clientApplicationInfo;
}

@property (nonatomic, retain) OFUser* user;
@property (nonatomic, retain) OFUser* comparedToUser;
@property (nonatomic, retain) OFGameProfilePageInfo* clientApplicationInfo;
@property (nonatomic, readonly) UIViewController* controller;
@property (nonatomic, retain) OFBannerCell* banner;

+ (id)withController:(UIViewController*)_controller andClientApplicationInfo:(OFGameProfilePageInfo*)_clientApplicationInfo;

@end

#pragma mark OFFramedControllerInfo Implementation

@implementation OFFramedControllerInfo

@synthesize user, comparedToUser, clientApplicationInfo, controller, banner;

+ (id)withController:(UIViewController*)_controller andClientApplicationInfo:(OFGameProfilePageInfo*)_clientApplicationInfo
{
	OFFramedControllerInfo* info = [[[OFFramedControllerInfo alloc] init] autorelease];
	info->controller = [_controller retain];
	info.clientApplicationInfo = _clientApplicationInfo;
	return info;
}

- (void)dealloc
{
 	OFSafeRelease(controller);
	self.banner = nil;
	self.user = nil;
	self.comparedToUser = nil;
	self.clientApplicationInfo = nil;
	[super dealloc];
}

@end

#pragma mark OFFramedNavigationController Internal Interface

@interface OFFramedNavigationController (Internal)
- (void)_pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfUser:(OFUser*)userContext comparedToUser:(OFUser*)comparedToUser;
- (void)_changeUserTo:(OFUser*)user comparedWith:(OFUser*)comparedWithUser notifyController:(BOOL)notifyController;
- (void)_positionViewsForController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)_repositionViews;
- (void)_repositionContent;
- (UIEdgeInsets)_calculateInsetsFor:(UIViewController*)viewController;
- (void)_makeNavBarCoherent;
- (void)_postSlideOut:(UIViewController*)viewController;
- (void)_postSlideIn:(UIViewController*)viewController;
- (OFFramedNavigationControllerVisibilityFlags)_visibilityFlagsForController:(UIViewController*)viewController;
- (void)_decideViewsForController:(UIViewController*)viewController;
- (void)_userChanged:(NSNotification*)notification;
- (OFBannerCell*)loadBannerFromController:(UIViewController*)controller;
- (void)_currentBannerDidDisappear;
- (void)_currentBannerDidAppear;
- (OFBannerCell*)_getBannerCellForViewController:(UIViewController*)viewController;
- (OFBannerCell*)_getCurrentBannerCell;
- (OFBannerCell*)_getBannerCellForBannerView:(UIView*)theBannerView;
- (void)_genRectsWithBannerFrame:(CGRect&)bannerFrame frameFrame:(CGRect&)frameFrame navBarFrame:(CGRect&)navBarFrame bottomFrame:(CGRect&)bottomFrame visibilityFlags:(OFFramedNavigationControllerVisibilityFlags)visibilityFlags;
@end

#pragma mark OFFramedNavigationController Implementation

@implementation OFFramedNavigationController

@synthesize owningTabBarItem, bannerView;

- (OFBannerCell*)_getCurrentBannerCell
{
	return bannerView.bannerSubview; // @NUKE
}

- (OFBannerCell*)_getBannerCellForBannerView:(UIView*)theBannerView
{
	for(OFFramedControllerInfo* info in controllerInfos)
	{
		if (info.banner.contentView == theBannerView)
		{
			return info.banner;
		}
	}
	
	return nil;
}

- (OFBannerCell*)_getBannerCellForViewController:(UIViewController*)viewController
{
	for(OFFramedControllerInfo* info in controllerInfos)
	{
		if (info.controller == viewController) 
		{
			return info.banner;
		}
	}
	
	return nil;
}

- (void)_currentBannerDidDisappear
{
	[[self _getCurrentBannerCell] viewDidDisappear];
}

- (void)_currentBannerDidAppear
{
	[[self _getCurrentBannerCell] viewDidAppear];
}

- (OFBannerCell*)loadBannerFromController:(UIViewController*)controller
{
	OFBannerCell* bannerCell = nil;
	if ([controller conformsToProtocol:@protocol(OFBannerProvider)])
	{
		UIViewController<OFBannerProvider>* bannerFrame = (UIViewController<OFBannerProvider>*)controller;
		
		if([bannerFrame isBannerAvailableNow])
		{				
			NSString* bannerCellControllerName = [bannerFrame bannerCellControllerName];		
			
			UITableViewCell* hopefullyAnOFBannerCell = OFControllerLoader::loadCell(bannerCellControllerName, nil);
			if (hopefullyAnOFBannerCell)
			{
				if ([hopefullyAnOFBannerCell isKindOfClass:[OFBannerCell class]])
				{
					bannerCell = (OFBannerCell*)hopefullyAnOFBannerCell;
					bannerCell.bannerProvider = controller;
					OFResource* bannerResource = [bannerFrame getBannerResource];
					[bannerCell changeResource:bannerResource];
				}
				else
				{
					NSLog(@"An %s isn't an OFTableViewCell", object_getClassName(hopefullyAnOFBannerCell));
				}
			}
		}
	}	
	
	return bannerCell;
}

- (void)showLoadingIndicator
{
	[super showLoadingIndicator];
	
	[mLoadingController.view removeFromSuperview];
	[self.view insertSubview:mLoadingController.view belowSubview:frameView];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	if (self != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userChanged:) name:OFNSNotificationUserChanged object:nil];
	}
	
	return self;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userChanged:) name:OFNSNotificationUserChanged object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUserChanged object:nil];

	OFSafeRelease(controllerInfos);
	
	[bannerView removeFromSuperview];
	OFSafeRelease(bannerView);

	[frameView removeFromSuperview];
	OFSafeRelease(frameView);
	
	[customBottomView removeFromSuperview];
	OFSafeRelease(customBottomView);
	
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	controllerInfos = [[NSMutableArray arrayWithCapacity:16] retain];
	
	OFSafeRelease(frameView);
	frameView = [(OFContentFrameView*)OFControllerLoader::loadView(@"ContentFrame") retain];

	OFSafeRelease(bannerView);
	bannerView = [(OFBannerFrame*)OFControllerLoader::loadView(@"BannerFrame") retain];
	
	visibilityDoes.showBanner = NO;
	visibilityDoes.showBottomView = NO;
	visibilityDoes.showNavBar = YES;
	
	visibilityShould.showBanner = NO;
	visibilityShould.showBottomView = NO;
	visibilityShould.showNavBar = NO;

	[self _makeNavBarCoherent];
	[self _repositionViews];

	self.view.clipsToBounds = YES; // So they don't see the empty banner when the dash is sliding up
	[self.view addSubview:frameView];
	[self.view addSubview:bannerView];
	[self.view bringSubviewToFront:self.navigationBar];
}

// This is here only for external users.
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (animated)
	{
		[UIView beginAnimations:@"navBarAdjustment" context:nil];
		[UIView setAnimationDuration:0.22f];
	}
	
	viewControllerSpecificallyWantsTheNavBarHidden = hidden;
	[self _decideViewsForController:self.visibleViewController];
	[self _repositionViews];
	
	if (animated)
	{
		[UIView commitAnimations];
	}
}

- (OFGameProfilePageInfo*)currentGameContext
{
	OFFramedControllerInfo* fci = [controllerInfos lastObject];
	return fci.clientApplicationInfo;
}

- (void)changeGameContext:(OFGameProfilePageInfo*)_gameContext
{
	OFFramedControllerInfo* fci = [controllerInfos lastObject];
	fci.clientApplicationInfo = _gameContext;
}

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfUser:(OFUser*)user
{
	[self _pushViewController:controller animated:animated inContextOfUser:user comparedToUser:nil];
}

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfLocalUserComparedTo:(OFUser*)user
{
	[self _pushViewController:controller animated:animated inContextOfUser:[OpenFeint localUser] comparedToUser:user];
}

- (void)pushViewController:(UIViewController*)controller animated:(BOOL)animated
{
	OFUser* user = [self currentUser];
	if (!user)
	{
		user = [OpenFeint localUser];
	}

	[self _pushViewController:controller animated:animated inContextOfUser:user comparedToUser:[(OFFramedControllerInfo*)[controllerInfos lastObject] comparedToUser]];
}

- (void)_pushViewController:(UIViewController*)controller animated:(BOOL)animated inContextOfUser:(OFUser*)userContext comparedToUser:(OFUser*)comparedToUser
{
	[self.view bringSubviewToFront:self.navigationBar];
	
	if (![controller.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		UIView* contentView = controller.view;
		OFFramedContentWrapperView* wrapperView = [[[OFFramedContentWrapperView alloc] initWithWrappedView:contentView] autorelease];
		[controller setView:wrapperView];
		
		// being the delegate for wrapperview is expensive,
		// but it ensures correct operation on 2.X.
		if (is2PointOhSystemVersion())
		{
			wrapperView.delegate = self;
		}
		
		[wrapperView setContentInsets:[OFContentFrameView getContentInsets]];
	}
	
	OFGameProfilePageInfo* clientAppContext = [[controllerInfos lastObject] clientApplicationInfo];
	OFFramedControllerInfo* newInfo = [OFFramedControllerInfo withController:controller andClientApplicationInfo:clientAppContext];
	[controllerInfos addObject:newInfo];

	[self _changeUserTo:userContext comparedWith:comparedToUser notifyController:NO];

	[super pushViewController:controller animated:animated];
	
	if (!animated)
	{
		// post push fixup.
		[self _positionViewsForController:controller animated:NO];
	}

	newInfo.banner = [self loadBannerFromController:controller];	
}

- (OFUser*)currentUser
{
	OFFramedControllerInfo* fci = [controllerInfos lastObject];
	return fci.user;
}

- (OFUser*)comparisonUser
{
	OFFramedControllerInfo* fci = [controllerInfos lastObject];
	return fci.comparedToUser;
}

- (void)refreshBanner
{
	OFFramedControllerInfo* info = [controllerInfos lastObject];
	info.banner = [self loadBannerFromController:self.topViewController];
	[self _positionViewsForController:self.topViewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController* popped = [super popViewControllerAnimated:animated];

	if (popped)
	{
		[controllerInfos removeLastObject];
		
		OFFramedControllerInfo* cui = [controllerInfos lastObject];
		[self _changeUserTo:cui.user comparedWith:cui.comparedToUser notifyController:NO];
	}

	return popped;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSArray* returned = [super popToViewController:viewController animated:animated];

	int numPopped = [returned count];
	for (int i = 0; i < numPopped; ++i)
		[controllerInfos removeLastObject];

	OFFramedControllerInfo* cui = [controllerInfos lastObject];
	[self _changeUserTo:cui.user comparedWith:cui.comparedToUser notifyController:NO];
	
	return returned;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	NSArray* returned = [super popToRootViewControllerAnimated:animated];
	
	int numPopped = [returned count];
	for (int i = 0; i < numPopped; ++i)
		[controllerInfos removeLastObject];

	OFFramedControllerInfo* cui = [controllerInfos lastObject];
	[self _changeUserTo:cui.user comparedWith:cui.comparedToUser notifyController:YES];

	return returned;
}

- (void)_safeSetContentInsets:(UIViewController*) viewController
{
	if (viewController && [viewController.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		UIEdgeInsets contentInsets = [self _calculateInsetsFor:viewController];
		[(OFFramedContentWrapperView*)viewController.view setContentInsets:contentInsets];
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[self _safeSetContentInsets:viewController];
	[super navigationController:navigationController willShowViewController:viewController animated:animated];
}

- (BOOL)_slideStuffInForVC:(UIViewController *)viewController
{
	[self _decideViewsForController:viewController];

	BOOL animatingInNavBar = (visibilityShould.showNavBar && !visibilityDoes.showNavBar);
	BOOL animatingInBottomView = (visibilityShould.showBottomView && !visibilityDoes.showBottomView);
	BOOL animatingInBanner = (visibilityShould.showBanner && !visibilityDoes.showBanner);
	
	if (animatingInNavBar || animatingInBottomView || animatingInBanner)
	{
		
		// in the case where we need to slide in the nav bar,
		// visibilityDoes.showNavBar isn't set yet.  We can't call _makeNavigationBarCoherent
		// though, because that will immediately reposition everything.
		// So basically we have to cheat a little here.
		if (visibilityShould.showNavBar && self.isNavigationBarHidden)
		{
			[super setNavigationBarHidden:NO animated:NO];
			[self _repositionViews];
			[self _repositionContent];
		}
		
		[UIView beginAnimations:@"slidingIn" context:nil];
		[UIView setAnimationDuration:0.325f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

		visibilityDoes.showNavBar |= visibilityShould.showNavBar;
		visibilityDoes.showBottomView |= visibilityShould.showBottomView;
		visibilityDoes.showBanner |= visibilityShould.showBanner;
		
		// If we're animating -anything-, we need to reposition.
		[self _repositionViews];
		
		[UIView commitAnimations];
		return TRUE;
	}
	
	// otw, not animating anything out on this transition.
	return FALSE;
	
}

- (BOOL)_slideStuffOutForVC:(UIViewController *)viewController
{
	[self _decideViewsForController:viewController];
	
	BOOL animatingOutNavBar = (!visibilityShould.showNavBar && visibilityDoes.showNavBar);
	BOOL animatingOutBottomView = (!visibilityShould.showBottomView && visibilityDoes.showBottomView);
	BOOL animatingOutBanner = (!visibilityShould.showBanner && visibilityDoes.showBanner);
	
	if (animatingOutNavBar || animatingOutBottomView || animatingOutBanner)
	{
		[UIView beginAnimations:@"slidingOut" context:nil];
		[UIView setAnimationDuration:0.325f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		
		visibilityDoes.showNavBar &= visibilityShould.showNavBar;
		visibilityDoes.showBottomView &= visibilityShould.showBottomView;
		visibilityDoes.showBanner &= visibilityShould.showBanner;
		
		// If we're animating -anything-, we need to reposition.
		[self _repositionViews];
		
		[UIView commitAnimations];
		return TRUE;
	}

	// otw, not animating anything out on this transition.
	return FALSE;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self _currentBannerDidAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self _currentBannerDidDisappear];
}

- (void)_postSlideOut:(UIViewController*)viewController
{
	// release stuff we no longer need.
	if (!visibilityDoes.showBottomView)
	{
		[customBottomView removeFromSuperview];
		OFSafeRelease(customBottomView);
	}

	// release or generate the bottom view.
	if (visibilityDoes.showBottomView != visibilityShould.showBottomView)
	{
		[self refreshBottomView];
		// This affects the content offset, so:
		[self _repositionContent];
	}
	
	// we mighta slid out the navbar.
	[self _makeNavBarCoherent];
	
	if (visibilityShould.showBanner)
	{
		visibilityShould.showBanner = NO;

		// time to attach the banner.  It was already allocated in _pushViewController.
		OFBannerCell* banner = [self _getBannerCellForViewController:viewController];
		
		if(banner)
		{
			visibilityShould.showBanner = YES;
			
			if(bannerView.bannerSubview && bannerView.bannerSubview != banner)
			{
				[self _currentBannerDidDisappear];
			}
			
			bannerView.bannerSubview = banner;
			[self _currentBannerDidAppear];
		}
	}
	else
	{
		if(bannerView.bannerSubview)
		{
			[self _currentBannerDidDisappear];
			bannerView.bannerSubview = nil;
		}
	}
}

- (void)_postSlideIn:(UIViewController*)viewController
{
}

- (void)animationDidStop:(NSString*)animId finished:(NSNumber*)finished context:(void*)context
{
	UIViewController* viewController = self.visibleViewController;

	if (animId == @"navBarAdjustment")
	{
		[self _makeNavBarCoherent];
	}
	if (animId == @"slidingOut")
	{
		[self _postSlideOut:viewController];
		if (![self _slideStuffInForVC:viewController])
		{
			[self _postSlideIn:viewController];
		}
	}
	else if (animId == @"slidingIn")
	{
		[self _postSlideIn:viewController];
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	[super navigationController:navigationController didShowViewController:viewController animated:animated];
	
	if (animated)
	{
		// If there's no slideout animation, go directly into slidein.
		if (![self _slideStuffOutForVC:viewController])
		{
			[self _postSlideOut:viewController];
			if (![self _slideStuffInForVC:viewController])
			{
				[self _postSlideIn:viewController];
			}
		}
	}
	else
	{
		[self _positionViewsForController:viewController animated:animated];
	}
}

- (void)refreshProfile
{
	if ([bannerView.bannerSubview isKindOfClass:[OFPlayerBannerCell class]])
    {
		OFPlayerBannerCell* headerView = (OFPlayerBannerCell*)bannerView.bannerSubview;
		if ([[headerView user] isLocalUser])
		{
			[headerView changeResource:[OpenFeint localUser]];
		}
    }
}

- (void)refreshBottomView
{
	UIView* newBottomView = nil;
	if ([self.topViewController conformsToProtocol:@protocol(OFCustomBottomView)])
	{
		newBottomView = [[(UIViewController<OFCustomBottomView>*)self.topViewController getBottomView] retain];
	}

	if (newBottomView != customBottomView)
	{
		[customBottomView removeFromSuperview];
		OFSafeRelease(customBottomView);
		customBottomView = [newBottomView retain];
	}

	if (customBottomView)
	{
		CGRect frame = customBottomView.frame;
		frame.origin.y = self.view.bounds.size.height;
		frame.size.width = self.view.bounds.size.width;
		customBottomView.frame = frame;

		[self.view addSubview:customBottomView];
	}

	[self _positionViewsForController:self.topViewController animated:NO];
}

- (void)adjustForKeyboard:(BOOL)_isKeyboardShown ofHeight:(float)_keyboardHeight
{
	isKeyboardShown = _isKeyboardShown;
	keyboardHeight = _keyboardHeight;

	[self _positionViewsForController:self.topViewController animated:YES];
}

- (OFFramedNavigationControllerVisibilityFlags)_visibilityFlagsForController:(UIViewController*)viewController
{
	OFFramedNavigationControllerVisibilityFlags v;
	
	v.showBanner = NO;
	if ([viewController conformsToProtocol:@protocol(OFBannerProvider)])
	{
		id<OFBannerProvider> bannerFrame = (id<OFBannerProvider>)viewController;
		v.showBanner = [bannerFrame isBannerAvailableNow];
	}
	
	if ([viewController conformsToProtocol:@protocol(OFFramedNavigationControllerBehavior)])
	{
		v.showNavBar = [(id<OFFramedNavigationControllerBehavior>)viewController shouldShowNavBar];
	}
	else
	{
		// if the controller has a cancel or other button, we definitely need to show the nav bar.
		if (viewController.navigationItem.rightBarButtonItem)
		{
			v.showNavBar = YES;
		}
		else
		{
			NSArray* vcs = self.viewControllers;
			if (!vcs || vcs.count == 0)
			{
				v.showNavBar = NO;
			}
			else
			{
				v.showNavBar = !([vcs objectAtIndex:0] == viewController) && !viewControllerSpecificallyWantsTheNavBarHidden;
			}
		}
	}

	v.showBottomView = [viewController conformsToProtocol:@protocol(OFCustomBottomView)];
	
	return v;
}

- (void)_decideViewsForController:(UIViewController*)viewController
{
	visibilityShould = [self _visibilityFlagsForController:viewController];
}

- (void)_genRectsWithBannerFrame:(CGRect&)bannerFrame
                      frameFrame:(CGRect&)frameFrame
                     navBarFrame:(CGRect&)navBarFrame
                     bottomFrame:(CGRect&)bottomFrame
                 visibilityFlags:(OFFramedNavigationControllerVisibilityFlags)visibilityFlags
{
	// set the nav bar appropriately first.
	navBarFrame.origin.y = visibilityFlags.showNavBar ? 0.f : -navBarFrame.size.height;
	
	// base banner off nav bar.
	bannerFrame.size = CGSizeMake([OpenFeint isInLandscapeMode] ? 480.f : 320.f, 58.f);
	bannerFrame.origin = CGPointZero;
	bannerFrame.origin.y = CGRectGetMaxY(navBarFrame);
	bannerFrame.origin.y -= visibilityFlags.showBanner ? 0.f : bannerFrame.size.height;
	
	// base the frame and content insets off the banner.
	frameFrame.origin = CGPointZero;
	frameFrame.origin.y = CGRectGetMaxY(bannerFrame);
	frameFrame.origin.y -= visibilityFlags.showBanner ? kfBannerOverlap : 0.f;  // we want them overlapping slightly
	
	frameFrame.size.height -= frameFrame.origin.y;
	
	frameFrame.size.height -= isKeyboardShown ? keyboardHeight : 0;
	
	if (visibilityFlags.showBottomView)
	{
		bottomFrame.origin.y = CGRectGetMaxY(frameFrame) - bottomFrame.size.height;
		frameFrame.size.height -= bottomFrame.size.height;
	}
}

- (void)_repositionViews
{
	CGRect bannerFrame = bannerView.frame;
	CGRect frameFrame = frameView.frame;
	frameFrame.size = self.view.bounds.size;

	CGRect navBarFrame = self.navigationBar.frame;
	CGRect bottomFrame = customBottomView.frame;
    
	[self _genRectsWithBannerFrame:bannerFrame frameFrame:frameFrame navBarFrame:navBarFrame bottomFrame:bottomFrame visibilityFlags:visibilityDoes];
	
	if (!is2PointOhSystemVersion())
	{
		self.navigationBar.frame = navBarFrame;
	}
	frameView.frame = frameFrame;
	bannerView.frame = bannerFrame;
	customBottomView.frame = bottomFrame;
}

- (void)_repositionContent
{
	[self _safeSetContentInsets:self.visibleViewController];
}

- (BOOL)frameWasSet:(OFFramedContentWrapperView*)wrapperView
{
	for (UIViewController* viewController in self.viewControllers)
	{
		if (viewController.view == wrapperView)
		{
			UIEdgeInsets contentInsets = [self _calculateInsetsFor:viewController];
			[(OFFramedContentWrapperView*)viewController.view setContentInsets:contentInsets];
			return YES;
		}
	}
	return NO; // unhandled
}

- (UIEdgeInsets)_calculateInsetsFor:(UIViewController*)viewController
{
	CGRect bannerFrame = bannerView.frame;
	CGRect frameFrame = frameView.frame;
	frameFrame.size = self.view.bounds.size;
	
	CGRect navBarFrame = self.navigationBar.frame;
	CGRect bottomFrame = customBottomView.frame;
	
	OFFramedNavigationControllerVisibilityFlags v = [self _visibilityFlagsForController:viewController];
	
    [self _genRectsWithBannerFrame:bannerFrame frameFrame:frameFrame navBarFrame:navBarFrame bottomFrame:bottomFrame visibilityFlags:v];
	UIEdgeInsets contentInsets = [OFContentFrameView getContentInsets];
	
	if (is2PointOhSystemVersion())
	{
		// Basically, since we cannot trust UINavigationController to put viewController at the right
		// place, we have to observe its place in subview space, then reverse-engineer the content
		// offsets from that.  We get notified every time the frame changes (because we're the
		// OFFramedContentWrapperView's delegate) so we can reposition then.
		CGRect frameInViewControllerSpace = [self.view convertRect:frameFrame toView:viewController.view];
		
		// NB: only the top and bottom of the contentInsets are used.
		contentInsets.top += frameInViewControllerSpace.origin.y;
		contentInsets.bottom += CGRectGetMaxY(viewController.view.frame) - CGRectGetMaxY(frameInViewControllerSpace);
		return contentInsets;
	}

	// We start with the content insets being aligned with frameframe.
	contentInsets.top += frameFrame.origin.y;
	
	// frameFrame is in self.view space, whereas the view controller (and therefore the content insets)
	// are in self.view+navbar.height space.  So, to derive accurate coordinates, we subtract out the
	// navbar height (unless of course it's hidden).
	if (!self.isNavigationBarHidden)
	{
		contentInsets.top -= navBarFrame.size.height;
	}

	// NB: dead code.
	if (is2PointOhSystemVersion())
	{
		if (self.isNavigationBarHidden)
		{
			contentInsets.bottom -= navBarFrame.size.height;
		}
	}
	
	if (isKeyboardShown)
	{
		contentInsets.bottom += keyboardHeight;
	}
	
	if (v.showBottomView)
	{
		contentInsets.bottom += bottomFrame.size.height;
	}
	
	return contentInsets;
}

- (void)_makeNavBarCoherent
{
	if (visibilityDoes.showNavBar && self.isNavigationBarHidden)
	{
		// we're about to slide in the navbar.
		[super setNavigationBarHidden:NO animated:NO];
		[self _repositionViews];
		[self _repositionContent];
	}		
	else if (!visibilityDoes.showNavBar && !self.isNavigationBarHidden)
	{
		// we just slid out the navbar, hide it by system.
		[super setNavigationBarHidden:YES animated:NO];
		[self _repositionViews];
		[self _repositionContent];
	}
}

- (void)_positionViewsForController:(UIViewController*)viewController animated:(BOOL)animated
{
	[self _decideViewsForController:viewController];
	visibilityDoes.showNavBar = visibilityShould.showNavBar;
	visibilityDoes.showBanner = visibilityShould.showBanner;
	visibilityDoes.showBottomView = visibilityShould.showBottomView;
	[self _postSlideOut:viewController];
	[self _postSlideIn:viewController];
	[self _repositionViews];
	[self _repositionContent];
}

- (void)_userChanged:(NSNotification*)notification
{
	if ([[notification name] isEqualToString:OFNSNotificationUserChanged])
	{
		OFUser* _previousUser = (OFUser*)[[notification userInfo] objectForKey:OFNSNotificationInfoPreviousUser];
		OFUser* _currentUser = (OFUser*)[[notification userInfo] objectForKey:OFNSNotificationInfoCurrentUser];

		for (OFFramedControllerInfo* fci in controllerInfos)
		{
			if ([fci.user.resourceId isEqualToString:_previousUser.resourceId])
			{
				fci.user = _currentUser;
				fci.comparedToUser = nil;
			}
			
			if ([fci.comparedToUser.resourceId isEqualToString:_previousUser.resourceId])
			{
				fci.comparedToUser = _currentUser;
			}
			
			if ([fci.banner isKindOfClass:[OFPlayerBannerCell class]])
			{
				[(OFPlayerBannerCell*)fci.banner changeResource:_currentUser];
			}
		}
		
		if ([controllerInfos count] > 0)
		{
			OFFramedControllerInfo* fci = [controllerInfos lastObject];
			[self _changeUserTo:fci.user comparedWith:fci.comparedToUser notifyController:YES];
			[self _positionViewsForController:self.topViewController animated:NO];
		}
	}
}

- (void)_changeUserTo:(OFUser*)user comparedWith:(OFUser*)comparedWithUser notifyController:(BOOL)notifyController
{
	OFFramedControllerInfo* fci = [controllerInfos lastObject];
	fci.user = user;
	fci.comparedToUser = comparedWithUser;

	if (notifyController && [fci.controller respondsToSelector:@selector(profileUsersChanged:comparedToUser:)])
	{
		[(id)fci.controller profileUsersChanged:user comparedToUser:comparedWithUser];
	}
}

#pragma mark Comparison

- (IBAction)compareButtonPressed
{
//	OFGameProfilePageInfo* info = [self currentGameContext];
//
//	if (!isComparisonEnabled || !info)
//		return;
//
//	if (isComparing)
//	{
//		[self _changeUserTo:[OpenFeint localUser] comparedWith:nil notifyController:YES];
//		[self _positionViewsForController:self.topViewController animated:YES];
//	}
//	else
//	{
//		[OFFriendPickerController launchPickerWithDelegate:self promptText:[NSString stringWithFormat:@"Friends who have %@", info.name] mustHaveApplicationId:info.resourceId];			
//	}
}

- (void)pickerFinishedWithSelectedUser:(OFUser*)selectedUser
{
	[self _changeUserTo:[OpenFeint localUser] comparedWith:selectedUser notifyController:YES];
	[self _positionViewsForController:self.topViewController animated:YES];
}

@end
