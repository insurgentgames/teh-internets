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

class OFBinarySink : public OFSmartObject
{
OFDeclareRTTI;
OFDeclareNonCopyable(OFBinarySink);
public:
	OFBinarySink() {}
	
	virtual void write(const void* data, unsigned int dataSize) = 0;
};

class OFBinaryFileSink : public OFBinarySink
{
OFDeclareRTTI;
public:
	OFBinaryFileSink(const char* filePath);
	~OFBinaryFileSink();
	
	void write(const void* data, unsigned int dataSize);
	
private:
	FILE* mFileStream;
};

class OFBinaryMemorySink : public OFBinarySink
{
OFDeclareRTTI;
public:
	OFBinaryMemorySink();
	OFBinaryMemorySink(NSData* data);
	~OFBinaryMemorySink();
	
	const void* getDataBuffer() const;
	NSData* getNSData() const;
	unsigned int getDataSize() const;
	
	void write(const void* data, unsigned int dataSize);

private:
	OFRetainedPtr<NSData> mData;
};