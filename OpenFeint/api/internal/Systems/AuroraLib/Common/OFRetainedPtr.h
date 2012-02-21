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

template <class T>
class OFRetainedPtr
{
public:
	/// Ctors and Dtors
	OFRetainedPtr(T* pObj = 0);
	OFRetainedPtr(const OFRetainedPtr& pPtr);
	~OFRetainedPtr();

	template <class D>
	explicit OFRetainedPtr(const OFRetainedPtr<D>& pPtr);

	template <class D>
	explicit OFRetainedPtr(OFRetainedPtr<D>& pPtr);

	/// Assigment
	OFRetainedPtr& operator=(const OFRetainedPtr& pPtr);

	/// @TODO Remove this!
	OFRetainedPtr& operator=(T* pObj);

	// Assignment from one smart pointer type to another
	template <class D>
	OFRetainedPtr<T>& operator=(OFRetainedPtr<D>& pPtr);

	/// Equality
	bool operator==(const OFRetainedPtr& pPtr) const;
	bool operator==(T* pObj) const;

	/// Inequality
	bool operator!=(const OFRetainedPtr& pPtr) const;
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
	bool operator<(const OFRetainedPtr<D>& Ptr) const;

private:
	/// Actual object pointer
	T*	m_pObject;
};


template <class T> template <class D>
inline OFRetainedPtr<T>::OFRetainedPtr(const OFRetainedPtr<D>& pPtr)
{
	m_pObject = static_cast<const T*>(pPtr.get());

	if(m_pObject)
	{
		[m_pObject retain];
	}
}

template <class T> template <class D>
inline OFRetainedPtr<T>::OFRetainedPtr(OFRetainedPtr<D>& pPtr)
{
	m_pObject = static_cast<T*>(pPtr.get());

	if(m_pObject)
	{
		[m_pObject retain];
	}
}

template <class T> template<class D>
inline OFRetainedPtr<T>& OFRetainedPtr<T>::operator=(OFRetainedPtr<D>& pPtr)
{
	if(pPtr.get() != m_pObject)
	{
		if(m_pObject)
		{
			[m_pObject release];
		}

		m_pObject = static_cast<T*>(pPtr.get());

		if(m_pObject)
		{
			[m_pObject retain];
		}
	}

	return *this;
}

template <class T>
inline T* OFRetainedPtr<T>::get()
{
	return m_pObject;
}

template <class T>
inline const T* OFRetainedPtr<T>::get() const
{
	return m_pObject;
}

template <class T>
inline void OFRetainedPtr<T>::reset(T* ptr)
{
	if(ptr == m_pObject)
	{
	}
	else
	{
		if(m_pObject)
		{
			[m_pObject release];
		}
		
		m_pObject = ptr;

		if(m_pObject)
		{
			[m_pObject retain];
		}
	}
}

template <class T>
inline OFRetainedPtr<T>::OFRetainedPtr(T* pObj) :
	m_pObject(pObj)
{
	if (m_pObject)
	{
		[m_pObject retain];
	}
}

template <class T>
inline OFRetainedPtr<T>::OFRetainedPtr(const OFRetainedPtr<T>& pPtr) :
	m_pObject(pPtr.m_pObject)
{
	if (m_pObject)
	{
		[m_pObject retain];
	}
}

template <class T>
inline OFRetainedPtr<T>::~OFRetainedPtr()
{
	if (m_pObject)
	{
		[m_pObject release];
	}
}

template <class T>
inline OFRetainedPtr<T>& OFRetainedPtr<T>::operator=(const OFRetainedPtr<T>& pPtr)
{
	if(m_pObject != pPtr.m_pObject)
	{
		if (m_pObject)
		{
			[m_pObject release];
		}
		
		m_pObject = pPtr.m_pObject;

		if (m_pObject)
		{
			[m_pObject retain];
		}
	}

	return *this;
}

template <class T>
inline OFRetainedPtr<T>& OFRetainedPtr<T>::operator=(T* pObj)
{
	if (m_pObject != pObj)
	{
		if (m_pObject)
		{
			[m_pObject release];
		}
		
		m_pObject = pObj;

		if (m_pObject)
		{
			[m_pObject retain];
		}
	}

	return *this;
}

template <class T>
inline bool OFRetainedPtr<T>::operator==(const OFRetainedPtr<T>& pPtr) const
{
	return m_pObject == pPtr.m_pObject;
}

template <class T>
inline bool OFRetainedPtr<T>::operator==(T* pObj) const
{
	return m_pObject == pObj;
}

template <class T>
inline bool OFRetainedPtr<T>::operator!=(const OFRetainedPtr<T>& pPtr) const
{
	return m_pObject != pPtr.m_pObject;
}

template <class T>
inline bool OFRetainedPtr<T>::operator!=(T* pObj) const
{
	return m_pObject != pObj;
}

template <class T>
inline OFRetainedPtr<T>::operator T*() const
{
	return m_pObject;
}

template <class T>
inline OFRetainedPtr<T>::operator bool() const
{
	return m_pObject != 0;
}

template <class T>
inline T* OFRetainedPtr<T>::operator->() const
{
	return m_pObject;
}

template <class T>
inline T& OFRetainedPtr<T>::operator*() const
{
	return *m_pObject;
}

template <class T> template <class D>
inline bool OFRetainedPtr<T>::operator<(const OFRetainedPtr<D>& Ptr) const
{
	return m_pObject < Ptr.m_pObject;
}
