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

#import "OFNotificationView.h"
#import "OFReceivedChallengeNotificationData.h"
@class OFImageView;
@class OFChallengeToUser;


@interface OFChallengeNotificationView : OFNotificationView
{
@package
	OFChallengeToUser* challengeToUser;
	OFImageView*	challengeIcon;
	OFImageView*	challengerProfileImage;
	UILabel*		challengerText;

}

+ (void)showChallengeNotice:(OFReceivedChallengeNotificationData*)notificationData inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;

- (void)configureWithNotificationData:(OFReceivedChallengeNotificationData*)notificationData inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;

@property (nonatomic, retain) IBOutlet OFImageView*		challengeIcon;
@property (nonatomic, retain) IBOutlet OFImageView*		challengerProfileImage;
@property (nonatomic, retain) IBOutlet UILabel*			challengerText;

@end
