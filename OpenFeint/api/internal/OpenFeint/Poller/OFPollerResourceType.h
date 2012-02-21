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

@class OFResource;

@interface OFPollerResourceType : NSObject
{
@private
	NSMutableArray* mNewResources;
	long long mLastSeenId;
	NSString* mName;
	NSString* mIdParameterName;
	NSString* mDiscoveryNotification;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) long long lastSeenId;
@property (nonatomic, retain) NSString* idParameterName;
@property (nonatomic, retain) NSString* discoveryNotification;
@property (nonatomic, retain) NSArray* newResources;

- (id)initWithName:(NSString*)name andDiscoveryNotification:(NSString*)discoveryNotification;
- (void)addResource:(OFResource*)resource;
- (void)markNewResourcesOld;
- (void)clearLastSeenId;
- (void)forceLastSeenId:(long long)lastSeenId;

@end