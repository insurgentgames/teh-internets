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

#include "OFSmartObject.h"
#include "OFRTTI.h"
#include "OFISerializerKey.h"

class OFHashedString;

class OFISerializer : public OFSmartObject
{	
OFDeclareRTTI;
public:
	class Scope
	{
	public:
		Scope(OFISerializer* serializer, const char* scope, bool containsSeries = false);		
		~Scope();
			
	private:
		const char* const mScope;
		OFISerializer* mSerializer;
	};

	virtual bool supportsKeys() const = 0;
	
	static const char* const NoScope;
	
	OFISerializer();
	virtual ~OFISerializer() {}
	
	template <typename OtherType>
	void serialize(const char* keyName, OtherType& composite);

	template <typename PointerType>
	void serialize(const char* keyName, const char* elementKeyName, std::vector< OFPointer<PointerType> >& container);

	template <typename ElementType>
	void serialize(const char* keyName, const char* elementKeyName, std::vector<ElementType>& container);
	void serialize(const char* keyName, const char* elementKeyName, std::vector<bool>& container);
	void serialize(const char* keyName, const char* elementKeyName, std::vector<int>& container);
	void serialize(const char* keyName, const char* elementKeyName, std::vector<float>& container);
	void serialize(const char* keyName, const char* elementKeyName, std::vector<OFRetainedPtr<NSString> >& container);
	
	// WARNING: This function assumes that the key uses io and the value uses serializePolymorphic. 
	// It's also not guaranteed to have the deserialized map have the same order as the serialized map (although I think it will)
	// BTW: I haven't tested this yet... Had to check it in for dependency reason.
	template <typename KeyType, typename ElementType>
	void serialize(const char* keyName, const char* elementKeyName, std::map<KeyType, ElementType>& container);
	
	// WARNING: elementKeyName should not be more than 16 characters
	template <typename ArrayType>
	void serialize(const char* keyName, const char* elementKeyName, unsigned int numItems, ArrayType* array);

	template <typename PointerType>
	void serialize(const char* keyName, OFPointer<PointerType>& object);
	
	template <typename BasePointerType>
	void serializePolymorphic(const char* keyName, OFPointer< BasePointerType >& object);

	template <typename BasePointerType>
	void serializePolymorphic(const char* keyName, const char* elementKeyName, std::vector<OFPointer< BasePointerType > >& container);
	
	template <typename EnumType>
	void serializeEnum(const char* keyName, EnumType& value);
				
	virtual bool isReading() const = 0;

	void io(const char* keyName, OFHashedString& value);
	void io(const char* keyName, bool& value);
	void io(const char* keyName, int& value);	
	void io(const char* keyName, unsigned int& value);	
	void io(const char* keyName, int64_t& value);
	void io(const char* keyName, float& value);	
	void io(const char* keyName, double& value);
	void io(const char* keyName, std::string& value);
	
#ifdef __OBJC__	
	void io(const char* keyName, OFRetainedPtr<NSString>& value);
	void io(const char* keyName, OFRetainedPtr<NSData>& value);
	void io(const char* keyName, NSString* value);
#endif
		
protected:	
	void setSerializeResourcesExternally(bool isSerializingResourcesExternally);
		
	class StringKey : public OFISerializerKey
	{
	public:
		explicit StringKey(const char* key) : value(key) {}

		bool equals(const OFISerializerKey* rhv) const			{ return strcmp(value, ((const StringKey*)rhv)->value) == 0; }
		bool lessthan(const OFISerializerKey* rhv) const		{ return strcmp(value, ((const StringKey*)rhv)->value) < 0; }
		const char* getAsString() const							{ return value; }
	
		const char* value;
	};
	
	struct ScopeDescriptor
	{
		ScopeDescriptor(OFPointer<OFISerializerKey>& _scopeName, bool _containsSeries) 
		: scopeName(_scopeName)
		, containsSeries(_containsSeries)
		{
		}

		OFPointer<OFISerializerKey> scopeName;
		bool containsSeries;
	};
	typedef std::vector<ScopeDescriptor> ScopeDescriptorSeries;
	
	const ScopeDescriptorSeries& getActiveScopes() const;
	
	bool isCurrentScopeASeries() const;

	virtual OFPointer<OFISerializerKey> createKey(const char* keyName) const;
	
private:
	virtual void nviIo(OFISerializerKey* keyName, bool& value) = 0;
	virtual void nviIo(OFISerializerKey* keyName, int& value) = 0;	
	virtual void nviIo(OFISerializerKey* keyName, unsigned int& value) = 0;	
	virtual void nviIo(OFISerializerKey* keyName, int64_t& value) = 0;	
	virtual void nviIo(OFISerializerKey* keyName, float& value) = 0;	
	virtual void nviIo(OFISerializerKey* keyName, double& value) = 0;
	virtual void nviIo(OFISerializerKey* keyName, std::string& value) = 0;

#ifdef __OBJC__	
	virtual void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value) = 0;
	virtual void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSData>& value) = 0;
#endif

	virtual void serializeNumElementsInScopeSeries(unsigned int& count);
	
	virtual void onScopePushed(OFISerializerKey* scopeName) {}
	virtual void onScopePopped(OFISerializerKey* scopeName) {}

	virtual const OFRTTI* beginDecodeType() = 0;
	virtual void endDecodeType() = 0;	
	virtual void beginEncodeType(const OFRTTI* typeToEncode) = 0;
	virtual void endEncodeType() = 0;
	
	template <class ElementType>
	void serializePodVector(const char* keyName, const char* elementKeyName, std::vector<ElementType>& container);

	template <typename PointerType>
	OFPointer<PointerType> deserializeObject(const char* keyName);

	template <typename BasePointerType>
	OFPointer<BasePointerType> deserializePolymorphicObject(const OFRTTI* type);
	
	virtual OFPointer<OFISerializer> createSerializerForInnerStreamOfType(const OFRTTI* type);
	virtual void storeInnerStreamOfType(OFISerializer* innerResourceStream, const OFRTTI* type);
	
	void pushScope(const char* scopeName, bool containsSeries);	
	void popScope();		
	
	ScopeDescriptorSeries mActiveScopes;
	bool mIsSerializingResourcesExternally;	
};

#include "OFISerializer.inl"