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

template <typename PointerType>
void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector< OFPointer<PointerType> >& container)
{
	Scope scope(this, keyName, true);

	unsigned int num_elements = container.size();
	serializeNumElementsInScopeSeries(num_elements);
	
	if(isReading())
	{
		container.clear();
		container.resize(num_elements);
	}
	
	for(unsigned int i = 0; i < num_elements; ++i)
	{
		serialize(elementKeyName, container.at(i));
	}
	
}

template <typename KeyType, typename ElementType>
void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::map< KeyType, ElementType >& container)
{
	Scope scope(this, keyName, true);
	
	unsigned int num_elements = container.size();
	serializeNumElementsInScopeSeries(num_elements);
	
	if(isReading())
	{
		container.clear();
		for (int i = 0; i < num_elements; i++)
		{
			std::pair<KeyType, ElementType> entry;
			Scope scope(this, elementKeyName, false);
			io("key", entry.first);
			serializePolymorphic("value", entry.second);
			container.insert(entry);
		}
	}
	else
	{
		typedef typename std::map<KeyType, ElementType>::iterator TypedMapIterator;
		TypedMapIterator it = container.begin();
		TypedMapIterator itEnd = container.end();
		for (; it != itEnd; ++it)
		{
			Scope scope(this, elementKeyName, false);
			io("key", *const_cast<KeyType*>(&it->first));
			serializePolymorphic("value", it->second);	
		}
	}
}

template <typename PointerType>
void OFISerializer::serialize(const char* keyName, OFPointer<PointerType>& object)
{
	if(isReading())
	{
		object = deserializeObject<PointerType>(keyName);
	}
	else if (object)
	{
		serialize(keyName, *object);
	}
}

template <typename ElementType>
void OFISerializer::serialize(const char* keyName, const char* elementKeyName, std::vector<ElementType>& container)
{
	Scope scope(this, keyName, true);
	
	unsigned int num_elements = container.size();
	serializeNumElementsInScopeSeries(num_elements);
	
	if(isReading())
	{
		container.clear();
		container.reserve(num_elements);
	}
	
	for(unsigned int i = 0; i < num_elements; ++i)
	{
		if(isReading())
		{
			Scope scope(this, elementKeyName);
			container.push_back(ElementType(this));
		}
		else
		{
			serialize(elementKeyName, container.at(i));
		}
	}
}

template <class ElementType>
void OFISerializer::serializePodVector(const char* keyName, const char* elementKeyName, std::vector<ElementType>& container)
{
	Scope scope(this, keyName, true);
	
	unsigned int num_elements = container.size();
	serializeNumElementsInScopeSeries(num_elements);
	
	if(isReading())
	{
		container.clear();
		container.reserve(num_elements);
	}
	
	for(unsigned int i = 0; i < num_elements; ++i)
	{
		ElementType value;
		
		if(!isReading())
		{
			value = container[i];
		}
		
		io(elementKeyName, value);

		if(isReading())
		{
			container.push_back(value);
		}
	}
}

template <typename BasePointerType>
void OFISerializer::serializePolymorphic(const char* keyName, OFPointer< BasePointerType >& object)
{
	Scope scope(this, keyName);
	
	if(isReading())
	{		
		const OFRTTI* type = beginDecodeType();
		object.reset(deserializePolymorphicObject<BasePointerType>(type));
		endDecodeType();
	}
	else if(object.get())
	{
		beginEncodeType(object->GetRTTI());
		object->serialize(this);
		endEncodeType();
	}
}

template <typename BasePointerType>
void OFISerializer::serializePolymorphic(const char* keyName, const char* elementKeyName, std::vector<OFPointer< BasePointerType > >& container)
{
	Scope scope(this, keyName, true);
	
	unsigned int num_elements = container.size();
	serializeNumElementsInScopeSeries(num_elements);
	
	if(isReading())
	{
		container.clear();
		container.resize(num_elements);
	}
	
	for(unsigned int i = 0; i < num_elements; ++i)
	{		
		serializePolymorphic(elementKeyName, container.at(i));
	}
}

template <typename OtherType>
void OFISerializer::serialize(const char* keyName, OtherType& composite)
{
	Scope scope(this, keyName);
	composite.serialize(this);
}

template <typename BasePointerType>
OFPointer<BasePointerType> OFISerializer::deserializePolymorphicObject(const OFRTTI* type)
{
	return OFPointer<BasePointerType>(type ? 
		static_cast<BasePointerType*>(
			type->DeserializeObject(this)
		) 
		:
		NULL
	);
}

template <typename PointerType>
OFPointer<PointerType> OFISerializer::deserializeObject(const char* keyName)
{
	Scope scope(this, keyName);
	OFPointer<PointerType> value(new PointerType(this));
	return value;
}

template <typename ArrayType>
void OFISerializer::serialize(const char* keyName, const char* elementKeyName, unsigned int numItems, ArrayType* array)
{
	char tmpString[64] = {0};
	
	Scope s(this, keyName, true);
	for(unsigned int i = 0; i < numItems; ++i)
	{
		sprintf(tmpString, "%s_%d", elementKeyName, i);
		io(tmpString, array[i]);
	}
}

template <typename EnumType>
void OFISerializer::serializeEnum(const char* keyName, EnumType& value)
{
	unsigned int v = (unsigned int)value;
	io(keyName, v);
	value = (EnumType)v;
}