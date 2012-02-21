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

#import "OFResource.h"

@class OFService;
@class OFUser;

@interface OFChatMessage : OFResource
{
@package
	NSString* message;
	NSString* date;
	NSString* playerCurrentGameIconUrl;
	BOOL doesLocalPlayerOwnGame;
	OFUser* user;
}

+ (OFResourceDataMap*)getDataMap;
+ (OFService*)getService;
+ (NSString*)getResourceName;
+ (NSString*)getResourceDiscoveredNotification;

@property (nonatomic, readonly) NSString* message;
@property (nonatomic, readonly) NSString* date;
@property (nonatomic, readonly) NSString* playerCurrentGameIconUrl;
@property (nonatomic, readonly) BOOL doesLocalPlayerOwnGame;
@property (nonatomic, readonly) OFUser* user;

@end