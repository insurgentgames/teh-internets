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

#import "OFImageCache.h"

namespace
{
	static OFImageCache* sInstance = nil;
	static NSInteger const kCacheSize = 50;
}

@implementation OFImageCache

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		mCache = [[NSMutableDictionary dictionaryWithCapacity:kCacheSize] retain];

		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector(purge)
			name:UIApplicationDidReceiveMemoryWarningNotification
			object:nil];

	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

	OFSafeRelease(mCache);
	[super dealloc];
}

+ (void)initializeCache
{
	OFAssert(!sInstance, "Already initialized");
	sInstance = [OFImageCache new];
}

+ (void)shutdownCache
{
	OFSafeRelease(sInstance);
}

+ (OFImageCache*)sharedInstance
{
	OFAssert(sInstance, "Not initialized");
	return sInstance;
}

- (UIImage*)fetch:(NSString*)identifier
{
	return [mCache objectForKey:identifier];
}

- (void)store:(UIImage*)image withIdentifier:(NSString*)identifier
{
	[mCache setObject:image forKey:identifier];
}

- (void)purgeUnreferenced
{
	UIImage* image = nil;
	NSArray* keys = [mCache allKeys];
	for (NSString* key in keys)
	{
		image = [mCache objectForKey:key];
		if ([image retainCount] == 1)
		{
			[mCache removeObjectForKey:key];
		}
	}
}

- (void)purge
{
	[mCache removeAllObjects];
}

@end