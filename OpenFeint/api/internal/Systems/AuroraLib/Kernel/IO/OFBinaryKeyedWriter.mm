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

#include "OFBinaryKeyedWriter.h"
#include "OFBinaryKeyed.h"

OFImplementRTTI(OFBinaryKeyedWriter, OFOutputSerializer);

OFBinaryKeyedWriter::OFBinaryKeyedWriter(bool serializeResourcesExternally)
{
	setSerializeResourcesExternally(serializeResourcesExternally);
}

OFBinaryKeyedWriter::OFBinaryKeyedWriter(const char* filePath, bool serializeResourcesExternally)
{
	doCommonConstruction(new OFBinaryFileSink(filePath), serializeResourcesExternally);
}
	
OFBinaryKeyedWriter::OFBinaryKeyedWriter(OFPointer<OFBinarySink> dataSink, bool serializeResourcesExternally)
{
	doCommonConstruction(dataSink, serializeResourcesExternally);
}

void OFBinaryKeyedWriter::doCommonConstruction(OFPointer<OFBinarySink> dataSink, bool serializeResourcesExternally)
{
	setSerializeResourcesExternally(serializeResourcesExternally);	
	initialize(dataSink);
}

void OFBinaryKeyedWriter::initialize(OFPointer<OFBinarySink> dataSink)
{
	mDataSink = dataSink;
	onScopePushed(createKey("root"));
}
	
OFBinaryKeyedWriter::~OFBinaryKeyedWriter()
{
	onScopePopped(createKey("root"));
}

const OFRTTI* OFBinaryKeyedWriter::beginDecodeType()
{
	OFAssert(0, "Internal error. An output serializer should not be reading.");
	return 0;
}

void OFBinaryKeyedWriter::endDecodeType()
{
}

void OFBinaryKeyedWriter::beginEncodeType(const OFRTTI* typeToEncode)
{
	OFSdbmHashedString typeId = typeToEncode->GetTypeId();
	io("___type", typeId);
}

void OFBinaryKeyedWriter::endEncodeType()
{
}

bool OFBinaryKeyedWriter::supportsKeys() const
{
	return true;
}

void OFBinaryKeyedWriter::writeData(OFISerializerKey* keyName, unsigned int dataSize, const void* data)
{
	mDataSink->write(&OFBinaryKeyed::DataMarker, sizeof(OFBinaryKeyed::DataMarker));	

	writeKey(keyName);
	
	mDataSink->write(&dataSize, sizeof(unsigned int));
	mDataSink->write(data, dataSize);
}

void OFBinaryKeyedWriter::onScopePushed(OFISerializerKey* scopeName)
{	
	mDataSink->write(&OFBinaryKeyed::ScopeMarkerBegin, sizeof(OFBinaryKeyed::ScopeMarkerBegin));
	writeKey(scopeName);
}

void OFBinaryKeyedWriter::writeKey(OFISerializerKey* scopeName)
{
	const unsigned char keyLength = strlen(scopeName->getAsString());
	mDataSink->write(&keyLength, sizeof(keyLength));
	mDataSink->write(scopeName->getAsString(), keyLength);
}

void OFBinaryKeyedWriter::onScopePopped(OFISerializerKey* scopeName)
{
	mDataSink->write(&OFBinaryKeyed::ScopeMarkerEnd, sizeof(OFBinaryKeyed::ScopeMarkerEnd));
}

OFPointer<OFBinarySink> OFBinaryKeyedWriter::getDataSink() const
{
	return mDataSink;
}