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

#include "OFBinarySdbmKeyedWriter.h"
#include "OFBinarySink.h"
#include "OFSdbmSerializerKey.h"

OFImplementRTTI(OFBinarySdbmKeyedWriter, OFBinaryKeyedWriter);

OFBinarySdbmKeyedWriter::OFBinarySdbmKeyedWriter(OFPointer<OFBinarySink> dataSink, bool serializeResourcesExternally)
: OFBinaryKeyedWriter(serializeResourcesExternally)
{
	initialize(dataSink);
}

OFPointer<OFISerializerKey> OFBinarySdbmKeyedWriter::createKey(const char* keyName) const
{
	return new OFSdbmSerializerKey(keyName);
}

void OFBinarySdbmKeyedWriter::writeKey(OFISerializerKey* keyName)
{
	OFSdbmSerializerKey* key = reinterpret_cast<OFSdbmSerializerKey*>(keyName);
	getDataSink()->write(&key->value.valueForSerialization(), sizeof(key->value.valueForSerialization()));
}