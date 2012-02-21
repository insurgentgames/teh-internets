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

#import "OFTableCellHelper.h"

@class OFChatRoomController;
@class OFImageView;

@interface OFChatRoomChatMessageCell : OFTableCellHelper
{
@private
	OFChatRoomController* owner;
	
	OFImageView* profilePictureView;
	OFImageView* gamePictureView;
	
	UILabel* playerNameLabel;
	UILabel* gameNameLabel;
	UILabel* chatMessageLabel;
}

@property (nonatomic, readwrite, assign) IBOutlet OFChatRoomController* owner;

@property (nonatomic, retain) IBOutlet OFImageView* profilePictureView;
@property (nonatomic, retain) IBOutlet OFImageView* gamePictureView;

@property (nonatomic, retain) IBOutlet UILabel* playerNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* gameNameLabel;
@property (nonatomic, retain) IBOutlet UILabel* chatMessageLabel;

- (void)onResourceChanged:(OFResource*)resource;
- (IBAction)onClickedFeintName;
- (IBAction)onClickedGameName;

@end
