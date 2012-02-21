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

#import "OFTableSequenceControllerHelper.h"
#import "OFProfileFrame.h"

@class OFUsersCredential;

@interface OFSelectProfilePictureController : OFTableSequenceControllerHelper
                                                  < OFProfileFrame,
                                                    UIActionSheetDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    UINavigationControllerDelegate >
{
	int refreshCount;
	IBOutlet UIButton* refreshButton;
	
	OFUsersCredential* facebookCredentialWaitingForUpdate;
	OFUsersCredential* twitterCredentialWaitingForUpdate;
	OFUsersCredential* httpBasicCredentialWaitngForUpdate;
    
	BOOL redownloadOnNextAppear;
	BOOL refreshOnNextRedownload;
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath;

- (IBAction)_clickedRefresh;
- (IBAction)_presentCustomImageActionSheet;

@end
