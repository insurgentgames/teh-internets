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
#import "OFChatRoomDefinitionService.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFService+Private.h"
#import "OFChatRoomDefinition.h"
#import "OFChatRoomInstance.h"

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFChatRoomDefinitionService);

@implementation OFChatRoomDefinitionService

OPENFEINT_DEFINE_SERVICE(OFChatRoomDefinitionService);

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFChatRoomDefinition getResourceName], [OFChatRoomDefinition class]);
	namedResources->addResource([OFChatRoomInstance getResourceName], [OFChatRoomInstance class]);
}

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	[OFChatRoomDefinitionService getPage:1 includeGlobalRooms:true includeDeveloperRooms:true includeApplicationRooms:true includeLastVisitedRoom:YES onSuccess:onSuccess onFailure:onFailure];
}

+ (void) getPage:(NSInteger)pageIndex 
includeGlobalRooms:(bool)includeGlobalRooms 
includeDeveloperRooms:(bool)includeDeveloperRooms 
includeApplicationRooms:(bool)includeApplicationRooms 
includeLastVisitedRoom:(bool)includeLastVisitedRoom
	   onSuccess:(const OFDelegate&)onSuccess 
	   onFailure:(const OFDelegate&)onFailure
{
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	params->io("include_global_rooms", includeGlobalRooms);
	params->io("include_application_rooms", includeApplicationRooms);
	params->io("include_developer_rooms", includeDeveloperRooms);
	params->io("include_last_visited_room", includeLastVisitedRoom);
	
	[[self sharedInstance] 
	 getAction:@"chat_room_definitions.xml"
	 withParameters:params
	 withSuccess:onSuccess
	 withFailure:onFailure
	 withRequestType:OFActionRequestForeground
	 withNotice:[OFNotificationData foreGroundDataWithText:@"Downloaded Chat Rooms"]];
}

@end
