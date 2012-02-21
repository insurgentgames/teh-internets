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

#import <UIKit/UIKit.h>
#import "OFSocialNotification.h"
#import "OFViewController.h"

@class OFImageView;

@interface OFSocialNotificationController : OFViewController< OFCallbackable >
{
	OFSocialNotification* mSocialNotification;
	
	UILabel* mNotificationText;
	UILabel* mApplicationLabel;
	OFImageView* mNotificationImage;
	
	UISwitch* mRememberSwitch;

	UIImageView* mNetworkIcon1;
	UIImageView* mNetworkIcon2;
}

@property(nonatomic,retain) OFSocialNotification* socialNotification;
@property(nonatomic,retain) IBOutlet UILabel* notificationText;
@property(nonatomic,retain) IBOutlet UILabel* applicationLabel;
@property(nonatomic,retain) IBOutlet OFImageView* notificationImage;
@property(nonatomic,retain) IBOutlet UISwitch* rememberSwitch;
@property(nonatomic,retain) IBOutlet UIImageView* networkIcon1;
@property(nonatomic,retain) IBOutlet UIImageView* networkIcon2;

-(void)addSocialNetworkIcon:(UIImage*)networkIcon;

-(IBAction)yesButtonClicked:(UIButton*)sender;
-(IBAction)noButtonClicked:(UIButton*)sender;
-(void)dismiss;

-(bool)canReceiveCallbacksNow;

@end