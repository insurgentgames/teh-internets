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

#ifndef __cplusplus
	#error "OpenFeint requires Objective-C++. In XCode, you can enable this by changing your file's extension to .mm"
#endif

#import "OFDependencies.h"
#import "OFDelegatesContainer.h"
#import "OpenFeintSettings.h"
#import "OFCallbackable.h"
#import "OFLocation.h"

@class OFProvider;
@class OFPoller;
@class OFRootController;
@class OFUser;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// Public OpenFeint API
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface OpenFeint : NSObject<UIActionSheetDelegate, CLLocationManagerDelegate, OFCallbackable>
{
@private
	OFDelegatesContainer* mDelegatesContainer;
	id<OpenFeintDelegate> mLaunchDelegate;
	bool mIsDashboardDismissing;
	UIWindow* mPresentationWindow;
	UIViewController* mQueuedRootModal;
	bool mIsQueuedModalAnOverlay;
	OFRootController* mOFRootController;
	NSString* mDisplayName;
	NSString* mShortDisplayName;
	OFProvider* mProvider;
	OFPoller* mPoller;
	UIInterfaceOrientation mPreviousOrientation;
	UIInterfaceOrientation mDashboardOrientation;
	bool mInvertedNotifications;
	bool mPreviousStatusBarHidden;
	NSTimeInterval mPollingFrequencyBeforeResigningActive;
	struct sqlite3* mOfflineDatabaseHandle;
	bool mIsErrorPending;
	bool mPushNotificationsEnabled;
	
	std::vector<OFDelegate> mBootstrapSuccessDelegates;
	std::vector<OFDelegate> mBootstrapFailureDelegates;
	bool mForceCreateAccountOnBootstrap;
	bool mSuccessfullyBootstrapped;
	bool mAllowErrorScreens;
	bool mIsShowingOverlayModal;
	bool mDisableUGC;
	
	void* mReservedMemory;
	
	OFLocation* mLocation;
	OFUser* mCachedLocalUser;
}

////////////////////////////////////////////////////////////
///
/// @param productKey is copied. This is your unique product key you received when registering your application.
/// @param productSecret is copied. This is your unique product secret you received when registering your application.
/// @param displayName is copied.
/// @param settings is copied. The available settings are defined as OpenFeintSettingXXXXXXXXXXXX. See OpenFeintSettings.h
/// @param delegatesContainer is retained but none of the delegates in the container are retained. 
///
/// @note This will begin the application authorization process.
///
////////////////////////////////////////////////////////////
+ (void) initializeWithProductKey:(NSString*)productKey 
						andSecret:(NSString*)secret
				   andDisplayName:(NSString*)displayName
					  andSettings:(NSDictionary*)settings 
					 andDelegates:(OFDelegatesContainer*)delegatesContainer;

////////////////////////////////////////////////////////////
///
/// Shuts down OpenFeint
///
////////////////////////////////////////////////////////////
+ (void) shutdown;

////////////////////////////////////////////////////////////
///
/// Launches the OpenFeint Dashboard view at the top of your application's keyed window.
///
/// @note:	If the player has not yet authorized your app, they will be prompted to setup an 
///			account or authorize your application before accessing the OpenFeint dashboard
///
////////////////////////////////////////////////////////////
+ (void) launchDashboard;

////////////////////////////////////////////////////////////
///
/// @see launchDashboard
/// 
/// @param delegate The delegate that is used for this launch. The original delegate will be restored
///					after dismissing the dashboard for use in future calls to launchDashboard.
///
////////////////////////////////////////////////////////////
+ (void) launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate;

////////////////////////////////////////////////////////////
///
/// Removes the OpenFeint Dashboard from your application's keyed window.
///
////////////////////////////////////////////////////////////
+ (void) dismissDashboard;

////////////////////////////////////////////////////////////
///
/// Sets what orientation the dashboard and notifications will show in.
///
////////////////////////////////////////////////////////////
+ (void) setDashboardOrientation:(UIInterfaceOrientation)orientation;

////////////////////////////////////////////////////////////
///
/// @return The version of the OpenFeint client library in use.
///
////////////////////////////////////////////////////////////
+ (NSUInteger)versionNumber;

////////////////////////////////////////////////////////////
///
/// If your application is using a non-portrait layout, you must invoke and return this instead 
/// of directly returning your supported orientations from shouldAutorotateToInterfaceOrientation.
///
/// @example
///		const unsigned int numOrientations = 2;
///		UIInterfaceOrientation myOrientations[numOrientations] = { UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight };
///		return [OpenFeint shouldAutorotateToInterfaceOrientation:interfaceOrientation withSupportedOrientations:myOrientations andCount:numOrientations];
///
////////////////////////////////////////////////////////////
+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation withSupportedOrientations:(UIInterfaceOrientation*)nullTerminatedOrientations andCount:(unsigned int)numOrientations;

////////////////////////////////////////////////////////////
///
/// These allow OpenFeint to turn off/on background processes when the user is 
/// not interacting with your application. 
///
////////////////////////////////////////////////////////////
+ (void)applicationWillResignActive;
+ (void)applicationDidBecomeActive;

////////////////////////////////////////////////////////////
///
/// If OpenFeintSettingEnablePushNotifications is set to true, these functions MUST be called
/// from the application delegates
/// - application:didRegisterForRemoteNotificationsWithDeviceToken:
/// - application:didFailToRegisterForRemoteNotificationsWithError:
/// - application:didReceiveRemoteNotification:
///
////////////////////////////////////////////////////////////
+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
+ (void)applicationDidFailToRegisterForRemoteNotifications;
/// Returns whether or not OpenFeint responded to the notification parameters
+ (BOOL)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo;

////////////////////////////////////////////////////////////
///
/// Call this method from application:didFinishLaunchingWithOptions: after OpenFeint has been initialized
/// This MUST be implemented for challenges to work through remote notifications.
///
/// Returns whether or not OpenFeint responded to the launch options
///
////////////////////////////////////////////////////////////
+ (BOOL)respondToApplicationLaunchOptions:(NSDictionary*)launchOptions;

////////////////////////////////////////////////////////////
///
/// Returns whether or not the user has enabled OpenFeint for this game.
///
////////////////////////////////////////////////////////////
+ (bool)hasUserApprovedFeint;

////////////////////////////////////////////////////////////
///
/// Call this method ONLY if overriding the OpenFeint disclosure screen via the delegate method
/// -(BOOL)willLaunchOpenFeintDisclosureScreen. You must pass in whether or not the user has chosen
/// to use OpenFeint in this application. You may optionally pass in a delegate that gets  called
/// once the setup process is complete
///
////////////////////////////////////////////////////////////
+ (void)userDidApproveFeint:(BOOL)approved;
+ (void)userDidApproveFeint:(BOOL)approved accountSetupCompleteDelegate:(OFDelegate&)accountSetupCompleteDelegate;

////////////////////////////////////////////////////////////
///
/// The OpenFeint Approval flow is launched automatically on initialization (and dashboard launch if user hasn't approved OpenFeint). 
/// Only call this when the user requests to use OpenFeint features and [OpenFeint hasUserApprovedFeint] returns false.
/// An example is when a user wants to create a challenge.
///
////////////////////////////////////////////////////////////
+ (void)presentUserFeintApprovalModal:(OFDelegate&)approvedDelegate deniedDelegate:(OFDelegate&)deniedDelegate;

////////////////////////////////////////////////////////////
///
/// Returns whether or not the game is connected to the OpenFeint server
///
////////////////////////////////////////////////////////////
+ (bool)isOnline;

////////////////////////////////////////////////////////////
///
/// Attempt to login to OpenFeint with the specified user. If the login attempt succeeds your onSuccess delegate will be invoked and
/// it the attempt fails your onFailure delegate will be invoked.
///
////////////////////////////////////////////////////////////
+ (void)loginWithUserId:(NSString*)openFeintUserId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

@end
