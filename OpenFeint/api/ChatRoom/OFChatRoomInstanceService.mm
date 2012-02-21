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
#import "OFChatRoomInstanceService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFChatRoomDefinition.h"
#import "OFChatRoomInstance.h"
#import "OFChatMessageService.h"
#import "OFDelegateChained.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFChatRoomInstanceService);

@implementation OFChatRoomInstanceService

@synthesize lastRoom = mLastRoom;
@synthesize roomJoining = mRoomJoining;
@synthesize rejoiningRoom = mRejoiningRoom;

OPENFEINT_DEFINE_SERVICE(OFChatRoomInstanceService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFChatRoomInstance getResourceName], [OFChatRoomInstance class]);
}

- (CFAbsoluteTime)getTimeSinceLastRoomUpdated
{
	return CFAbsoluteTimeGetCurrent() - mLastUpdateOfLastRoom;
}

+ (void) getPage:(NSInteger)pageIndex forChatRoomDefinition:(OFChatRoomDefinition*)roomDefinition onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> resourceId = roomDefinition.resourceId;
	params->io("chat_room_definition_id", resourceId);
	params->io("page", pageIndex);
	
	
	[[self sharedInstance] 
	 getAction:@"chat_room_instances.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Room Instances"]];
}

+ (void) attemptToJoinRoom:(OFChatRoomInstance*)roomToJoin 
				 rejoining:(BOOL)rejoining  
				 onSuccess:(const OFDelegate&)onSuccess 
				 onFailure:(const OFDelegate&)onFailure
{
	OFDelegate chainedSuccessDelegate([self sharedInstance], @selector(_onJoinedChatRoom:nextCall:), onSuccess);
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	OFRetainedPtr<NSString> resourceId = roomToJoin.resourceId;
	params->io("chat_room_instance_id", resourceId);
	
	[self sharedInstance].roomJoining = roomToJoin;
	[self sharedInstance].rejoiningRoom = rejoining;
	
	[[self sharedInstance] 
	 getAction:@"chat_room_instances/join"
	 withParameters:params
	 withSuccess:chainedSuccessDelegate
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Joined Chat Room"]];
}

+ (void) loadLastRoomJoined:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	CFTimeInterval timeSinceUpdated = [[self sharedInstance]getTimeSinceLastRoomUpdated];
	if (timeSinceUpdated < 10.f)
	{
		onSuccess.invoke([self sharedInstance].lastRoom);
	}
	else
	{
		OFDelegate chainedSuccessDelegate([self sharedInstance], @selector(_onLoadedLastJoinedChatRoom:nextCall:), onSuccess);
		
		[[self sharedInstance] 
		 getAction:@"chat_room_instances/show"
		 withParameters:nil
		 withSuccess:chainedSuccessDelegate
		 withFailure:onFailure
		 withRequestType:OFActionRequestSilent
		 withNotice:nil];
	}
}

+ (OFChatRoomInstance*) getCachedLastRoomJoined
{
	return [self sharedInstance].lastRoom;
}

- (void)_onJoinedChatRoom:(NSObject*)param nextCall:(OFDelegateChained*)nextCall
{
	if (!self.rejoiningRoom)
	{
		[OFChatMessageService clearCacheAndPollNow];
	}
	self.lastRoom = self.roomJoining;
	self.roomJoining = nil;
	self.rejoiningRoom = NO;
	mLastUpdateOfLastRoom = CFAbsoluteTimeGetCurrent();
	[nextCall invokeWith:param];
}

- (void)_onLoadedLastJoinedChatRoom:(NSArray*)roomArray nextCall:(OFDelegateChained*)nextCall
{
	mLastUpdateOfLastRoom = CFAbsoluteTimeGetCurrent();
	if ([roomArray count] == 1)
	{
		self.lastRoom = [roomArray objectAtIndex:0];
	}
	else
	{
		self.lastRoom = nil;
	}
	[nextCall invokeWith:self.lastRoom];
}




@end
