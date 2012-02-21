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
#import "OFSelectChatRoomInstanceController.h"
#import "OFControllerLoader.h"
#import "OFResourceControllerMap.h"
#import "OFChatRoomInstance.h"
#import "OFChatRoomInstanceService.h"
#import "OFChatRoomController.h"
#import "OFDeadEndErrorController.h"
#import "OpenFeint+Private.h"

@implementation OFSelectChatRoomInstanceController

@synthesize preLoadedChatRoomInstances;

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFChatRoomInstance class], @"ChatRoomInstance");
}

- (OFService*)getService
{
	return [OFChatRoomInstanceService sharedInstance];
}

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
	[self showLoadingScreen];
	OFDelegate success(self, @selector(onJoinedRoom));
	OFDelegate failure(self, @selector(onFailedToJoinRoom));
	[OFChatRoomInstanceService attemptToJoinRoom:(OFChatRoomInstance*)cellResource rejoining:NO onSuccess:success onFailure:failure];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	success.invoke(self.preLoadedChatRoomInstances);
}

- (void)onJoinedRoom
{
	[self hideLoadingScreen];
	if (![self isInHiddenTab])
	{
		[OFSelectChatRoomInstanceController pushChatRoom:[OFChatRoomInstanceService getCachedLastRoomJoined] navController:[self navigationController]];
	}
}

- (void)onFailedToJoinRoom
{
	[self hideLoadingScreen];
	
	if (![OpenFeint isShowingErrorScreenInNavController:self.navigationController])
	{
		[OFSelectChatRoomInstanceController pushRoomFullScreen:[self navigationController]];
	}
}

+ (void)pushChatRoom:(OFChatRoomInstance*)chatRoom navController:(UINavigationController*)navController
{
	OFChatRoomController* chatRoomController = (OFChatRoomController*)OFControllerLoader::load(@"ChatRoom");
	chatRoomController.roomInstance = chatRoom;
	[navController pushViewController:chatRoomController animated:YES];
}

+ (void)pushRoomFullScreen:(UINavigationController*)navController
{
	OFDeadEndErrorController* errorScreen = (OFDeadEndErrorController*)OFControllerLoader::load(@"DeadEndError");
	errorScreen.message = @"The room you attempted to join is full. Please try another room.";
	[navController pushViewController:errorScreen animated:YES];
}

- (NSString*)getTableHeaderControllerName
{
	return nil;
}

- (NSString*)getNoDataFoundMessage
{
	return @"There are no available chat room instances";
}

- (void)dealloc
{
	self.preLoadedChatRoomInstances = nil;
	[super dealloc];
}
@end
