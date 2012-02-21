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

#import "OFMagicDelegate.h"

@implementation OFMagicDelegate

@synthesize actualDelegate, justResponded;

- (id)init
{
	actualDelegate = nil;
	justResponded = NO;
	refCount = 1;	
	return self;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	NSMethodSignature* signature = [[actualDelegate class] instanceMethodSignatureForSelector:selector];

	// returning a dummy signature here avoids the exception
	if (!signature)
	{
		signature = [NSMethodSignature signatureWithObjCTypes:"@"];
	}
	
	justResponded = NO;
	return signature;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	if ([actualDelegate respondsToSelector:[invocation selector]])
	{
		[invocation invokeWithTarget:actualDelegate];
		justResponded = YES;
	}
}

#pragma mark Reference Counting

- (id)retain
{
	refCount++;
	return self;
}

- (oneway void)release
{
	OFAssert(refCount > 0, "OFMagicDelegate ref count underflow");
	refCount--;
	if (refCount == 0)
	{
		[self dealloc];
	}
}

- (id)autorelease
{
	[NSAutoreleasePool addObject:self];
	return self;
}

- (NSUInteger)retainCount
{
	return refCount;
}

@end