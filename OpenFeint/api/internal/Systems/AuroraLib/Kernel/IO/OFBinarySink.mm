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

#include "OFBinarySink.h"

OFImplementRTTI(OFBinarySink, OFSmartObject);
OFImplementRTTI(OFBinaryFileSink, OFBinaryMemorySink);
OFImplementRTTI(OFBinaryMemorySink, OFBinaryMemorySink);

OFBinaryFileSink::OFBinaryFileSink(const char* filePath)
{
	mFileStream = fopen(filePath, "wb+");		
}

OFBinaryFileSink::~OFBinaryFileSink()
{
	fclose(mFileStream);
	mFileStream = NULL;
}
	
void OFBinaryFileSink::write(const void* data, unsigned int dataSize)
{
	fwrite(data, dataSize, 1, mFileStream);
}	

OFBinaryMemorySink::OFBinaryMemorySink()
{
}

OFBinaryMemorySink::OFBinaryMemorySink(NSData* data)
: mData(data)
{
}

OFBinaryMemorySink::~OFBinaryMemorySink()
{
}
	
const void* OFBinaryMemorySink::getDataBuffer() const
{
	return [mData.get() bytes];
}

NSData* OFBinaryMemorySink::getNSData() const
{
	return mData.get();
}
	
void OFBinaryMemorySink::write(const void* data, unsigned int dataSize)
{
	mData = [NSData dataWithBytes:data length:dataSize];
}

unsigned int OFBinaryMemorySink::getDataSize() const
{
	return [mData.get() length];
}