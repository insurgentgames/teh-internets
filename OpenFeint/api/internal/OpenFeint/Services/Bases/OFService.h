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

#import "OFCallbackable.h"
#import "OFPointer.h"
#import "OFResourceNameMap.h"
#import "OFDelegate.h"
#import "OFRequestHandle.h"

@interface OFService : NSObject<OFCallbackable>
{
@private
	OFPointer<OFResourceNameMap> mKnownResources;
}

- (bool) canReceiveCallbacksNow;
- (OFResourceNameMap*) getKnownResources;

@end

#define OPENFEINT_DECLARE_AS_SERVICE(interfaceName) \
+ (interfaceName*)sharedInstance;					\
+ (void)initializeService;							\
+ (void)shutdownService;

#define OPENFEINT_DEFINE_SERVICE_INSTANCE(interfaceName)	\
namespace													\
{															\
	static interfaceName* interfaceName##Instance = nil;	\
}

#define OPENFEINT_DEFINE_SERVICE(interfaceName)									\
+ (interfaceName*)sharedInstance												\
{																				\
	return interfaceName##Instance;												\
}																				\
																				\
+ (void)initializeService														\
{																				\
	if (interfaceName##Instance == nil)											\
	{																			\
		interfaceName##Instance = [interfaceName new];							\
	}																			\
}																				\
																				\
+ (void)shutdownService															\
{																				\
	int retainCount = [interfaceName##Instance retainCount];					\
	if (retainCount > 1)														\
	{																			\
		OFLog(@#interfaceName " has outstanding references during shutdown!");	\
	}																			\
																				\
	[interfaceName##Instance release];											\
	interfaceName##Instance = nil;												\
}
