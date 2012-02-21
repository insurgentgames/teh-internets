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

#import "OFXmlReader.h"
#import "OFXmlDocument.h"
#include "OFRTTIRepository.h"

OFImplementRTTI(OFXmlReader, OFInputSerializer);

OFXmlReader::OFXmlReader(const char* fileName, StringDecoder decoder)
: mStringDecoder(decoder)
{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:fileName] ofType:@"xml"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		// OFLog(@"OFXmlReader: Expected xml file at path %@. Not Parsing.", filePath);
		return;
	}
	
	mDocument.reset([OFXmlDocument xmlDocumentWithData:[NSData dataWithContentsOfFile:filePath]]);
}

OFXmlReader::OFXmlReader(NSData* data, StringDecoder decoder)
: mStringDecoder(decoder)
{
	mDocument.reset([OFXmlDocument xmlDocumentWithData:data]);
}

OFXmlReader::OFXmlReader(NSString* fullPathName, StringDecoder decoder)
: mStringDecoder(decoder)
{
	mDocument.reset([OFXmlDocument xmlDocumentWithData:[NSData dataWithContentsOfFile:fullPathName]]);
}

bool OFXmlReader::getNextValueAtCurrentScope(OFISerializerKey* keyName, NSString*& outString)
{
	return [mDocument.get() nextValueAtCurrentScopeWithKey:keyName->getAsString() outValue:outString];
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, bool& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString boolValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, int& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString intValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, std::string& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [decodeString(outString).get() UTF8String];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, unsigned int& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString intValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, int64_t& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString longLongValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, double& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString doubleValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, float& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value = [outString floatValue];
	}
}

void OFXmlReader::nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)
{
	NSString* outString;
	const bool isValid = getNextValueAtCurrentScope(keyName, outString);
	if(isValid)
	{
		value.reset(decodeString(outString));
	}
}

void OFXmlReader::onScopePushed(OFISerializerKey* scopeName)
{
	[mDocument.get() pushNextScope:scopeName->getAsString()];
}

void OFXmlReader::onScopePopped(OFISerializerKey* scopeName)
{
	[mDocument.get() popScope];
}

const OFRTTI* OFXmlReader::beginDecodeType()
{
	[mDocument.get() pushNextUnreadScope];
	return OFRTTIRepository::Instance()->getType([[mDocument.get() getCurrentScopeShortName] UTF8String]);
}

void OFXmlReader::endDecodeType()
{
	onScopePopped(NULL);
}

void OFXmlReader::beginEncodeType(const OFRTTI* typeToEncode)
{
	OFAssert(0, "Internal error. An input serializer should not be writing.");
}

void OFXmlReader::endEncodeType()
{
	OFAssert(0, "Internal error. An input serializer should not be writing.");
}

bool OFXmlReader::supportsKeys() const
{
	return true;
}

OFRetainedPtr<NSString> OFXmlReader::decodeString(NSString* stringToDecode)
{
	if(mStringDecoder == NULL)
	{
		return stringToDecode;
	}
	
	return mStringDecoder(stringToDecode);
}