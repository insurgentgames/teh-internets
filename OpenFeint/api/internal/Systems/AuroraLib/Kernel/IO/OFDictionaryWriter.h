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

#pragma once

#include "OFOutputSerializer.h"
#include <cstdio>

class OFDictionaryWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFDictionaryWriter();
	~OFDictionaryWriter();

	bool supportsKeys() const;
	
	NSDictionary* getDictionary() const;
	
private:
	void nviIo(OFISerializerKey* keyName, bool& value);
	void nviIo(OFISerializerKey* keyName, int& value);
	void nviIo(OFISerializerKey* keyName, unsigned int& value);
	void nviIo(OFISerializerKey* keyName, int64_t& value);	
	void nviIo(OFISerializerKey* keyName, float& value);
	void nviIo(OFISerializerKey* keyName, double& value);
	void nviIo(OFISerializerKey* keyName, std::string& value);
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value);
		
	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();

	OFRetainedPtr<NSMutableDictionary> mDictionary;
};