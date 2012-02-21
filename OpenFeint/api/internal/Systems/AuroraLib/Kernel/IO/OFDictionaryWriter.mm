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

#include "OFDictionaryWriter.h"

OFImplementRTTI(OFDictionaryWriter, OFOutputSerializer);

OFDictionaryWriter::OFDictionaryWriter()
{
	mDictionary.reset([NSMutableDictionary dictionary]);
}

OFDictionaryWriter::~OFDictionaryWriter()
{
}

bool OFDictionaryWriter::supportsKeys() const
{
	return true;
}

NSDictionary* OFDictionaryWriter::getDictionary() const
{
	return mDictionary.get();
}

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, bool& value)	
{ [mDictionary.get() setValue:[NSNumber numberWithBool:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, int& value)
{ [mDictionary.get() setValue:[NSNumber numberWithInt:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, unsigned int& value)
{ [mDictionary.get() setValue:[NSNumber numberWithUnsignedInt:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, int64_t& value)
{ [mDictionary.get() setValue:[NSNumber numberWithLongLong:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, float& value)
{ [mDictionary.get() setValue:[NSNumber numberWithFloat:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, double& value)
{ [mDictionary.get() setValue:[NSNumber numberWithDouble:value] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, std::string& value)
{ [mDictionary.get() setValue:[NSString stringWithUTF8String:value.c_str()] forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }

void OFDictionaryWriter::nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)
{ [mDictionary.get() setValue:value.get() forKey:[NSString stringWithUTF8String:keyName->getAsString()]]; }
	
const OFRTTI* OFDictionaryWriter::beginDecodeType() { return NULL; }
void OFDictionaryWriter::endDecodeType() {}
void OFDictionaryWriter::beginEncodeType(const OFRTTI* typeToEncode) {}
void OFDictionaryWriter::endEncodeType() {}