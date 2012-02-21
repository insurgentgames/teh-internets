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

#import "OFTickerProxy.h"
#import "OFTickerService.h"
#import "OFPaginatedSeries.h"
#import "OFResource.h"
#import "OFTicker.h"

#import "OpenFeint+Private.h"

@implementation OFTickerProxy

- (void)_kickTicker
{
	if ([OpenFeint isOnline])
	{
		// @TODO: get more than the first page.  Previous implementation was spamming, so boo to that.
		[OFTickerService getPage:1 onSuccess:OFDelegate(self, @selector(_tickerMessagesRecieved:)) onFailure:OFDelegate()];
	}
}

- (void)getNextMessage:(id)_callbackObj
{
	if (tickerMessages)
	{
		if (currMessageIndex >= tickerMessages.count)
		{
			currMessageIndex = 0;
		}
		
		if (tickerMessages.count)
		{
			NSString* _message = [tickerMessages objectAtIndex:currMessageIndex++];
			[_callbackObj newTickerMessage:_message];
		}
	}
	else
	{
		recipient = _callbackObj;
		[self _kickTicker];
	}
}

- (void)neverMind:(id)_callbackObj
{
	if (_callbackObj == recipient)
	{
		recipient = nil;
	}
}

- (void)_tickerMessagesRecieved:(OFPaginatedSeries*)page
{
	OFSafeRelease(tickerMessages);
	tickerMessages = [[NSMutableArray arrayWithCapacity:page.count] retain];
	for (unsigned int i=0; i<page.count; ++i)
	{
		OFTicker* res = (OFTicker*)[page objectAtIndex:i];
		[tickerMessages addObject:res.message];
	}
	
	if (recipient)
	{
		id<OFTickerProxyRecipient> _recipient = recipient;
		recipient = nil;
		[self getNextMessage:_recipient];		
	}
}

- (void)queueNewMessage:(NSString*)_message
{
	if (!tickerMessages)
	{
		tickerMessages = [[NSMutableArray arrayWithCapacity:10] retain];
	}
	
	[tickerMessages insertObject:_message atIndex:0];
}

+ (OFTickerProxy*)instance
{
	static OFTickerProxy* _singleton = NULL;
	if (!_singleton)
	{
		_singleton = [[OFTickerProxy alloc] init]; // and leak.
	}
	return _singleton;
}

+ (void)getNextMessage:(id<OFTickerProxyRecipient>)_callbackObj
{
	[[self instance] getNextMessage:_callbackObj];
}

+ (void)neverMind:(id<OFTickerProxyRecipient>)_callbackObj
{
	[[self instance] neverMind:_callbackObj];
}

+ (void)queueNewMessage:(NSString*)_message
{
	[[self instance] queueNewMessage:_message];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
