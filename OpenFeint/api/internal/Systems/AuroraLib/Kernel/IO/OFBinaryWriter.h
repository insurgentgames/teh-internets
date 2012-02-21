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

class OFBinaryWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFBinaryWriter(const char* filePath);
	~OFBinaryWriter();

	bool supportsKeys() const;
	
private:
	void nviIo(OFISerializerKey* keyName, bool& value)				{ if(mFileStream) fwrite(&value, sizeof(value), 1, mFileStream); } 
	void nviIo(OFISerializerKey* keyName, int& value)				{ if(mFileStream) fwrite(&value, sizeof(value), 1, mFileStream); }
	void nviIo(OFISerializerKey* keyName, unsigned int& value)	{ if(mFileStream) fwrite(&value, sizeof(value), 1, mFileStream); }
	void nviIo(OFISerializerKey* keyName, float& value)			{ if(mFileStream) fwrite(&value, sizeof(value), 1, mFileStream); }
	void nviIo(OFISerializerKey* keyName, double& value)			{ if(mFileStream) fwrite(&value, sizeof(value), 1, mFileStream); }
	void nviIo(OFISerializerKey* keyName, std::string& value)
	{
		if(mFileStream)
		{
			int stringLength = value.length();
			fwrite(&stringLength, sizeof(stringLength), 1, mFileStream);
			fwrite(value.c_str(), stringLength, 1, mFileStream);
		}
	}
		
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)
	{
		if(mFileStream)
		{
			int stringLength = [value.get() length];
			fwrite(&stringLength, sizeof(stringLength), 1, mFileStream);
			NSData* data = [value.get() dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
			fwrite([data bytes], [data length], 1, mFileStream);
		}
	}
	
	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();

	FILE* mFileStream;
};