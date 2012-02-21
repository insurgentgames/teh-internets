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

#ifndef OF_RTTI_H
#define OF_RTTI_H

#include "OFBase.h"
#include "OFHashedString.h"

class OFISerializer;

//////////////////////////////////////////////////////////////////////////
/// OFRTTI is a class which facilitates the tracking and identifying
/// of any class' position in its inheritance hierarchy. A static OFRTTI
/// class object should be present in every class in the hierarchy.
///
/// @remarks	Never directly refer to the RTTI class. Always use the 
///				provided macros. However, the provided functions should be 
///				used when appropriate. See OFDeclareRootRTTI for the 
///				available functions.
///
/// @remarks	An RTTI root class should make sure of OFDeclareRTTI in the 
///				definition, and OFImplementRootRTTI in the implementation.
///
/// @remarks	Derived classes should make use of OFDeclareRTTI in the class 
///				definition, and OFImplementRTTI in the implementation.
///
/// @see	OFDeclareRootRTTI, OFImplementRootRTTI, 
///			OFDeclareRTTI, OFImplementRTTI
//////////////////////////////////////////////////////////////////////////
class OFRTTI
{
public:
	typedef void* (*DeserializationFunction)(OFISerializer*);
	
	//////////////////////////////////////////////////////////////////////////
	/// @note This should always be wrapped by the above macros
	//////////////////////////////////////////////////////////////////////////
	OFRTTI(
		const onChar* szName,	///< The name given to this RTTI object
		const OFRTTI* pBase,		///< Pointer to this RTTI object's parent	
		DeserializationFunction fDeserializeFunction
		);

	//////////////////////////////////////////////////////////////////////////
	/// Releases memory associated with the name
	//////////////////////////////////////////////////////////////////////////
	~OFRTTI()
	{
		if (s_zName)
			delete[] s_zName;
	}

	//////////////////////////////////////////////////////////////////////////
	/// Accessors
	//////////////////////////////////////////////////////////////////////////
	const onChar* GetName() const						{ return s_zName; }
	const OFRTTI* GetBase()	const						{ return m_pBaseClass; }
	const OFSdbmHashedString& GetTypeId() const	{ return m_TypeId; }
	
	//////////////////////////////////////////////////////////////////////////
	/// Never call these
	//////////////////////////////////////////////////////////////////////////
	// WARNING: The memory returned here is not managed
	void* DeserializeObject(OFISerializer* stream) const;
	
private:
	const onChar*	s_zName;
	const OFRTTI*	m_pBaseClass;
	OFSdbmHashedString m_TypeId;
	DeserializationFunction m_DeserializationFunction;
};

//////////////////////////////////////////////////////////////////////////
/// Allows access to the RTTI object of a type without the need to know 
/// the name of the static member.
//////////////////////////////////////////////////////////////////////////
#define OFGetRTTI(x) &(x::s_RTTI)

//////////////////////////////////////////////////////////////////////////
/// Declare RTTI object and utility functions for casting and hierarchy 
/// position determination
///
/// @remarks	This should be placed in the declaration of the root 
///				class of a hierarchy, before any scope specifiers.
///
/// @remarks	Prefer the templated DynamicCast to the non-templated one.
//////////////////////////////////////////////////////////////////////////
#define OFDeclareRootRTTI															\
	public:																			\
		static const OFRTTI s_RTTI;													\
																					\
		virtual const OFRTTI* GetRTTI() const									{ return &s_RTTI; }								\
		bool IsExactlyClass(const OFRTTI* pRTTI) const						{ return GetRTTI() == pRTTI; }					\
		const void* DynamicCast(const OFRTTI* pRTTI) const					{ return (IsDerivedFrom(pRTTI) ? this : 0); }	\
		void* DynamicCast(const OFRTTI* pRTTI)									{ return (IsDerivedFrom(pRTTI) ? this : 0); }	\
		template <typename TargetType> TargetType* DynamicCast()				{ return (IsDerivedFrom(&TargetType::s_RTTI) ? static_cast<TargetType*>(this) : 0); } \
		template <typename TargetType> const TargetType* DynamicCast() const	{ return (IsDerivedFrom(&TargetType::s_RTTI) ? static_cast<const TargetType*>(this) : 0); } \
		bool IsDerivedFrom(const OFRTTI* pRTTI) const								\
		{																			\
			const OFRTTI* pTempRTTI = GetRTTI();									\
																					\
			while (pTempRTTI)														\
			{																		\
				if (pTempRTTI == pRTTI)												\
					return true;													\
																					\
				pTempRTTI = pTempRTTI->GetBase();									\
			}																		\
																					\
			return false;															\
		}

//////////////////////////////////////////////////////////////////////////
/// INTERNAL:: Implements the deserialization interface
//////////////////////////////////////////////////////////////////////////
#define __OFdeserializerName(className) OFRTTI__deserializer__##className

#define __OFImplementDeserialization(className) \
	static void* __deserializerName(className)(OFISerializer* stream) \
	{ \
		return reinterpret_cast<void*>(new className(stream)); \
	}
	
//////////////////////////////////////////////////////////////////////////
/// Implement RTTI object
//////////////////////////////////////////////////////////////////////////
#define OFImplementRootRTTI(className) \
	const OFRTTI className::s_RTTI(#className, 0, NULL);

#define OFImplementRootRTTISerializable(className) \
	__OFImplementDeserialization(className) \
	const OFRTTI className::s_RTTI(#className, 0, __OFdeserializerName(className));
			
//////////////////////////////////////////////////////////////////////////
/// Declare RTTI object and virtual GetRTTI accessor
///
/// @remarks	This should be placed in the declaration of a derived 
///				class, before any scope specifiers.
//////////////////////////////////////////////////////////////////////////
#define OFDeclareRTTI												\
	public:															\
		static const OFRTTI s_RTTI;									\
		virtual const OFRTTI* GetRTTI()	const	{ return &s_RTTI; }

//////////////////////////////////////////////////////////////////////////
/// Implement RTTI object
///
/// @remarks	This should be placed in the cpp file of a derived class. 
//////////////////////////////////////////////////////////////////////////
#define OFImplementRTTI(className, baseClassName)					\
	const OFRTTI className::s_RTTI(#className, &baseClassName::s_RTTI, NULL);

#define OFImplementRTTISerializable(className, baseClassName)					\
	__OFImplementDeserialization(className) \
	const OFRTTI className::s_RTTI(#className, &baseClassName::s_RTTI, __OFdeserializerName(className));

#endif