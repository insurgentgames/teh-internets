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

class OFBinarySource : public OFSmartObject
{
OFDeclareRTTI;
OFDeclareNonCopyable(OFBinarySource);
public:
	OFBinarySource() {}
	
	virtual void read(void* data, unsigned int dataSize) = 0;
	virtual bool isEmpty() const = 0;
};

class OFBinaryFileSource : public OFBinarySource
{
OFDeclareRTTI;
public:
	OFBinaryFileSource(const char* filePath);
	~OFBinaryFileSource();
	
	void read(void* data, unsigned int dataSize);
	bool isEmpty() const;
		
private:
	FILE* mFileStream;
};

class OFBinaryMemorySource : public OFBinarySource
{
OFDeclareRTTI;
public:
	OFBinaryMemorySource(const char* data, unsigned int dataSize);
	~OFBinaryMemorySource();
	
	void read(void* data, unsigned int dataSize);
	bool isEmpty() const;
	
private:
	const char* const mData;
	const unsigned int mNumBytes;
	unsigned int mNextByte;
};