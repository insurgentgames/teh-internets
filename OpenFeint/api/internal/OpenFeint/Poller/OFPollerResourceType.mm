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
#import "OFPollerResourceType.h"
#import "OFResource.h"

@implementation OFPollerResourceType

@synthesize lastSeenId = mLastSeenId;
@synthesize name = mName;
@synthesize idParameterName = mIdParameterName;
@synthesize discoveryNotification = mDiscoveryNotification;
@synthesize newResources = mNewResources;

- (id)initWithName:(NSString*)name andDiscoveryNotification:(NSString*)discoveryNotification
{
	self = [super init];
	if (self != nil)
	{
		self.name = name;
		self.idParameterName = [NSString stringWithFormat:@"last_seen_%@_id", self.name];
		self.discoveryNotification = discoveryNotification;
		self.newResources = [NSMutableArray array];		
	}
	return self;
}

- (void) dealloc
{
	self.newResources = nil;
	self.discoveryNotification = nil;
	self.name = nil;
	self.idParameterName = nil;
	[super dealloc];
}

- (void)addResource:(OFResource*)resource
{
	long long resourceId = [resource.resourceId longLongValue];

	if(resourceId > mLastSeenId)
	{
		mLastSeenId = resourceId;
	}
	
	[mNewResources addObject:resource];
}

- (void)markNewResourcesOld
{
	[mNewResources removeAllObjects];
}

- (void)clearLastSeenId
{
	mLastSeenId = 0;
}

- (void)forceLastSeenId:(long long)lastSeenId
{
	mLastSeenId = lastSeenId;
}

@end