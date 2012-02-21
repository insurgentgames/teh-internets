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

#import "OFKeyValuePair.h"

@implementation OFKeyValuePair

@synthesize key;
@synthesize value;

+ (OFKeyValuePair*)pairWithKey:(NSString*)key andValue:(NSObject*)value
{
	return [[[OFKeyValuePair alloc] initWithKey:key andValue:value] autorelease];
}
- (id)init
{
	return [self initWithKey:nil andValue:nil];
}

- (id)initWithKey:(NSString*)_key andValue:(NSObject*)_value
{
	self = [super init];
	if (self)
	{
		self.key = _key;
		self.value = _value;
	}
	return self;
}

- (void)dealloc
{
	self.key = nil;
	self.value = nil;
	[super dealloc];
}

@end

