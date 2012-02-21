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

#import "OFCallbackable.h"

enum OFAbuseType
{
	kAbuseType_Chat,
	kAbuseType_Forum
};

@interface OFAbuseReporter : NSObject< OFCallbackable, UIActionSheetDelegate >
{
@private
	OFAbuseType abuseType;
	NSString* flaggableId;
	NSString* flaggableType;
	
	BOOL reported;
	NSString* userId;
	UIViewController* viewController;
}

@property (retain) NSString* flaggableId;
@property (retain) NSString* flaggableType;

+ (void)reportAbuseByUser:(NSString*)userId fromController:(UIViewController*)viewController;
+ (void)reportAbuseByUser:(NSString*)userId forumPost:(NSString*)forumPostId fromController:(UIViewController*)viewController;
+ (void)reportAbuseByUser:(NSString*)userId forumThread:(NSString*)forumThreadId fromController:(UIViewController*)viewController;

@end