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

class OFXmlWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFXmlWriter(const char* rootNodeName);
	OFXmlWriter();

	bool supportsKeys() const;
	
	OFRetainedPtr<NSString> buildAndGetDocument() const;
	
private:
	void nviIo(OFISerializerKey* keyName, bool& value);
	void nviIo(OFISerializerKey* keyName, int& value);
	void nviIo(OFISerializerKey* keyName, unsigned int& value);
	void nviIo(OFISerializerKey* keyName, float& value);
	void nviIo(OFISerializerKey* keyName, double& value);
	void nviIo(OFISerializerKey* keyName, std::string& value);	
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value);	

	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();
	
	void onScopePushed(OFISerializerKey* scopeName);
	void onScopePopped(OFISerializerKey* scopeName);
	
	class Node : public OFSmartObject
	{
	public:
		Node(OFISerializerKey* _name, OFRetainedPtr<NSString> _value) : name(_name), value(_value) {}
		Node(OFISerializerKey* _name) : name(_name), value(0) {}

		OFRetainedPtr<NSString> createSubtree() const;

		OFPointer<OFISerializerKey> name;
		OFRetainedPtr<NSString> value;
		std::vector<OFPointer<Node> > children;
	};

	void attachNode(OFPointer<Node> nodeToAttach);

	OFPointer<Node> mDocumentRoot;
	std::vector<OFPointer<Node> > mActiveNodes;
};