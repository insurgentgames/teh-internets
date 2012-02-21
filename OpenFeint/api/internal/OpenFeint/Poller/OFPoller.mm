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
#import "OFPoller.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFProviderProtocol.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFResource.h"
#import "OFXmlDocument.h"
#import "OFPollerResourceType.h"
#import <objc/runtime.h>
#import "OFHttpNestedQueryStringWriter.h"
#import "OFTimerHeartbeat.h"
#import "OpenFeint+Private.h"
#import "OpenFeint+Settings.h"
#import "OFPaginatedSeries.h"

NSString* OFPollerNotificationKeyForResources = @"OFPollerNotificationKeyResources";

@implementation OFPoller

- (id)initWithProvider:(NSObject<OFProviderProtocol>*)provider sourceUrl:(NSString*)sourceUrl;
{
	self = [super init];
	if (self != nil)
	{
		mProvider = [provider retain];
		mChronologicalResourceTypes = [[NSMutableDictionary dictionary] retain];
		mSourceUrl = [sourceUrl retain];
	}
	return self;
}

- (void) dealloc
{
	[mHeartbeat invalidate];
	[mHeartbeat release];
	[mChronologicalResourceTypes release];
	[mProvider release];
	[mSourceUrl release];
	[super dealloc];
}

- (Class)getRegisteredResourceClassWithName:(NSString*)resourceName
{
	return mRegisteredResources.getTypeNamed(resourceName);
}

- (void)resetToDefaultPollingFrequency
{
	NSUInteger defaultPollingFrequency = [OpenFeint getPollingFrequencyDefault];
	[self changePollingFrequency:defaultPollingFrequency];
}

- (void)changePollingFrequency:(NSTimeInterval)pollingFrequency
{
	[self stopPolling];
	
	if(pollingFrequency == 0.0f)
	{
		return;
	}
	
	mHeartbeat = [[OFTimerHeartbeat scheduledTimerWithInterval:pollingFrequency target:self selector:@selector(pollNow)] retain];
	OFLog(@"Polling every %f seconds", pollingFrequency);
}

- (void)stopPolling
{
	[mHeartbeat invalidate];
	[mHeartbeat release];
	mHeartbeat = nil;
	OFLog(@"Stopped polling");
}

- (void)registerResourceClass:(Class)resourceClassType;
{	
	if(![resourceClassType isSubclassOfClass:[OFResource class]])
	{
		NSAssert1(0, @"'%s' must derive from OFResource to be work with the Polling system.", class_getName(resourceClassType));
		return;
	}
	
	NSString* name = [resourceClassType performSelector:@selector(getResourceName)];
	NSString* notificationName = [resourceClassType performSelector:@selector(getResourceDiscoveredNotification)];
		
	mRegisteredResources.addResource(name, resourceClassType);
	
	OFPollerResourceType* resourceType = [[[OFPollerResourceType alloc] initWithName:name andDiscoveryNotification:notificationName] autorelease];
	[mChronologicalResourceTypes setObject:resourceType forKey:resourceClassType];
}

- (void)clearCacheForResourceClass:(Class)resourceClassType
{
	OFPollerResourceType* resourceType = [mChronologicalResourceTypes objectForKey:resourceClassType];
	[resourceType markNewResourcesOld];
	[resourceType clearLastSeenId];
}

- (void)clearCacheAndForceLastSeenId:(long long)lastSeenId forResourceClass:(Class)resourceClassType
{
	OFPollerResourceType* resourceType = [mChronologicalResourceTypes objectForKey:resourceClassType];
	[resourceType markNewResourcesOld];
	[resourceType forceLastSeenId:lastSeenId];
}

- (void)_onPollComplete
{
	mInPoll = false;
	if (mQueuedPoll)
	{
		mQueuedPoll = false;
		[self pollNow];
	}
}

- (void)_onSucceededDownloading:(MPOAuthAPIRequestLoader*)request
{
	OFPaginatedSeries* incomingResources = [OFResource resourcesFromXml:[OFXmlDocument xmlDocumentWithData:request.data] withMap:&mRegisteredResources];
	
	NSMutableSet* incomingTypes = [NSMutableSet set];
	for(OFResource* currentResource in incomingResources.objects)
	{
		OFPollerResourceType* resourceType = [mChronologicalResourceTypes objectForKey:[currentResource class]];
		[resourceType addResource:currentResource];
		[incomingTypes addObject:resourceType];
	}

	for(OFPollerResourceType* resourceType in incomingTypes)
	{
		NSDictionary* resourcesDictionary = [NSDictionary dictionaryWithObject:resourceType.newResources forKey:OFPollerNotificationKeyForResources];
		[[NSNotificationCenter defaultCenter] postNotificationName:resourceType.discoveryNotification object:nil userInfo:resourcesDictionary];
		[resourceType markNewResourcesOld];
	}
	[self _onPollComplete];
}

- (void)_onFailedDownloading
{
	[self _onPollComplete];
}

- (void)pollNow
{		
	if(![mProvider isAuthenticated])
	{
		return;
	}
	
	if (mInPoll)
	{
		mQueuedPoll = true;
		return;
	}
	
	mQueuedPoll = false;
	mInPoll = true;
	
	OFLog(@"Polling Now");
	
	OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
	for(Class resourceClass in mChronologicalResourceTypes)
	{
		OFPollerResourceType* resourceType = [mChronologicalResourceTypes objectForKey:resourceClass];
		OFRetainedPtr<NSString> theId = [[NSNumber numberWithLongLong:resourceType.lastSeenId] stringValue];
		params->io([resourceType.idParameterName UTF8String], theId);
	}
	
	[mProvider performAction:mSourceUrl
			  withParameters:params->getQueryParametersAsMPURLRequestParameters()
			  withHttpMethod:@"GET"
			     withSuccess:OFDelegate(self, @selector(_onSucceededDownloading:))
				 withFailure:OFDelegate(self, @selector(_onFailedDownloading))
				withRequestType:OFActionRequestSilent
				  withNotice:nil];
}

- (NSTimeInterval)getPollingFrequency
{
	return mHeartbeat.timeInterval;
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
