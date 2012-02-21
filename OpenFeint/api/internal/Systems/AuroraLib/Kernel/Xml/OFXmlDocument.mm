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

#import "OFXmlDocument.h"
#import "OFXmlElement.h"

#include "parsifal.h"

#pragma mark Internal Interface

@interface OFXmlDocument ()
- (void)elementStarted:(OFXmlElement*)element;
- (void)elementEnded;
- (OFXmlElement*)activeElement;
@end

#pragma mark Parsifal SAX Callbacks

int StartElement(void* userdata, XMLCH const* uri, XMLCH const* localname, XMLCH const* qname, LPXMLVECTOR attributes)
{
	NSString* elementName = [NSString stringWithUTF8String:(char const*)qname];
	OFPointer<OFXmlElement> newElement(new OFXmlElement(elementName));
	
	if (attributes->length > 0)
	{
		LPXMLRUNTIMEATT attribute = NULL;
		NSMutableDictionary* attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:attributes->length];
		
		int i = 0;
		for (; i < attributes->length; ++i)
		{
			attribute = (LPXMLRUNTIMEATT)XMLVector_Get(attributes, i);
			[attributeDictionary 
				setObject:[NSString stringWithUTF8String:(char const*)attribute->qname] 
				forKey:[NSString stringWithUTF8String:(char const*)attribute->value]];
		}
		
		newElement->setAttributes(attributeDictionary);
	}

	[(OFXmlDocument*)userdata elementStarted:newElement];
	return XML_OK;
}

int EndElement(void* userdata, XMLCH const* uri, XMLCH const* localname, XMLCH const* qname)
{
	[(OFXmlDocument*)userdata elementEnded];
	return XML_OK;
}

int CharactersFound(void* userdata, XMLCH const* characters, int numCharacters)
{
	OFXmlElement* element = [(OFXmlDocument*)userdata activeElement];

	NSString* value = [[[NSString alloc] initWithBytes:(void const*)characters length:numCharacters encoding:NSUTF8StringEncoding] autorelease];
	if (element->hasValue())
	{
		value = [element->getValue() stringByAppendingString:value];
	}
	
	element->setValue(value);
	return XML_OK;
}

void ParsingError(LPXMLPARSER parser)
{
	OFLog(@"Error parsing XML: %s", parser->ErrorString);
}

#pragma mark Parsifal Input Callback

typedef struct
{
	NSData* data;
	unsigned int offset;
} ParsifalInputData;

int ParsifalInputCallback(BYTE *buf, int cBytes, int *cBytesActual, void *inputData)
{
	ParsifalInputData* data = (ParsifalInputData*)inputData;
	
	unsigned int desiredBytes = (unsigned int)cBytes;
	
	unsigned char* bytes = (unsigned char*)[data->data bytes];
	unsigned int length = [data->data length];
	
	unsigned int consumedBytes = MIN((length - data->offset), desiredBytes);
	memcpy(buf, bytes + data->offset, consumedBytes);
	
	data->offset += consumedBytes;
	(*cBytesActual) = consumedBytes;
	return consumedBytes < desiredBytes;
}

@implementation OFXmlDocument

#pragma mark Creation

+ (id)xmlDocumentWithData:(NSData*)data
{
	return [[[OFXmlDocument alloc] initWithData:data] autorelease];
}

+ (id)xmlDocumentWithString:(NSString*)str
{
	return [OFXmlDocument xmlDocumentWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithData:(NSData*)data
{
	self = [super init];
	if(self)
	{
		OFPointer<OFXmlElement> sentinel(new OFXmlElement(@"root"));
		mActiveElements.push_back(sentinel);

		LPXMLPARSER parser = NULL;
		XMLParser_Create(&parser);
		
		parser->startElementHandler = StartElement;
		parser->endElementHandler = EndElement;
		parser->charactersHandler = CharactersFound;
		parser->errorHandler = ParsingError;	
		parser->UserData = self;
		
		ParsifalInputData inputData;
		inputData.data = data;
		inputData.offset = 0;
	
		XMLParser_Parse(parser, ParsifalInputCallback, &inputData, NULL);
		
		XMLParser_Free(parser);
		
		if (sentinel->hasChildren())
		{
			mDocumentRoot = sentinel->getChildAt(0);
		}
	}

	return self;
}

#pragma mark Document Traversal Methods

- (NSString*)getElementValue:(const char*)targetElementFullName
{
	NSArray* elementPath = [[NSString stringWithUTF8String:targetElementFullName] componentsSeparatedByString:@"."];
	OFXmlElement* currentNode = mDocumentRoot.get();
	
	if(currentNode)
	{
		const unsigned int numElementsInPath = [elementPath count];
		
		for(unsigned int i = 1; i < numElementsInPath; ++i)
		{
			NSString* currentName = [elementPath objectAtIndex:i];
			
			currentNode = currentNode->getChildWithName(currentName);
			if(currentNode == NULL)
			{
				break;
			}
		}
		
		if(currentNode)
		{
			return currentNode->getValue();
		}
	}
		
	return @"";
}

- (OFPointer<OFXmlElement>)readNextElement
{
	if(mActiveElements.back())
	{
		return mActiveElements.back()->dequeueNextUnreadChild();
	}
	
	return NULL;
}

- (void)pushNextScope:(const char*)scopeName
{	
	OFPointer<OFXmlElement> child;

	if(mActiveElements.size() == 0)
	{
		child = mDocumentRoot;
	}
	else if(mActiveElements.back().get() != NULL)
	{
		child = mActiveElements.back()->dequeueNextUnreadChild(scopeName);
	}
	 
	mActiveElements.push_back(child);
}

- (void)popScope
{
	mActiveElements.pop_back();
}

- (void)pushNextUnreadScope
{
	if(mActiveElements.back().get() != NULL)
	{
		mActiveElements.push_back(mActiveElements.back()->dequeueNextUnreadChild());
	}
}

- (bool)pushNextUnreadScopeWithNameIfAvailable:(const char*)scopeName
{
	if(mActiveElements.back().get() != NULL)
	{
		OFPointer<OFXmlElement> nextElement = mActiveElements.back()->dequeueNextUnreadChild(scopeName);		
		if(nextElement.get())
		{
			mActiveElements.push_back(nextElement);
			return true;
		}
	}
	
	return false;
}

- (NSString*)getCurrentScopeShortName
{
	if(mActiveElements.empty())
	{
		return @"";
	}
	
	return mActiveElements.back()->getName();
}

- (bool)nextValueAtCurrentScopeWithKey:(const char*)keyName outValue:(NSString*&)outString
{
	if(mActiveElements.back().get() != NULL)
	{
		const bool isValid = mActiveElements.back()->getValueWithName(keyName, outString, true);
		return isValid;
	}
	else
	{
		return false;
	}
}

#pragma mark Internal Parsing Methods

- (void)elementStarted:(OFXmlElement*)element
{
	mActiveElements.back()->addChild(element);
	mActiveElements.push_back(element);
}

- (void)elementEnded
{
	OFXmlElement* element = mActiveElements.back().get();
	
	if (element->hasNilValue())
		element->setValue(@"");
	
	mActiveElements.pop_back();
}

- (OFXmlElement*)activeElement
{
	return mActiveElements.back().get();
}

@end
