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

////////////////////////////////////////////////////////////
///
/// @type		NSNumber UIInterfaceOrientation
/// @default	UIInterfaceOrientationPortrait
/// @behavior	Defines what orientation the OpenFeint dashboard launches in. The dashboard does not auto rotate.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingDashboardOrientation;


////////////////////////////////////////////////////////////
///
/// @type		NSString 
/// @default	Your application's (short) display name.
/// @behavior	Used as the game tab's title
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingShortDisplayName;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	Allows this application to send and receive Push Notifications. Only available on OS 3.0.
///				If set to true you must call OpenFeint::applicationDidRegisterForRemoteNotificationsWithDeviceToken
///				and OpenFeint::applicationDidFailToRegisterForRemoteNotifications from your UIApplicationDelegate
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingEnablePushNotifications;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	When a user enters the OpenFeint dashboard they will be unable to access the chat and forum functionality
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingDisableUserGeneratedContent;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	If this is true, then when OpenFeint displays achievement, score, or challenge notifications,
///				they will drop down from the top of the screen instead of popping up from the bottom of the
///				screen.  Useful if you are using the bottom of the screen as a critical area.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingInvertNotifications;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	If this is true then the application will prompt the user to approve OpenFeint every time the
///				application launches in DEBUG mode only. This makes testing custom approval screens easier.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingAlwaysAskForApprovalInDebug;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	If this is false, then OpenFeint will check to make sure you're handling dashboard notifications
///				in DEBUG mode only, and give you a message if you aren't.  If this is fully intentional you
///				can set this to true; however it is strongly recommended that you implement these delegate
///				methods to pause and unpause your game when the dashboard comes up.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingDisableIncompleteDelegateWarning;

////////////////////////////////////////////////////////////
///
/// @type		UIWindow
/// @default	nil
/// @behavior	You can specify a UIWindow here which will be the window that OpenFeint launches it's dashboard
///				in and the window that OpenFeint displays it's notification views in. If you *do not* specify a
///				UIWindow here OpenFeint will choose the UIApplication's keyWindow, and failing that it will
///				choose the first of the UIApplication's UIWindow objects.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingPresentationWindow;

////////////////////////////////////////////////////////////
///
/// @type		NSString
/// @default	nil
/// @behavior	If this setting is present then OpenFeint will attempt to authenticate as the specified user id
///				during the initialization process.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingInitialUserId;

////////////////////////////////////////////////////////////
///
/// @type		NSNumber bool
/// @default	false 
/// @behavior	If this is true then OpenFeint will automatically prompt the user to post achievements to twitter
///				and/or facebook when they are successfully unlocked. If false, the prompt is not shown automatically.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingPromptToPostAchievementUnlock;

////////////////////////////////////////////////////////////
///
/// @type		NSString
/// @default	nil
/// @behavior	If this setting is present, then OpenFeint will attempt to load nibs with the given suffix
///				before attempting to load nibs with its default suffix ("Of").  You can use this if you want
///				to override specific controller nibs within OpenFeint with your own.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingOverrideSuffixString;

////////////////////////////////////////////////////////////
///
/// @type		NSString
/// @default	nil
/// @behavior	If this setting is present, then OpenFeint will attempt to instantiate classes with the given
///				prefix before attempting to instantiate classes with its default prefix ("OF").  You can use
///				this if you want to override specific UI classes within OpenFeint with your own.
///
////////////////////////////////////////////////////////////
extern const NSString* OpenFeintSettingOverrideClassNamePrefixString;

