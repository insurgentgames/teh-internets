//  Copyright 2009-2010 Aurora Feint, Inc.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  	http://www.apache.org/licenses/LICENSE-2.0
//  	
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "OFRequestHandle.h"

#import "OpenFeint+Private.h"
#import "OFProvider.h"

@interface OFRequestHandle ()
////////////////////////////////////////////////////////////
/// @internal
/// Designated initializer
/// Initializes the OFRequestHandle with it's wrapped request.
/// @param request The API request that this OFRequestHandle is wrapping
////////////////////////////////////////////////////////////
- (id)initWithRequest:(id)request;
@end

@implementation OFRequestHandle

+ (OFRequestHandle*)requestHandle:(id)request
{
	return [[[OFRequestHandle alloc] initWithRequest:request] autorelease];
}

- (id)initWithRequest:(id)request
{
	self = [super init];
	if (self)
	{
		_request = request;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)cancel
{
	[[OpenFeint provider] cancelRequest:_request];
}

@end
