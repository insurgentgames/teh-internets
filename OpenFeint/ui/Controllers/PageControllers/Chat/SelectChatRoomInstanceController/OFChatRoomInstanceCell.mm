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

#import "OFDependencies.h"
#import "OFChatRoomInstanceCell.h"
#import "OFChatRoomDefinitionCell.h"
#import "OFViewHelper.h"
#import "OFChatRoomInstance.h"

@implementation OFChatRoomInstanceCell

- (void)onResourceChanged:(OFResource*)resource
{
	OFChatRoomInstance* chatRoomInstance = (OFChatRoomInstance*)resource;
	
	BOOL roomFull = chatRoomInstance.numUsersInRoom == chatRoomInstance.maxNumUsersInRoom;
	
	UILabel* nameLabel = (UILabel*)OFViewHelper::findViewByTag(self, 1);
	nameLabel.text = chatRoomInstance.roomName;
	
	UILabel* numUsersLabel = (UILabel*)OFViewHelper::findViewByTag(self, 2);
	numUsersLabel.text = [NSString stringWithFormat:@"%d/%d", chatRoomInstance.numUsersInRoom, chatRoomInstance.maxNumUsersInRoom];
	if (roomFull)
	{
		numUsersLabel.textColor = [UIColor redColor];
	}
	else
	{
		const float grayNameColor = 0.278f;
		numUsersLabel.textColor = [UIColor colorWithRed:grayNameColor green:grayNameColor blue:grayNameColor alpha:1.0f];
	}
	
	UIImageView* typeIcon = (UIImageView*)OFViewHelper::findViewByTag(self, 4);
	typeIcon.image = [OFChatRoomDefinitionCell getChatIconForChatType:chatRoomInstance.roomType full:roomFull];
}

@end
