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

#import "OpenFeint.h"
#import "OFNotificationStatus.h"
#import "OFSocialNotification.h"

@class OFActionRequest;
@class MPOAuthAPIRequestLoader;
struct sqlite3;

@interface OpenFeint (Private)

+ (BOOL)hasBootstrapCompleted;
+ (void)invalidateBootstrap;

+ (OpenFeint*) sharedInstance;
+ (void) createSharedInstance;
+ (void) destroySharedInstance;
+ (id<OpenFeintDelegate>)getDelegate;
+ (id<OFNotificationDelegate>)getNotificationDelegate;
+ (id<OFChallengeDelegate>)getChallengeDelegate;
+ (UIInterfaceOrientation)getDashboardOrientation;
+ (BOOL)isInLandscapeMode;
+ (CGRect)getDashboardBounds;

+ (void)loginWasAborted;
+ (void)loginWasCompleted;

+ (void)launchLoginFlowThenDismiss;
+ (void)launchLoginFlowToDashboard;
+ (void)launchLoginFlowForRequest:(OFActionRequest*)request;
+ (void)doBootstrapWithDeviceToken:(NSData*)deviceToken forceCreateAccount:(bool)forceCreateAccount;
+ (void)doBootstrap:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (void)doBootstrap:(bool)forceCreateAccount onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (void)doBootstrap:(bool)forceCreateAccount userId:(NSString*)userId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (void)addBootstrapDelegates:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (BOOL)isSuccessfullyBootstrapped;
+ (void)presentConfirmAccountModal:(OFDelegate&)onCompletionDelegate useModalInDashboard:(BOOL)useModalInDashboard;

+ (void)launchGetExtendedCredentialsFlowForRequest:(OFActionRequest*)request withData:(NSData*)data andNoticeUserData:(id)notificationUserData;
+ (void)launchRequestUserPermissionForSocialNotification:(OFSocialNotification*)socialNotification withCredentialTypes:(NSArray*)credentials;

+ (UIWindow*)getTopApplicationWindow;
+ (UIView*) getTopLevelView;
+ (UIViewController*)getRootController;
+ (UINavigationController*)getActiveNavigationController;
+ (void)reloadInactiveTabBars;
+ (bool)isShowingFullScreen;
+ (bool)isDashboardHubOpen;
+ (void)presentModalOverlay:(UIViewController*)modal;
+ (void)presentRootControllerWithModal:(UIViewController*)modal;
+ (void)presentRootControllerWithTabbedDashboard:(NSString*)controllerName;
+ (void)presentRootControllerWithTabbedDashboard:(NSString*)controllerName pushControllers:(NSArray*)pushControllers;
+ (void)launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName;
+ (void)launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName andController:(NSString*)controller;
+ (void)launchDashboardWithDelegate:(id<OpenFeintDelegate>)delegate tabControllerName:(NSString*)tabControllerName andControllers:(NSArray*)controllers;
+ (void)dismissRootController;
+ (void)dismissRootControllerOrItsModal;
+ (void)destroyDashboard;

+ (void)updateApplicationBadge;

+ (void)allowErrorScreens:(BOOL)allowed;
+ (BOOL)areErrorScreensAllowed;
+ (BOOL)isShowingErrorScreenInNavController:(UINavigationController*)navController;

+ (void)displayUpgradeRequiredErrorMessage:(NSData*)data;
+ (void)displayErrorMessage:(NSString*)message;
+ (void)displayErrorMessageAndOfflineButton:(NSString*)message;
+ (void)displayServerMaintenanceNotice:(NSData*)data;

+ (void)dashboardWillAppear;
+ (void)dashboardDidAppear;
+ (void)dashboardWillDisappear;
+ (void)dashboardDidDisappear;

+ (void)reserveMemory;
+ (void)releaseReservedMemory;

+ (void)setPollingFrequency:(NSTimeInterval)frequency;
+ (void)setPollingToDefaultFrequency;
+ (void)stopPolling;
+ (void)forceImmediatePoll;
+ (void)clearPollingCacheForClassType:(Class)resourceClassType;

+ (void)switchToOnlineDashboard;
+ (void)switchToOfflineDashboard;

+ (void)setupOfflineDatabase;
+ (void)teardownOfflineDatabase;
+ (struct sqlite3*)getOfflineDatabaseHandle;

+ (OFProvider*)provider;
+ (bool)isTargetAndSystemVersionThreeOh;

+ (BOOL)allowUserGeneratedContent;
+ (BOOL)invertNotifications;

+ (void) startLocationManagerIfAllowed;
+ (CLLocation*) getUserLocation;
+ (void) setUserLocation:(OFLocation*)userLoc;

@end
