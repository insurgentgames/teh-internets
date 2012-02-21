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
#import "OpenFeint+Private.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFControllerLoader.h"
#import <QuartzCore/QuartzCore.h>
#import "OFPoller.h"
#import "OFProvider.h"
#import "OFPoller.h"
#import "OFDeadEndErrorController.h"
#import "OFReachability.h"
#import "OFServerMaintenanceNoticeController.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+NSNotification.h"
#import "OFNotification.h"
#import "OFNotificationDelegate.h"
#import "OFInputResponseOpenDashboard.h"
#import "OFActionRequest.h"
#import "OFNavigationController.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Dashboard.h"
#import "OFXmlDocument.h"
#import "OFTransactionalSaveFile.h"
#import <sqlite3.h>
#import "OFAchievementService+Private.h"
#import "OFImageCache.h"
#import "OFUserFeintApprovalController.h"
#import "OFLinkSocialNetworksController.h"
#import "OFDelegateChained.h"
#import "OFUsersCredential.h"
#import "OFExtendedCredentialController.h"
#import "OFSocialNotificationController.h"
#import "OFTableControllerHelper.h"
#import "OFRootController.h"
#import "OFDoBootstrapController.h"
#import "IPhoneOSIntrospection.h"
#import "OFTabBarController.h"
#import "OFChallengeListController.h"
#import "OFViewHelper.h"
#import "OFOfflineService.h"
#import "OFTabbedDashboardController.h"
#import "OFFramedNavigationController.h"
#import "OFGameProfileController.h"
#import "OFHighScoreController.h"
#import "OFLeaderboardController.h"
#import "OFLeaderboardService+Private.h"
#import "OFAnnouncementService+Private.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserStats.h"

namespace
{
	OpenFeint* gInstance = nil;
	unsigned int kOverlayBackgroundViewTag = 489;

	// We want to reserve 3MB when the dashboard isn't open.
	static const int kOFReservedMemorySize = (3*1024*1024);
}

@implementation OpenFeint (Private)

static BOOL s_BootstrapCompleted = NO;

+ (BOOL)hasBootstrapCompleted{
	return s_BootstrapCompleted;
}

+ (void)invalidateBootstrap{
	s_BootstrapCompleted = NO;
}

+ (void) createSharedInstance
{
	NSAssert(gInstance == nil, @"Attempting to initialize OpenFeint a second time. This is not allowed.");
	gInstance = [[OpenFeint alloc] init];
}

+ (void)destroySharedInstance
{
	NSAssert(gInstance != nil, @"Attempting to shutdown OpenFeint when it has not been initialized. This is not allowed.");
	OFSafeRelease(gInstance);
}

+ (void)loginWasCompleted
{
	[OpenFeint incrementNumberOfOnlineGameSessions];
	[OpenFeint incrementNumberOfGameSessions];
	
	if (![OpenFeint isShowingFullScreen])
	{
		NSUInteger numChallenges = [OpenFeint unviewedChallengesCount];
		NSUInteger numInbox = [OpenFeint unreadInboxCount];
		NSUInteger numFriends = [OpenFeint pendingFriendsCount];
		
		NSString* notificationText = nil;
		OFNotificationInputResponse* inputResponse = nil;

		if (numChallenges > 0)
		{
			inputResponse = [[[OFInputResponseOpenDashboard alloc] 
				initWithTab:OpenFeintDashBoardTabNowPlaying
				andControllerName:@"ChallengeList"] autorelease];

			notificationText = [NSString stringWithFormat:@"Hi %@! You have %u new challenge%@.", 
				[OpenFeint lastLoggedInUserName], 
				numChallenges, 
				(numChallenges > 1 ? @"s" : @"")];
		}
		else if (numInbox > 0)
		{
			inputResponse = [[[OFInputResponseOpenDashboard alloc] 
				initWithTab:OpenFeintDashBoardTabMyFeint
				andControllerName:@"Inbox"] autorelease];

			notificationText = [NSString stringWithFormat:@"Hi %@! You have %u unread conversation%@.", 
				[OpenFeint lastLoggedInUserName], 
				numInbox, 
				(numInbox > 1 ? @"s" : @"")];
		}
		else if(numFriends > 0)
		{
			inputResponse = [[[OFInputResponseOpenDashboard alloc] 
				initWithTab:OpenFeintDashBoardTabMyFeint
				andControllerName:@"Friends"] autorelease];

			notificationText = [NSString stringWithFormat:@"Hi %@! You have %u pending friend%@.", 
				[OpenFeint lastLoggedInUserName], 
				numFriends, 
				(numFriends > 1 ? @"s" : @"")];
		}
		else
		{
			inputResponse = [[OFInputResponseOpenDashboard new] autorelease];
			notificationText = [NSString stringWithFormat:@"Welcome back, %@", [OpenFeint lastLoggedInUserName]];
		}
		
		OFNotificationData* notificationData = [OFNotificationData dataWithText:notificationText andCategory:kNotificationCategoryLogin andType:kNotificationTypeSuccess];
		[[OFNotification sharedInstance] showBackgroundNotice:notificationData andStatus:OFNotificationStatusSuccess andInputResponse:inputResponse];
	}

	NSString* userId = [OpenFeint lastLoggedInUserId];
	[[OFOfflineService sharedInstance] performSelector:@selector(sendPendingData:) withObject:userId];
	
	[OFAnnouncementService downloadAnnouncements];
}

+ (void)loginWasAborted
{
	[OpenFeint incrementNumberOfGameSessions];
	NSString* noticeText;
	NSString* userId = [OpenFeint lastLoggedInUserId];

	if (![userId isEqualToString:@"0"] && [OpenFeint lastLoggedInUserName])
	{
		noticeText = [NSString stringWithFormat:@"Welcome back, %@, you are OFFLINE", [OpenFeint lastLoggedInUserName]];
	}
	else
	{
		noticeText = @"Not Logged In To OpenFeint";
	}
	OFNotificationData* notice = [OFNotificationData dataWithText:noticeText andCategory:kNotificationCategoryLogin andType:kNotificationTypeSuccess];
	[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusFailure andInputResponse:nil];	
}

+ (void)launchLoginFlowAndShowDashboard:(bool)shouldShowDashboard withOptionalRequest:(OFActionRequest*)request
{
	const bool isAutomaticallyPrompting = shouldShowDashboard == false;
	const NSString* complicatedErrorOccurred = @"Unable to login to OpenFeint. Restart to try again.";
	OFNotificationData* notice = [OFNotificationData dataWithText:complicatedErrorOccurred andCategory:kNotificationCategoryLogin andType:kNotificationTypeError];
	if(![self isShowingFullScreen])
	{
		if(isAutomaticallyPrompting && ![self shouldAutomaticallyPromptLogin] && !request.failedNotAuthorized)
		{
			[self loginWasAborted];
		}
		else
		{
			[[OFNotification sharedInstance] showBackgroundNotice:notice andStatus:OFNotificationStatusFailure andInputResponse:nil];
		}
	}
	else
	{
		[self displayErrorMessage:complicatedErrorOccurred];
	}
	
	[request abandonInLightOfASeriousError];
}

+ (void)launchLoginFlowThenDismiss
{
	[self launchLoginFlowAndShowDashboard:false withOptionalRequest:nil];
}

+ (void)launchLoginFlowToDashboard
{
	[self launchLoginFlowAndShowDashboard:true withOptionalRequest:nil];
}

+ (void)launchLoginFlowForRequest:(OFActionRequest*)request;
{
	[self launchLoginFlowAndShowDashboard:[OpenFeint isDashboardHubOpen] withOptionalRequest:request];
}

- (void)invokeAndClearBootstrapDelegates:(std::vector<OFDelegate>&)delegates
{
	std::vector<OFDelegate>::const_iterator it = delegates.begin();
	std::vector<OFDelegate>::const_iterator itEnd = delegates.end();
	for (; it != itEnd; ++it)
	{
		it->invoke();
	}
	mBootstrapSuccessDelegates.clear();
	mBootstrapFailureDelegates.clear();
}

- (void) _succeededBootstrapping:(NSObject*)param
{
	mSuccessfullyBootstrapped = true;
	mForceCreateAccountOnBootstrap = false;
	
	s_BootstrapCompleted = YES;
	
	[self invokeAndClearBootstrapDelegates:mBootstrapSuccessDelegates];
	
	[OpenFeint switchToOnlineDashboard];

	[OpenFeint loginWasCompleted];
	
	//s_BootstrapCompleted = YES;
	
	OF_OPTIONALLY_INVOKE_DELEGATE_WITH_PARAMETER([OpenFeint getDelegate], userLoggedIn:, (id)[OpenFeint lastLoggedInUserId]);	
	
#ifdef __IPHONE_3_0
	if (mPushNotificationsEnabled)
	{
		if ([OpenFeint isTargetAndSystemVersionThreeOh])
		{
			const int notificationFlags = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)notificationFlags];
		}
	}
#endif
	
	//s_BootstrapCompleted = YES;
	
#if 1	// DIAG_GetTheMost
	if ([OpenFeint doneWithGetTheMost]){
		//OfLog(@"GetTheMost screen is not needed.");
	}else if( [OFLinkSocialNetworksController hasSessionSeenLinkSocialNetworksScreen] ){
		//OfLog(@"GetTheMost screen still needed but already seen since app start.");
	}else if( [OpenFeint isShowingFullScreen] ){
		//OfLog(@"GetTheMost screen delayed on full screen from _succeededBootstrapping.");
	}else{
		UIViewController* getTheMostController = nil;
		OFNavigationController* navController = nil;
		
		getTheMostController = (UIViewController*)OFControllerLoader::load(@"LinkSocialNetworks");
		navController = [[[OFNavigationController alloc] initWithRootViewController:getTheMostController] autorelease];
		[navController setNavigationBarHidden:YES animated:NO];
		
		if ([OpenFeint isShowingFullScreen]){
			//OfLog(@"GetTheMost screen launched in full screen from _succeededBootstrapping.");
			
			[[OpenFeint getRootController] presentModalViewController:navController animated:YES];
		}else{			
			//OfLog(@"GetTheMost screen launched as indepedent modal from _succeededBootstrapping.");
			
			[OpenFeint presentRootControllerWithModal:navController];
		}
	}	
#endif
}

- (void) _failedBootstrapping:(NSObject*)param
{
	[OpenFeint loginWasAborted];
	mForceCreateAccountOnBootstrap = false;
	[self invokeAndClearBootstrapDelegates:mBootstrapFailureDelegates];
}

+ (void)doBootstrapWithDeviceToken:(NSData*)deviceToken forceCreateAccount:(bool)forceCreateAccount
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	[instance->mProvider loginAndBootstrapWithDeviceToken:deviceToken 
									   forceCreateAccount:forceCreateAccount
												   userId:nil
												onSuccess:OFDelegate(instance, @selector(_succeededBootstrapping:)) 
												onFailure:OFDelegate(instance, @selector(_failedBootstrapping:))];
}

+ (void)doBootstrap:(const OFDelegate&)chainedOnSuccess onFailure:(const OFDelegate&)chainedOnFailure
{
	[OpenFeint doBootstrap:false onSuccess:chainedOnSuccess onFailure:chainedOnFailure];
}

+ (void)doBootstrap:(bool)forceCreateAccount onSuccess:(const OFDelegate&)chainedOnSuccess onFailure:(const OFDelegate&)chainedOnFailure
{
	[OpenFeint doBootstrap:forceCreateAccount userId:nil onSuccess:chainedOnSuccess onFailure:chainedOnFailure];
}

+ (void)doBootstrap:(bool)forceCreateAccount userId:(NSString*)userId onSuccess:(const OFDelegate&)chainedOnSuccess onFailure:(const OFDelegate&)chainedOnFailure
{
	//  [adill note] if we put this code back in then uninstall + reinstall of a game
	//      will not show the open feint approval screen. 
	//	OpenFeint* instance = [OpenFeint sharedInstance];
	//	if ([instance->mProvider isAuthenticated])
	//	{
	//		[OpenFeint setUserApprovedFeint];
	//	}
	
	if([OpenFeint hasUserApprovedFeint])
	{
		[OpenFeint addBootstrapDelegates:chainedOnSuccess onFailure:chainedOnFailure];
		OpenFeint* instance = [OpenFeint sharedInstance];
		instance->mForceCreateAccountOnBootstrap = forceCreateAccount;
		[instance->mProvider loginAndBootstrapWithDeviceToken:nil 
										   forceCreateAccount:forceCreateAccount
													   userId:userId
													onSuccess:OFDelegate(instance, @selector(_succeededBootstrapping:)) 
													onFailure:OFDelegate(instance, @selector(_failedBootstrapping:))];
	}
	else if (![OpenFeint hasUserSetFeintAccess])
	{
		OFDelegate nilDelegate;
		[OpenFeint presentUserFeintApprovalModal:nilDelegate deniedDelegate:nilDelegate];
	}
}

+ (void)addBootstrapDelegates:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	instance->mBootstrapSuccessDelegates.push_back(onSuccess);
	instance->mBootstrapFailureDelegates.push_back(onFailure);
}

+ (BOOL)isSuccessfullyBootstrapped
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	return instance ? instance->mSuccessfullyBootstrapped : NO;
}

+ (void)presentConfirmAccountModal:(OFDelegate&)onCompletionDelegate useModalInDashboard:(BOOL)useModalInDashboard
{
	OFDoBootstrapController* approvalFlow = (OFDoBootstrapController*)OFControllerLoader::load(@"DoBootstrap");
	[approvalFlow setCompleteDelegate:onCompletionDelegate];
	
	if ([OpenFeint isShowingFullScreen])
	{
		if (useModalInDashboard)
		{
			OFNavigationController* newNavController = [[[OFNavigationController alloc] initWithRootViewController:approvalFlow] autorelease];
			[newNavController setNavigationBarHidden:YES animated:NO];
			[[OpenFeint getRootController] presentModalViewController:newNavController animated:YES];
		}
		else
		{
			UINavigationController* navController = [OpenFeint getActiveNavigationController];
			OFAssert(navController, "Must have a navigation controller in this case!");
			[navController pushViewController:approvalFlow animated:YES];
		}
		
	}
	else
	{
		OFNavigationController* navController = [[[OFNavigationController alloc] initWithRootViewController:approvalFlow] autorelease];
		[navController setNavigationBarHidden:YES animated:NO];
		[OpenFeint presentRootControllerWithModal:navController];
	}
}

+ (BOOL) _extendedCredentialsRequiredFor:(const char*)credentialXmlPath withDocument:(OFXmlDocument*)errorDocument
{
	NSString* message = [errorDocument getElementValue:credentialXmlPath];
	return [message isEqualToString:@"extended_credentials"];
}

+ (void)launchGetExtendedCredentialsFlowForRequest:(OFActionRequest*)request withData:(NSData*)data andNoticeUserData:(id)notificationUserData
{
	UIViewController< OFExtendedCredentialController >* firstController = nil;

	OFXmlDocument* errorDocument = [OFXmlDocument xmlDocumentWithData:data];
	if ([self _extendedCredentialsRequiredFor:"errors.TwitterCredential" withDocument:errorDocument])
	{
		firstController = (UIViewController< OFExtendedCredentialController >*)OFControllerLoader::load(@"TwitterExtendedCredential");
		[firstController setRequestRequiringCredential:request];

		if ([notificationUserData isKindOfClass:[OFSocialNotification class]])
		{
			[firstController setSocialNotification:(OFSocialNotification*)notificationUserData];
		}
	}
	if ([self _extendedCredentialsRequiredFor:"errors.FbconnectCredential" withDocument:errorDocument])
	{
		UIViewController< OFExtendedCredentialController >* tempController = nil;
		tempController = (UIViewController< OFExtendedCredentialController >*)OFControllerLoader::load(@"FacebookExtendedCredential");
		[tempController setRequestRequiringCredential:request];

		if ([notificationUserData isKindOfClass:[OFSocialNotification class]])
		{
			[tempController setSocialNotification:(OFSocialNotification*)notificationUserData];
		}

		if (firstController)
		{
			[firstController setRequestRequiringCredential:nil];
			[firstController setNextController:tempController];
		}
		else
		{
			firstController = tempController;
		}
	}

	[OpenFeint presentModalOverlay:firstController];
}

+ (void)launchRequestUserPermissionForSocialNotification:(OFSocialNotification*)socialNotification withCredentialTypes:(NSArray*)credentials
{
	OFSocialNotificationController* modal = (OFSocialNotificationController*)OFControllerLoader::load(@"SocialNotification");
	modal.socialNotification = socialNotification;
	
	for (OFUsersCredential* credential in credentials)
	{
		if ([credential isFacebook])
			[modal addSocialNetworkIcon:[OFImageLoader loadImage:@"OFFacebookIcon.png"]];
		else if ([credential isTwitter])
			[modal addSocialNetworkIcon:[OFImageLoader loadImage:@"OFTwitterIcon.png"]];
	}
	
	[OpenFeint presentModalOverlay:modal];
}

+ (void)transformViewToDashboardOrientation:(UIView*)view
{
	UIInterfaceOrientation dashboardOrientation = [OpenFeint sharedInstance]->mDashboardOrientation;

	CGAffineTransform newTransform = CGAffineTransformIdentity;
	CGRect bounds = view.bounds;
	CGPoint center = view.center;
	switch (dashboardOrientation) 
	{
		case UIInterfaceOrientationLandscapeRight:
			newTransform = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
			bounds = CGRectMake(0.f, 0.f, bounds.size.height, bounds.size.width);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			newTransform = CGAffineTransformMake(0, -1, 1, 0, 0, 0);
			bounds = CGRectMake(0.f, 0.f, bounds.size.height, bounds.size.width);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			newTransform = CGAffineTransformMake(-1, 0, 0, -1, 0, 0);
			break;
		case UIInterfaceOrientationPortrait:
			newTransform = CGAffineTransformTranslate(newTransform, 0, 0);
			break;
		default:
			OFAssert(false, "invalid dashboard orientation used");
			break;
	}
	
	[view setTransform:newTransform];
	view.bounds = bounds;
	view.center = center;
}

+ (bool)tryCreateDashboardWithModal:(UIViewController*)modal
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	
	if ([OpenFeint isShowingFullScreen] || (instance->mOFRootController && instance->mIsDashboardDismissing))
	{
		instance->mQueuedRootModal = [modal retain];
		return false;
	}

	instance->mIsDashboardDismissing = false;
	
	// jkw: Must be called before the root controller is loaded
	[self dashboardWillAppear];
	
	if (!instance->mOFRootController)
	{
		instance->mOFRootController = [OFControllerLoader::load(@"Root") retain];
	}

	[OpenFeint transformViewToDashboardOrientation:instance->mOFRootController.view];
	
	[[OpenFeint getTopApplicationWindow] addSubview:instance->mOFRootController.view];
		
	return true;
}

+ (void)presentModalOverlay:(UIViewController*)modal
{
	OpenFeint* instance = [OpenFeint sharedInstance];

	if(![self tryCreateDashboardWithModal:modal])
	{
		instance->mIsQueuedModalAnOverlay = true;
		return;
	}

	instance->mIsShowingOverlayModal = true;

	CGRect dashboardBounds = [OpenFeint getDashboardBounds];

	UIView* backgroundView = [[[UIView alloc] initWithFrame:dashboardBounds] autorelease];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	backgroundView.autoresizesSubviews = YES;
	backgroundView.backgroundColor = [UIColor blackColor];
	backgroundView.tag = kOverlayBackgroundViewTag;	
	backgroundView.alpha = 0.0f;
	[instance->mOFRootController.view addSubview:backgroundView];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	backgroundView.alpha = 0.85f;
	[UIView commitAnimations];
	
	CGRect modalRect = modal.view.frame;
	modalRect.origin.x = 0.5f * (dashboardBounds.size.width - modalRect.size.width);
	modal.view.frame = modalRect;
	
	instance->mOFRootController.transitionIn = kCATransitionFromBottom;
	instance->mOFRootController.transitionOut = kCATransitionFromTop;
	[instance->mOFRootController showController:modal];
}

+ (void)presentRootControllerWithModal:(UIViewController*)modal
{
	OpenFeint* instance = [OpenFeint sharedInstance];

	if(![self tryCreateDashboardWithModal:modal])
	{
		instance->mIsQueuedModalAnOverlay = false;
		return;
	}

	instance->mIsShowingOverlayModal = false;

	CGRect rootBounds = instance->mOFRootController.view.bounds;
	modal.view.frame = CGRectMake(0.f, 0.f, rootBounds.size.width, rootBounds.size.height);
	
	instance->mOFRootController.transitionIn = kCATransitionFromTop;
	instance->mOFRootController.transitionOut = kCATransitionFromBottom;
	[instance->mOFRootController showController:modal];
}

+ (void)presentRootControllerWithTabbedDashboard:(NSString*)controllerName
{
	[self presentRootControllerWithTabbedDashboard:controllerName pushControllers:nil];
}

+ (void)presentRootControllerWithTabbedDashboard:(NSString*)controllerName pushControllers:(NSArray*)pushControllers
{
	OFTabbedDashboardController* tabController = nil;
	BOOL alreadyOpen = NO;
	
	if ([OpenFeint isDashboardHubOpen])
	{
		// We may be being launched from inside a notification?
		tabController = (OFTabbedDashboardController*)gInstance->mOFRootController.contentController;
		alreadyOpen = YES;
	}
	else
	{
		tabController = (OFTabbedDashboardController*)OFControllerLoader::load(@"TabbedDashboard");
	}
	
	bool online = [OpenFeint isOnline];
	
	NSString* override = [OpenFeint initialDashboardScreen];
	if (!controllerName && [OpenFeint hasUserApprovedFeint] && override && override.length)
	{
		controllerName = override;
	}
	
	controllerName = (controllerName ? controllerName : [tabController defaultTab]);

	// The only tab guaranteed to work offline is the NowPlaying tab.
	if (![OpenFeint isOnline])
	{
		controllerName = [tabController offlineTab];
		pushControllers = nil;
	}

	if (!alreadyOpen)
	{
		[OpenFeint presentRootControllerWithModal:tabController];
	}
	[tabController showTabViewControllerNamed:controllerName];

	OFFramedNavigationController* navController = (OFFramedNavigationController*) tabController.tabBar.selectedViewController;
	if (alreadyOpen)
	{
		[navController popToRootViewControllerAnimated:NO];
	}
	
    UIViewController* controllerToPush = nil;
	bool allowed = true;
	for (NSObject* obj in pushControllers)
	{
		if (allowed)
		{
			if ([obj isKindOfClass:[NSString class]])
			{
				if (controllerToPush && [controllerToPush isKindOfClass:[OFLeaderboardController class]])
				{
					//The previous controller was leaderboard, the string is a leaderboardId for high scores
					OFLeaderboard* leaderboard = [OFLeaderboardService getLeaderboard:(NSString*)obj];
					if( leaderboard )
					{
						controllerToPush = (UIViewController*)OFControllerLoader::load(OpenFeintControllerHighScores);
						controllerToPush.title = @"HighScore";
						OFHighScoreController* highScoreController = (OFHighScoreController*)controllerToPush;
						highScoreController.leaderboard = leaderboard;
					} 
					else
					{
						controllerToPush = nil;
					}
				} else { 
					NSString* pushControllerName = (NSString*)obj;
					controllerToPush = (UIViewController*)OFControllerLoader::load(pushControllerName);
				}
			}
			else if ([obj isKindOfClass:[UIViewController class]])
			{
				controllerToPush = (UIViewController*)obj;
			}
			else
				OFAssert(false, "Unrecognized argument type!");
			
			allowed = online; //if offline assume controller is not allowed
			if (controllerToPush && [controllerName isEqualToString:OpenFeintDashBoardTabNowPlaying])
			{
				OFGameProfilePageInfo* localInfo = [OpenFeint localGameProfileInfo];
				[navController changeGameContext:localInfo];
				[OFGameProfileController setPushControllerData:controllerToPush withGameProfileInfo:localInfo];

				if ([controllerToPush.title isEqualToString: @"Achievements"])
				{
					allowed = [OpenFeint appHasAchievements];
				}
				else if ([controllerToPush.title isEqualToString: @"Leaderboards"] ||
						 [controllerToPush.title isEqualToString: @"HighScore"])
				{
					allowed = [OpenFeint appHasLeaderboards] || [OFLeaderboardService hasLeaderboards];
				}
			}
			
			if (allowed)
			{
				[navController pushViewController:controllerToPush animated:YES];
			}
		}
	}
	
#if defined(_DEBUG) || defined(DEBUG)
	if ([self shouldWarnOnIncompleteDelegates])
	{
		// Only do this once per install anyway...
		[self setShouldWarnOnIncompleteDelegates:NO];
		
		// Let's look at our delegate
		id delegate = [self sharedInstance]->mDelegatesContainer.openFeintDelegate;
		
		if (!delegate ||
			![delegate respondsToSelector:@selector(dashboardWillAppear)] ||
			![delegate respondsToSelector:@selector(dashboardDidDisappear)])
		{
			NSString* msg = nil;
			if (!delegate) {
				msg = [NSString stringWithFormat:
					   @"Please make sure to provide a delegate to OpenFeint!"];
			} else {
				msg = [NSString stringWithFormat:
					   @"%s doesn't implement some of the dashboard-handling "
					   "messages from OpenFeintDelegate.h.  Please make sure "
					   "to pause your game and stop updating the view when you "
					   "open the Dashboard!  See OpenFeintDelegate.h for details.",
					   object_getClassName(delegate)];
			}
			UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"OpenFeint Developer Warning"
														 message:msg
														delegate:nil
											   cancelButtonTitle:@"OK"
											   otherButtonTitles:nil];
			
			[av show];
			[av release];
		}
	}	
#endif
}

- (void)_presentRootControllerWithTabbedDashboard
{
	if ([OpenFeint isOnline])
	{
	  [OpenFeint presentRootControllerWithTabbedDashboard:nil];
	} else {
		[OpenFeint destroyDashboard];
	}
}

+ (void) launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName
{
	[self launchDashboardWithDelegate:delegate tabControllerName:tabControllerName andControllers:nil];
}

+ (void) launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName andController:(NSString*)controller
{
	NSArray* controllers = [[[NSArray alloc] initWithObjects:controller,nil] autorelease];
	[self launchDashboardWithDelegate:delegate tabControllerName:tabControllerName andControllers:controllers];
}

+ (void) launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName andControllers:(NSArray*)controllers
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	instance->mLaunchDelegate = delegate;
	
	if (![OpenFeint hasUserApprovedFeint] && ![OFLeaderboardService hasLeaderboards])
	{
		OFDelegate nilDelegate;
		OFDelegate presentRootControllerDelegate([OpenFeint sharedInstance], @selector(_presentRootControllerWithTabbedDashboard));
		[OpenFeint presentUserFeintApprovalModal:presentRootControllerDelegate deniedDelegate:nilDelegate];
	}
	else if (([instance->mProvider isAuthenticated] && [OpenFeint lastLoggedInUserId]) || [OFLeaderboardService hasLeaderboards]) 
	{
		[OpenFeint presentRootControllerWithTabbedDashboard:tabControllerName pushControllers:controllers];
	}
	else if (!OFReachability::Instance()->isGameServerReachable()) 
	{
		[[[[UIAlertView alloc] initWithTitle:@"No OpenFeint Account" 
									 message:@"You must go online once and connect to the OpenFeint server." 
									delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		[self launchLoginFlowToDashboard];
	}
}

+ (void)switchToOnlineDashboard
{
	[[NSNotificationCenter defaultCenter] postNotificationName:OFNSNotificationUserOnline object:nil userInfo:nil];
	
	OpenFeint* instance = [OpenFeint sharedInstance];	
	
	UIViewController* topController = instance->mOFRootController.contentController;
	if([topController isKindOfClass:[OFTabBarController class]])
	{
		OFTabBarController* tabController = (OFTabBarController*)topController;
		[OFTabbedDashboardController setOnlineMode:tabController];
	}

	[OpenFeint reloadInactiveTabBars];
}

+ (void)switchToOfflineDashboard
{
	[[NSNotificationCenter defaultCenter] postNotificationName:OFNSNotificationUserOffline object:nil userInfo:nil];

	OpenFeint* instance = [OpenFeint sharedInstance];	

	[OpenFeint setUnviewedChallengesCount:0];
	[OpenFeint setUnreadInboxCount:0];
	[OpenFeint setPendingFriendsCount:0];
	[OFAnnouncementService clearLocalAnnouncements];

	UIViewController* topController = instance->mOFRootController.contentController;
	if([topController isKindOfClass:[OFTabBarController class]])
	{
		OFTabBarController* tabController = (OFTabBarController*)topController;
		[tabController showTabViewControllerNamed:OpenFeintDashBoardTabNowPlaying showAtRoot:YES];
		OFFramedNavigationController* navController = (OFFramedNavigationController*) tabController.tabBar.selectedViewController;
		[OFTabbedDashboardController setOfflineMode:tabController];

		if ([[navController topViewController] isKindOfClass:[OFGameProfileController class]])
		{
			[(OFGameProfileController*)[navController topViewController] refreshView];
		}

		if (instance->mOFRootController.modalViewController != nil)
		{
			[instance->mOFRootController dismissModalViewControllerAnimated:YES];
		}
	}
// needs testing
//	else
//	{
//		[OpenFeint presentRootControllerWithTabbedDashboard:OpenFeintDashBoardTabNowPlaying pushControllers:nil];
//	}	
}

+ (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if(instance->mIsDashboardDismissing)
	{
		instance->mIsDashboardDismissing = false;
		
		[OpenFeint destroyDashboard];

		if (instance->mQueuedRootModal)
		{
			if (instance->mIsQueuedModalAnOverlay)
				[OpenFeint presentModalOverlay:instance->mQueuedRootModal];
			else
				[OpenFeint presentRootControllerWithModal:instance->mQueuedRootModal];

			OFSafeRelease(instance->mQueuedRootModal);
		}
	}
	else
	{
		[OpenFeint dashboardDidAppear];
	}
}

+ (void)dismissRootController
{
	if (![OpenFeint isShowingFullScreen])
	{
		return;
	}
	
	OpenFeint* instance = [OpenFeint sharedInstance];

	instance->mIsDashboardDismissing = true;
	
	if(instance->mIsShowingOverlayModal)
	{
		UIView* backgroundView = OFViewHelper::findViewByTag(instance->mOFRootController.view, kOverlayBackgroundViewTag);
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		backgroundView.alpha = 0.0f;
		[UIView commitAnimations];
	}

	[instance->mOFRootController hideController];
			
	[self dashboardWillDisappear];
}
	
+ (void)dismissRootControllerOrItsModal
{
	if (![OpenFeint isShowingFullScreen])
	{
		return;
	}
	
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance->mOFRootController.modalViewController != nil)
	{
		[instance->mOFRootController dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[OpenFeint dismissRootController];
	}	
}

+ (UIWindow*)getTopApplicationWindow
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	
	if (instance && instance->mPresentationWindow)
		return instance->mPresentationWindow;

	UIApplication* clientApp = [UIApplication sharedApplication];
	
	NSAssert([[clientApp windows] count] > 0, @"Your application must have at least one window set before launching OpenFeint");
	UIWindow* topWindow = [clientApp keyWindow];
	if (!topWindow)
	{
		OFLog(@"OpenFeint found no key window. Uses first available window instead."); 
		topWindow = [[clientApp windows] objectAtIndex:0];
	}
	
	return topWindow;
}

+ (id<OpenFeintDelegate>)getDelegate
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	
	if(instance->mLaunchDelegate)
	{
		return instance->mLaunchDelegate;
	}
	
	return instance->mDelegatesContainer.openFeintDelegate;
}

+ (id<OFNotificationDelegate>)getNotificationDelegate
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	return instance->mDelegatesContainer.notificationDelegate;
}

+ (id<OFChallengeDelegate>)getChallengeDelegate
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	return instance->mDelegatesContainer.challengeDelegate;
}

+ (UIInterfaceOrientation)getDashboardOrientation
{
	return [OpenFeint sharedInstance] ? [OpenFeint sharedInstance]->mDashboardOrientation : UIInterfaceOrientationPortrait;
}

+ (BOOL)isInLandscapeMode
{
	UIInterfaceOrientation activeOrientation = [OpenFeint getDashboardOrientation];
	return activeOrientation == UIInterfaceOrientationLandscapeLeft || activeOrientation == UIInterfaceOrientationLandscapeRight;
}

+ (CGRect)getDashboardBounds
{
	CGRect dashboardBounds = [[UIScreen mainScreen] bounds];
	if ([OpenFeint isInLandscapeMode])
	{
		dashboardBounds = CGRectMake(dashboardBounds.origin.x, dashboardBounds.origin.y, dashboardBounds.size.height, dashboardBounds.size.width);
	}
	return dashboardBounds;
}


+ (void)destroyDashboard
{
	[self dashboardDidDisappear];

	OpenFeint* instance = [OpenFeint sharedInstance];

	[instance->mOFRootController dismissModalViewControllerAnimated:NO];
	[instance->mOFRootController.view removeFromSuperview];
	OFSafeRelease(instance->mOFRootController);
	
	instance->mLaunchDelegate = nil;
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[OFImageCache sharedInstance] purge];
}

+ (void)updateApplicationBadge
{
	NSInteger badgeNumber = [OpenFeint unviewedChallengesCount];
	[UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
}

+ (OpenFeint*) sharedInstance
{
	return gInstance;
}

+ (UIView*)getTopLevelView
{
	OFRootController* root = (OFRootController*)[OpenFeint getRootController];
	if ([root contentController])
	{
		return [root contentController].view;
	}

	return [root view];
}

+ (UIViewController*)getRootController
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	return instance ? instance->mOFRootController : nil;
}

+ (bool)isShowingFullScreen
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance && instance->mOFRootController)
	{
		return !instance->mIsDashboardDismissing && instance->mOFRootController.contentController;
	}

	return false;
}

+ (bool)isDashboardHubOpen
{
	return [self isShowingFullScreen] && [gInstance->mOFRootController.contentController isKindOfClass:[OFTabbedDashboardController class]];
}

+ (UINavigationController*)getActiveNavigationController
{
	OpenFeint* instance = [OpenFeint sharedInstance];	
	
	UIViewController* visibleViewController = instance->mOFRootController.modalViewController;
	if (visibleViewController && [visibleViewController isKindOfClass:[UINavigationController class]])
	{
		return (UINavigationController*)visibleViewController;
	}
	
	visibleViewController = instance->mOFRootController.contentController;
	
	if([visibleViewController isKindOfClass:[UINavigationController class]])
	{
		return (UINavigationController*)visibleViewController;
	}
	else if([visibleViewController isKindOfClass:[OFTabBarController class]])
	{
		OFTabBarController* tabBarController = (OFTabBarController*)visibleViewController;
		UIViewController* selectedTab = [[tabBarController tabBar] selectedViewController];
		
		if([selectedTab isKindOfClass:[UINavigationController class]])
		{
			return (UINavigationController*)selectedTab;
		}			
	}
		
	return nil;
}

+ (void)reloadInactiveTabBars
{
	OpenFeint* instance = [OpenFeint sharedInstance];	
	
	UIViewController* topController = instance->mOFRootController.contentController;
	if([topController isKindOfClass:[OFTabBarController class]])
	{
		OFTabBarController* tabController = (OFTabBarController*)topController;
		for (OFTabBarItem* tabItem in tabController.tabBarItems)
		{
			UIViewController* tabPageController = tabItem.viewController;
			if (tabPageController && [tabPageController isKindOfClass:[UINavigationController class]])
			{
				UINavigationController* nestedNavController = (UINavigationController*)tabPageController;

				if (tabPageController != [[tabController tabBar] selectedViewController])
				{
					[nestedNavController popToRootViewControllerAnimated:NO];
					if ([nestedNavController.topViewController isKindOfClass:[OFTableControllerHelper class]])
					{
						OFTableControllerHelper* tableController = (OFTableControllerHelper*)nestedNavController.topViewController;
						[tableController reloadDataFromServer];
					}
				}

				if ([nestedNavController isKindOfClass:[OFFramedNavigationController class]])
				{
					[(OFFramedNavigationController*)nestedNavController refreshProfile];
				}
			}
		}
	}
}

+ (void)_delayedPushViewController:(UIViewController*)errorController inNavController:(UINavigationController*)activeNavController
{
	[OpenFeint sharedInstance]->mIsErrorPending = NO;
	[activeNavController pushViewController:errorController animated:YES];
}

+ (void)displayErrorMessage:(UIViewController*)errorController inNavController:(UINavigationController*)activeNavController
{
	if ([OpenFeint sharedInstance]->mAllowErrorScreens == NO)
		return;

	if ([OpenFeint isShowingErrorScreenInNavController:activeNavController])
	{
		return;
	}
	
	// citron note: The navigation controller system doesn't behave properly if you push
	//				a view, pop a view, and push again all while it's trying to animate one of its views.
	//				By adding a slight delay here, we prevent the user from spamming actions which cause
	//				visual artifiacts in the navigation bar.
	SEL delayedPushSelector = @selector(_delayedPushViewController:inNavController:);
	NSInvocation* delayedPush = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:delayedPushSelector]];
	[delayedPush setSelector:delayedPushSelector];
	[delayedPush setTarget:self];
	[delayedPush setArgument:&errorController atIndex:2];
	[delayedPush setArgument:&activeNavController atIndex:3];	
	[delayedPush retainArguments];	
	const float enoughTimeForViewControllerAnimationsToPlay = 0.1f;
	[delayedPush performSelector:@selector(invoke) withObject:nil afterDelay:enoughTimeForViewControllerAnimationsToPlay];
	
	[OpenFeint sharedInstance]->mIsErrorPending = YES;
}

+ (void)allowErrorScreens:(BOOL)allowed
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		instance->mAllowErrorScreens = allowed;
	}
}

+ (BOOL)areErrorScreensAllowed
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		return instance->mAllowErrorScreens;
	}
	
	return NO;
}

+ (BOOL)isShowingErrorScreenInNavController:(UINavigationController*)navController
{
	if (![OpenFeint sharedInstance])
		return NO;
		
	UIViewController* currentViewController = [navController visibleViewController];
	UIViewController* incomingViewController = (UIViewController*)[navController.viewControllers lastObject];
	
	const bool isTopAnError = [currentViewController isKindOfClass:[OFDeadEndErrorController class]];
	const bool isAnimatingInAnError = [incomingViewController isKindOfClass:[OFDeadEndErrorController class]];
	if(isAnimatingInAnError || isTopAnError || [OpenFeint sharedInstance]->mIsErrorPending)
	{
		return YES;
	}
	
	return NO;
}

+ (void)displayUpgradeRequiredErrorMessage:(NSData*)data
{
	if([OpenFeint isShowingFullScreen])
	{
		OFXmlDocument* errorDocument = [OFXmlDocument xmlDocumentWithData:data];
		NSString* message = [errorDocument getElementValue:"error_message"];
		message = [NSString stringWithFormat:message, [OpenFeint applicationDisplayName]];
		
		UIViewController* viewController = [OFDeadEndErrorController deadEndErrorWithMessage:message];
		viewController.navigationItem.hidesBackButton = YES;

		UINavigationController* activeNavController = [self getActiveNavigationController];
		[OpenFeint displayErrorMessage:viewController inNavController:activeNavController];
	}
}

+ (void)displayServerMaintenanceNotice:(NSData*)data
{
	if([OpenFeint isShowingFullScreen])
	{
		UINavigationController* activeNavController = [self getActiveNavigationController];
		[self displayErrorMessage:[OFServerMaintenanceNoticeController maintenanceControllerWithHtmlData:data] inNavController:activeNavController];
	}
}

+ (void)displayErrorMessage:(NSString*)message
{
	if([OpenFeint isShowingFullScreen])
	{
		UINavigationController* activeNavController = [self getActiveNavigationController];
		if (![OpenFeint isDashboardHubOpen] || OFReachability::Instance()->isGameServerReachable())
		{
			[self displayErrorMessage:[OFDeadEndErrorController deadEndErrorWithMessage:message] inNavController:activeNavController];
		}
		else
		{
			[self displayErrorMessage:[OFDeadEndErrorController deadEndErrorWithMessageAndOfflineButton:message] inNavController:activeNavController];
		}
	}
}

+ (void)displayErrorMessageAndOfflineButton:(NSString*)message
{
	if([OpenFeint isShowingFullScreen])
	{
		UINavigationController* activeNavController = [self getActiveNavigationController];
		[self displayErrorMessage:[OFDeadEndErrorController deadEndErrorWithMessageAndOfflineButton:message] inNavController:activeNavController];
	}
}

+ (OFProvider*)provider
{
	OpenFeint* instance = [self sharedInstance];
	if (instance)
		return instance->mProvider;
		
	return nil;
}

+ (bool)isTargetAndSystemVersionThreeOh
{
#ifdef __IPHONE_3_0
	return is3PointOhSystemVersion();
#else
	return false;	
#endif
}

+ (void) dashboardDidAppear
{
	[self dashboardLaunched];
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getDelegate], dashboardDidAppear);	
}

+ (void)dashboardDidDisappear
{
	[OpenFeint dashboardClosed];
	// Wait until the dashboard has fully disappeared before reserving memory,
	// so that we don't attempt to grab memory until there's memory to grab.
	[self reserveMemory];
	
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getDelegate], dashboardDidDisappear);
}

+ (void) dashboardWillAppear
{	
	[OpenFeint sharedInstance]->mPreviousOrientation = [UIApplication sharedApplication].statusBarOrientation;
	[OpenFeint sharedInstance]->mPreviousStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[[UIApplication sharedApplication] setStatusBarOrientation:[OpenFeint sharedInstance]->mDashboardOrientation];	

	// Release any memory we've reserved so that we actually have room to allocate the
	// dashboard into.
	[self releaseReservedMemory];
	
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getDelegate], dashboardWillAppear);
}

+ (void)dashboardWillDisappear
{
	UIApplication* clientApp = [UIApplication sharedApplication];
	
	[clientApp setStatusBarOrientation:[OpenFeint sharedInstance]->mPreviousOrientation animated:YES];
	[clientApp setStatusBarHidden:[OpenFeint sharedInstance]->mPreviousStatusBarHidden animated:YES];
	
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getDelegate], dashboardWillDisappear);
}

+ (void)reserveMemory
{
#ifdef OPENFEINT_MEMORY_PAD_ENABLED
	OFAssert([OpenFeint sharedInstance]->mReservedMemory == NULL, "Unbalanced reserve memory requests.");

	[OpenFeint sharedInstance]->mReservedMemory = malloc(kOFReservedMemorySize);

	// It's necessary to actually touch all the memory so that the VMM actually
	// commits all the pages.
	bzero([OpenFeint sharedInstance]->mReservedMemory, kOFReservedMemorySize);
#endif
}

+ (void)releaseReservedMemory
{
#ifdef OPENFEINT_MEMORY_PAD_ENABLED
	OFAssert([OpenFeint sharedInstance]->mReservedMemory != NULL, "Unbalanced reserve memory requests.");
	
	free([OpenFeint sharedInstance]->mReservedMemory);
	[OpenFeint sharedInstance]->mReservedMemory = NULL;
#endif
}

+ (void)setPollingFrequency:(NSTimeInterval)frequency
{
	[[OpenFeint sharedInstance]->mPoller changePollingFrequency:frequency];
}

+ (void)setPollingToDefaultFrequency
{
	[[OpenFeint sharedInstance]->mPoller resetToDefaultPollingFrequency];
}

+ (void)stopPolling
{
	[[OpenFeint sharedInstance]->mPoller stopPolling];
}

+ (void)forceImmediatePoll
{
	[[OpenFeint sharedInstance]->mPoller pollNow];
}

+ (void)clearPollingCacheForClassType:(Class)resourceClassType
{
	[[OpenFeint sharedInstance]->mPoller clearCacheForResourceClass:resourceClassType];
}

+ (void)setupOfflineDatabase
{
	if (SQLITE_OK != sqlite3_open([OFTransactionalSaveFile::getSavePathForFile(@"feint_offline") UTF8String], &[OpenFeint sharedInstance]->mOfflineDatabaseHandle))
	{
		OFAssert(false, "Failed to initialize offline database!");
		[OpenFeint sharedInstance]->mOfflineDatabaseHandle = nil;
	}
}

+ (void)teardownOfflineDatabase
{
	if (SQLITE_BUSY == sqlite3_close([OpenFeint sharedInstance]->mOfflineDatabaseHandle))
	{
		OFLog(@"Not all SQLite memory has been released in offline database!");
	}
}

+ (struct sqlite3*)getOfflineDatabaseHandle
{
	return [OpenFeint sharedInstance]->mOfflineDatabaseHandle;
}

+ (BOOL)allowUserGeneratedContent
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		return (!instance->mDisableUGC && [OpenFeint loggedInUserHasChatEnabled]);
	}
	
	return YES;
}

+ (BOOL)invertNotifications
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		return instance->mInvertedNotifications;
	}
	
	return NO;
}

+ (CLLocation*) getUserLocation
{
	CLLocation* userLoc = nil;
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		userLoc = instance->mLocation.userLocation;
	}
	return userLoc;
}

+ (void) setUserLocation:(OFLocation*)userLoc
{
	OpenFeint* instance = [OpenFeint sharedInstance];
	if (instance)
	{
		OFSafeRelease(instance->mLocation);
		instance->mLocation = [userLoc retain];
	}
}
+ (void) startLocationManagerIfAllowed
{
	OFUserDistanceUnitType userDistanceUnit = [OpenFeint userDistanceUnit];
	if ( userDistanceUnit != kDistanceUnitNotAllowed && [OpenFeint hasUserApprovedFeint] ) 
	{
		OpenFeint* instance = [OpenFeint sharedInstance];
		if (instance)
		{
			instance->mLocation = [[[OFLocation alloc] init] retain];
		}
	}
}

@end
