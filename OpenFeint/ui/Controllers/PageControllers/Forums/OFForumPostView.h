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

#import "OFViewController.h"
#import "OFCallbackable.h"

@class OFForumPost;
@class OFImageView;
@class OFForumThreadViewController;

@interface OFForumPostView : OFViewController< OFCallbackable >
{
	OFForumPost* post;

	IBOutlet OFForumThreadViewController* owner;
	
	IBOutlet UIScrollView* scrollView;
	
	IBOutlet OFImageView* authorPicture;
	IBOutlet UILabel* authorName;
	IBOutlet UILabel* gameName;
	IBOutlet UILabel* postBody;	
	IBOutlet UIView* bodyWrapperView;
	IBOutlet UIView* footerView;
	IBOutlet UIImageView* actionWindow;
	
	IBOutlet UIButton* chatButton;
	IBOutlet UIButton* reportButton;
	IBOutlet UIButton* addFriendButton;
	IBOutlet UIButton* replyButton;
	
	BOOL nextDisabled;
	BOOL prevDisabled;
}

@property (retain) OFForumPost* post;

- (void)disableNext:(BOOL)disable;
- (void)disablePrevious:(BOOL)disable;

- (IBAction)_chat;
- (IBAction)_report;
- (IBAction)_friend;

@end
