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

#ifndef OF_POINTER_H
#define OF_POINTER_H

#include "OFBase.h"

//////////////////////////////////////////////////////////////////////////
/// OFPointer is a templated class which wraps the functionality of a
/// pointer and automates reference counting of OFSmartObject derived
/// objects.
//////////////////////////////////////////////////////////////////////////
template <class T>
class OFPointer
{
public:
	/// Ctors and Dtors
	OFPointer(T* pObj = 0);
	OFPointer(const OFPointer& pPtr);
	~OFPointer();

	template <class D>
	explicit OFPointer(const OFPointer<D>& pPtr);

	template <class D>
	explicit OFPointer(OFPointer<D>& pPtr);

	/// Assigment
	OFPointer& operator=(const OFPointer& pPtr);

	/// @TODO Remove this!
	OFPointer& operator=(T* pObj);

	// Assignment from one smart pointer type to another
	template <class D>
	OFPointer<T>& operator=(OFPointer<D>& pPtr);

	/// Equality
	bool operator==(const OFPointer& pPtr) const;
	bool operator==(T* pObj) const;

	/// Inequality
	bool operator!=(const OFPointer& pPtr) const;
	bool operator!=(T* pObj) const;

	// Pointer access
	T* get();
	const T* get() const;

	// Resets the smart pointer
	void reset(T* ptr);

	/// Implicit conversions
	/// @TODO Remove this!
	operator T*() const;

	operator bool() const;

	T* operator->() const;
	T& operator*() const;

	template <class D>
	bool operator<(const OFPointer<D>& Ptr) const;

private:
	/// Actual object pointer
	T*	m_pObject;
};

template <class T> template <class D>
inline OFPointer<T>::OFPointer(const OFPointer<D>& pPtr)
{
	m_pObject = static_cast<const T*>(pPtr.get());

	if(m_pObject)
		m_pObject->AddRef();
}

template <class T> template <class D>
inline OFPointer<T>::OFPointer(OFPointer<D>& pPtr)
{
	m_pObject = static_cast<T*>(pPtr.get());

	if(m_pObject)
		m_pObject->AddRef();
}

template <class T> template<class D>
inline OFPointer<T>& OFPointer<T>::operator=(OFPointer<D>& pPtr)
{
	if(pPtr.get() != m_pObject)
	{
		if(m_pObject)
			m_pObject->Release();

		m_pObject = static_cast<T*>(pPtr.get());

		if(m_pObject)
			m_pObject->AddRef();
	}

	return *this;
}

template <class T>
inline T* OFPointer<T>::get()
{
	return m_pObject;
}

template <class T>
inline const T* OFPointer<T>::get() const
{
	return m_pObject;
}

template <class T>
inline void OFPointer<T>::reset(T* ptr)
{
	if(ptr != m_pObject)
	{
		if(m_pObject)
			m_pObject->Release();

		m_pObject = ptr;

		if(m_pObject)
			m_pObject->AddRef();
	}
}

template <class T>
inline OFPointer<T>::OFPointer(T* pObj) :
	m_pObject(pObj)
{
	if (m_pObject)
		m_pObject->AddRef();
}

template <class T>
inline OFPointer<T>::OFPointer(const OFPointer<T>& pPtr) :
	m_pObject(pPtr.m_pObject)
{
	if (m_pObject)
		m_pObject->AddRef();
}

template <class T>
inline OFPointer<T>::~OFPointer()
{
	if (m_pObject)
		m_pObject->Release();
}

template <class T>
inline OFPointer<T>& OFPointer<T>::operator=(const OFPointer<T>& pPtr)
{
	if(m_pObject != pPtr.m_pObject)
	{
		if (m_pObject)
			m_pObject->Release();

		m_pObject = pPtr.m_pObject;

		if (m_pObject)
			m_pObject->AddRef();
	}

	return *this;
}

template <class T>
inline OFPointer<T>& OFPointer<T>::operator=(T* pObj)
{
	if (m_pObject != pObj)
	{
		if (m_pObject)
			m_pObject->Release();

		m_pObject = pObj;

		if (m_pObject)
			m_pObject->AddRef();
	}

	return *this;
}

template <class T>
inline bool OFPointer<T>::operator==(const OFPointer<T>& pPtr) const
{
	return m_pObject == pPtr.m_pObject;
}

template <class T>
inline bool OFPointer<T>::operator==(T* pObj) const
{
	return m_pObject == pObj;
}

template <class T>
inline bool OFPointer<T>::operator!=(const OFPointer<T>& pPtr) const
{
	return m_pObject != pPtr.m_pObject;
}

template <class T>
inline bool OFPointer<T>::operator!=(T* pObj) const
{
	return m_pObject != pObj;
}

template <class T>
inline OFPointer<T>::operator T*() const
{
	return m_pObject;
}

template <class T>
inline OFPointer<T>::operator bool() const
{
	return m_pObject != 0;
}

template <class T>
inline T* OFPointer<T>::operator->() const
{
	return m_pObject;
}

template <class T>
inline T& OFPointer<T>::operator*() const
{
	return *m_pObject;
}

template <class T> template <class D>
inline bool OFPointer<T>::operator<(const OFPointer<D>& Ptr) const
{
	return m_pObject < Ptr.m_pObject;
}

#endif