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

#import "OFCallbackable.h"
#import "OFNotificationStatus.h"

@class MPOAuthAPIRequestLoader;
@class OFNotificationInputResponse;

@interface OFNotificationView : UIView<OFCallbackable>
{
@package
	UILabel* notice;
	UIImageView* statusIndicator;
	UIImageView* backgroundImage;
	UIImageView* disclosureIndicator;
	
	OFNotificationInputResponse* mInputResponse;
	BOOL mParentViewIsRotatedInternally;
	BOOL mPresenting;
	float mNotificationDuration;

	UIView* presentationView;
}

+ (void)showNotificationWithRequest:(MPOAuthAPIRequestLoader*)request andNotice:(NSString*)noticeText inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;
+ (void)showNotificationWithText:(NSString*)noticeText andStatus:(OFNotificationStatus*)status inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;

- (void)configureWithRequest:(MPOAuthAPIRequestLoader*)request andNotice:(NSString*)noticeText inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;
- (void)configureWithText:(NSString*)noticeText andStatus:(OFNotificationStatus*)status inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse;

- (bool)canReceiveCallbacksNow;

@property (nonatomic, retain) IBOutlet UILabel* notice;
@property (nonatomic, retain) IBOutlet UIImageView* statusIndicator;
@property (nonatomic, retain) IBOutlet UIImageView* backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView* disclosureIndicator;

- (void)_setPresentationView:(UIView*)_presentationView;
- (void)_presentForDuration:(float)duration;

@end