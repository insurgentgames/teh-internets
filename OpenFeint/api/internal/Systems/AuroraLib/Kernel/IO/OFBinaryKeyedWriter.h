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
#include "OFBinarySink.h"

class OFBinaryKeyedWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFBinaryKeyedWriter(const char* filePath, bool serializeResourcesExternally = true);
	OFBinaryKeyedWriter(OFPointer<OFBinarySink> dataSink, bool serializeResourcesExternally = true);

	~OFBinaryKeyedWriter();

	bool supportsKeys() const;

	OFPointer<OFBinarySink> getDataSink() const;

protected:
	OFBinaryKeyedWriter(bool serializeResourcesExternally);
	void initialize(OFPointer<OFBinarySink> dataSink);
	
private:
	void nviIo(OFISerializerKey* keyName, bool& value)			{ writeData(keyName, sizeof(bool), &value); } 
	void nviIo(OFISerializerKey* keyName, int& value)				{ writeData(keyName, sizeof(int), &value); }
	void nviIo(OFISerializerKey* keyName, unsigned int& value)	{ writeData(keyName, sizeof(unsigned int), &value); }
	void nviIo(OFISerializerKey* keyName, int64_t& value)			{ writeData(keyName, sizeof(int64_t), &value); }
	void nviIo(OFISerializerKey* keyName, float& value)			{ writeData(keyName, sizeof(float), &value); }
	void nviIo(OFISerializerKey* keyName, double& value)			{ writeData(keyName, sizeof(double), &value); }
	void nviIo(OFISerializerKey* keyName, std::string& value)
	{
		uint32_t len = value.length();
		char const* cStr = value.c_str();
		writeData(keyName, len, cStr);
	}
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)
	{
		NSData* data = [value.get() dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
		writeData(keyName, [data length], [data bytes]);
	}
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSData>& value)
	{
		OFAssert(false, @"Writing NSData Not Implemented In OFBinaryKeyedWrited");
	}
	
	void doCommonConstruction(OFPointer<OFBinarySink> dataSink, bool serializeResourcesExternally);

	void writeData(OFISerializerKey* keyName, unsigned int dataSize, const void* data);
	virtual void writeKey(OFISerializerKey* scopeName);
	
	void onScopePushed(OFISerializerKey* scopeName);
	void onScopePopped(OFISerializerKey* scopeName);
		
	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();
	
	OFPointer<OFBinarySink> mDataSink;
};