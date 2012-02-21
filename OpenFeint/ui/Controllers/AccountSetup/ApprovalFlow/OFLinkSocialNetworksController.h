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

#import "OFViewController.h"
#import "OFDefaultButton.h"

@class OFFriendImporter;

@interface OFLinkSocialNetworksController : OFViewController
{
	OFFriendImporter* mImporter;
	IBOutlet UILabel* mAppNameLabel;
	IBOutlet OFTextButton* mBtnConnectTwitter;		// DIAG_GetTheMost
	IBOutlet OFTextButton* mBtnConnectFacebook;		// DIAG_GetTheMost
	IBOutlet UISwitch* mShareLocationSwitch;		// DIAG_GetTheMost
	IBOutlet UISwitch* mShareOnlineStatusSwitch;	// DIAG_GetTheMost
	BOOL	 mShareLocationOriginalState;			// DIAG_GetTheMost
	BOOL	 mShareOnlineStatusOriginalState;		// DIAG_GetTheMost
	OFDelegate mOnCompletionDelegate;
}


@property (nonatomic, retain) IBOutlet OFTextButton* mBtnConnectTwitter;	// DIAG_GetTheMost
@property (nonatomic, retain) IBOutlet OFTextButton* mBtnConnectFacebook;	// DIAG_GetTheMost
@property (nonatomic, retain) IBOutlet UISwitch* mShareLocationSwitch;		// DIAG_GetTheMost
@property (nonatomic, retain) IBOutlet UISwitch* mShareOnlineStatusSwitch;	// DIAG_GetTheMost
@property (nonatomic) BOOL	 mShareLocationOriginalState;					// DIAG_GetTheMost
@property (nonatomic) BOOL	 mShareOnlineStatusOriginalState;				// DIAG_GetTheMost


- (IBAction)onImportFromTwitter;
- (IBAction)onImportFromFacebook;
- (IBAction)onSkip;
- (void)setCompleteDelegate:(OFDelegate&)completeDelegate;

+ (BOOL)hasSessionSeenLinkSocialNetworksScreen;
+ (void)invalidateSessionSeenLinkSocialNetworksScreen;


@end
