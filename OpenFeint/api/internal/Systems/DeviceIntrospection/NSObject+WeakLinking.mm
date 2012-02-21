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
#import "NSObject+WeakLinking.h"
#import <objc/runtime.h>

@implementation NSObject (WeakLinking)

- (SEL)findSelectorForProperty:(objc_property_t)property named:(NSString*)name forReading:(bool)findGetter 
{
	const char* attributeString = property_getAttributes(property);
	
	char customPropertyToken;
	if(findGetter)
	{
		customPropertyToken = 'G';
	}
	else
	{
		customPropertyToken = 'S';
	}

	SEL foundSelector = nil;
	
	NSArray* attributes = [[NSString stringWithUTF8String:attributeString] componentsSeparatedByString:@","];
	for(NSString* attribute in attributes)
	{
		if([attribute characterAtIndex:0] == customPropertyToken)
		{
			 foundSelector = sel_registerName([[attribute substringFromIndex:1] UTF8String]);
		}
	}

	if(!foundSelector)
	{
		NSString* selectorName = nil;
		if(findGetter)
		{
			selectorName = name;
		}
		else
		{
			selectorName = [NSString stringWithFormat:@"set%@%@:", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
		}
	
		foundSelector = sel_registerName([selectorName UTF8String]);
	}
	
	if(![self respondsToSelector:foundSelector])
	{
		foundSelector = nil;
	}
	
	return foundSelector;;
}

- (SEL)findSelectorForPropertyNamed:(NSString*)propertyName forReading:(bool)forReading
{
	objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
	if(!property)
	{
		return NULL;
	}
	
	SEL discoveredSelector = [self findSelectorForProperty:property named:propertyName forReading:forReading];
	if(!discoveredSelector)
	{
		return NULL;
	}
	
	return discoveredSelector;
}

- (bool)tryGet:(NSString*)dottedProperty outObject:(id*)outObject
{
	NSArray* propertyNames = [dottedProperty componentsSeparatedByString:@"."];
	
	const unsigned int numProperties = [propertyNames count];
	id returnedObject = self;	
	for(unsigned int i = 0; i < numProperties; ++i)
	{
		SEL discoveredGetter = [returnedObject findSelectorForPropertyNamed:[propertyNames objectAtIndex:i] forReading:true];
		if(!discoveredGetter)
		{
			return false;
		}
		
		returnedObject = [returnedObject performSelector:discoveredGetter];
	}

	*outObject = returnedObject;
	return true;
}

- (bool)trySet:(NSString*)dottedProperty withValue:(id)value
{
	NSArray* propertyNames = [dottedProperty componentsSeparatedByString:@"."];	
	id objectToSet = self;
	const unsigned int numProperties = [propertyNames count];

	if(numProperties > 1)
	{
		NSMutableString* dottedGetterProperty = [NSMutableString stringWithString:[propertyNames objectAtIndex:0]];
		{
			for(unsigned int i = 1; i < numProperties - 1; ++i)
			{
				[dottedGetterProperty appendFormat:@".%@", [propertyNames objectAtIndex:i]];
			}
		}
	
		if(!([self tryGet:dottedGetterProperty outObject:&objectToSet] && objectToSet))
		{
			return false;
		}
	}
	
	SEL discoveredSetter = [objectToSet findSelectorForPropertyNamed:[propertyNames lastObject] forReading:false];
	if(!discoveredSetter)
	{
		return false;
	}
	
	[objectToSet performSelector:discoveredSetter withObject:value];	
	return true;	
}


- (id)tryGet:(NSString*)firstDottedProperty elseGet:(NSString*)elseDottedProperty
{
	id value = nil;
	if(![self tryGet:firstDottedProperty outObject:&value])
	{
		if(![self tryGet:elseDottedProperty outObject:&value])
		{
		}
	}
	return value;
}

- (void)trySet:(NSString*)firstDottedProperty with:(id)firstValue elseSet:(NSString*)elseDottedProperty with:(id)secondValue
{
	if(![self trySet:firstDottedProperty withValue:firstValue])
	{
		if(![self trySet:elseDottedProperty withValue:secondValue])
		{
		}
	}
}

- (void)trySet:(NSString*)firstDottedProperty elseSet:(NSString*)elseDottedProperty with:(id)value
{
	[self trySet:firstDottedProperty with:value elseSet:elseDottedProperty with:value];
}

@end
