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

@class OFAnnouncement;

@protocol OpenFeintDelegate<NSObject>

@optional

////////////////////////////////////////////////////////////
///
/// @note This is where you should pause your game.
///
////////////////////////////////////////////////////////////
- (void)dashboardWillAppear;

////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////
- (void)dashboardDidAppear;

////////////////////////////////////////////////////////////
///
/// @note This is where Cocoa based games should unpause and resume playback. 
///
/// @warning	Since an exit animation will play, this will cause negative performance if your game 
///				is rendering on an EAGLView. For OpenGL games, you should refresh your view once and
///				resume your game in dashboardDidDisappear
///
////////////////////////////////////////////////////////////
- (void)dashboardWillDisappear;

////////////////////////////////////////////////////////////
///
/// @note This is where OpenGL games should unpause and resume playback.
///
////////////////////////////////////////////////////////////
- (void)dashboardDidDisappear;

////////////////////////////////////////////////////////////
///
/// @note This is called whenever the game successfully connects to OpenFeint with a logged in user, not just when a new user logs in
///
////////////////////////////////////////////////////////////
- (void)userLoggedIn:(NSString*)userId;

////////////////////////////////////////////////////////////
///
/// @note This is called whenever a user explicitly logs out from OpenFeint from within the dashboard
///	      This is NOT called when the player switches account within the OpenFeint dashboard. In that case only userLoggedIn is called with the new user.
///
////////////////////////////////////////////////////////////
- (void)userLoggedOut:(NSString*)userId;

////////////////////////////////////////////////////////////
///
/// @note Developers can override this method to customize the OpenFeint approval screen. Returning YES will prevent OpenFeint from
///       displaying it's default approval screen. If a developer chooses to override the approval screen they MUST call 
///       [OpenFeint userDidApproveFeint:(BOOL)approved] before OpenFeint will function.
///
////////////////////////////////////////////////////////////
- (BOOL)showCustomOpenFeintApprovalScreen;

////////////////////////////////////////////////////////////
///
/// @note Developers can override this method to customize the developer announcement screen. Returning YES will prevent OpenFeint from
///       displaying it's default screen.
///
////////////////////////////////////////////////////////////
- (BOOL)showCustomScreenForAnnouncement:(OFAnnouncement*)announcement;

@end
