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

#include "OFISerializer.h"
#include "OFHashedString.h"

OFImplementRTTI(OFISerializer, OFSmartObject);

const char* const OFISerializer::NoScope = 0;

OFISerializer::OFISerializer()
: mIsSerializingResourcesExternally(true)
{
}

void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector<bool>& container)
{
	serializePodVector(keyName, elementKeyName, container);
}

void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector<float>& container)
{
	serializePodVector(keyName, elementKeyName, container);
}

void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector<int>& container)
{
	serializePodVector(keyName, elementKeyName, container);
}

void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector<OFRetainedPtr<NSString> >& container)
{
	serializePodVector(keyName, elementKeyName, container);
}
	
void OFISerializer::pushScope(const char* scopeName, bool containsSeries)
{	
	OFPointer<OFISerializerKey> scope = createKey(scopeName);
	
	mActiveScopes.push_back(ScopeDescriptor(scope, containsSeries));
	onScopePushed(scope);
}

void OFISerializer::popScope()
{
	ScopeDescriptor poppingScope = mActiveScopes.back();

	mActiveScopes.pop_back();
	onScopePopped(poppingScope.scopeName);
}

void OFISerializer::io(const char* keyName, OFHashedString& value)
{
	io(keyName, value.valueForSerialization());	
}

OFISerializer::Scope::Scope(OFISerializer* serializer, const char* scope, bool containsSeries)
: mScope(scope)
{
	if(mScope == NoScope)
	{
		return;
	}
	
	mSerializer = serializer;
	mSerializer->pushScope(scope, containsSeries);
}

OFISerializer::Scope::~Scope()
{
	if(mScope == NoScope)
	{
		return;
	}

	mSerializer->popScope();
}

void OFISerializer::setSerializeResourcesExternally(bool isSerializingResourcesExternally)
{
	mIsSerializingResourcesExternally = isSerializingResourcesExternally;
}

OFPointer<OFISerializer> OFISerializer::createSerializerForInnerStreamOfType(const OFRTTI* type)
{
	return this;
}

void OFISerializer::storeInnerStreamOfType(OFISerializer* innerResourceStream, const OFRTTI* type)
{
	OFAssert(innerResourceStream == this, "An alternative serializer was partially specified for inner streams");

	// citron note: do nothing
}

const OFISerializer::ScopeDescriptorSeries& OFISerializer::getActiveScopes() const
{
	return mActiveScopes;
}

bool OFISerializer::isCurrentScopeASeries() const
{
	return !mActiveScopes.empty() && mActiveScopes.back().containsSeries;
}

void OFISerializer::serializeNumElementsInScopeSeries(unsigned int& count)
{
	io("num_elements", count);
}

OFPointer<OFISerializerKey> OFISerializer::createKey(const char* keyName) const
{
	return new StringKey(keyName);
}

void OFISerializer::io(const char* keyName, bool& value)			{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, int& value)			{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, unsigned int& value)	{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, int64_t& value)		{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, float& value)			{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, double& value)		{	nviIo(createKey(keyName), value); }
void OFISerializer::io(const char* keyName, std::string& value)	{	nviIo(createKey(keyName), value); }
	
#ifdef __OBJC__	
void OFISerializer::io(const char* keyName, OFRetainedPtr<NSString>& value) {	nviIo(createKey(keyName), value); }

void OFISerializer::io(const char* keyName, OFRetainedPtr<NSData>& value)
{
	nviIo(createKey(keyName), value);
}

void OFISerializer::io(const char* keyName, NSString* value) 
{ 
	OFRetainedPtr<NSString> retainedString(value);
	OFAssert(!isReading(), @"When reading you must use a retained pointer");
	io(keyName, retainedString); 
}
#endif