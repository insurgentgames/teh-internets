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
#ifndef OF_SMART_OBJECT_H
#define OF_SMART_OBJECT_H

#include "OFRTTI.h"

//////////////////////////////////////////////////////////////////////////
/// An interface by which objects can be self-managed through the
/// use of reference counting and auto-pointers to wrap the reference
/// counting. 
///
/// @note	To derive a new such object, one would have to inherit from
///			OFSmartObject, as well as declare and implement the RTTI system 
///			either by hand or using the predefined macros OFDeclareRTTI and 
///			OFImplementRTTI. 
///
/// @note	To avoid the requirement of calling AddRef/Release
///			upon creation/deletion of a pointer you may also make use of 
///			the	onSmartPointer class.
///
/// @note	RTTI implementation is optional but recommended.
///
/// @note	Use the onSharedPtr type for non-intrusive shared pointers.
///
/// @remarks	Prefer the onIntrusivePtr datatype for declarations of
///				shared pointers for smart objects.
//////////////////////////////////////////////////////////////////////////

class OFSmartObject
{
	OFDeclareRootRTTI
public:
	virtual ~OFSmartObject();

	int GetObjectID();

	void AddRef();
	void AddRef() const;
	
	void Release();
	void Release() const;

	int RefCount() const;

	bool unique() const;

protected:
	OFSmartObject();

	mutable int	m_iRefCount;
};

#include "OFSmartObject.inl"

#endif