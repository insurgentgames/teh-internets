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

#ifndef __OF_BASE_H__
#define __OF_BASE_H__

#pragma once

typedef				char		onInt8;
typedef unsigned	char		onUInt8;
typedef				short		onInt16;
typedef unsigned	short		onUInt16;
typedef				int			onInt32;
typedef unsigned	int			onUInt32;
typedef				char		onChar;
typedef				bool		onBool;
typedef				float		onReal;

//////////////////////////////////////////////////////////////////////////
/// Defines an assertion which breaks the debugger on the assertion line,
/// not somewhere in the assert function. 
///
/// @note	No debug box is displayed, but rather a user breakpoint notice.
//////////////////////////////////////////////////////////////////////////
#if defined(_DEBUG)
	#if TARGET_IPHONE_SIMULATOR
		#define OFAssert(condition, message, ...) if(!(condition)) { OFLog([NSString stringWithFormat:@"ASSERT: %s Failed: %s ", #condition, message], ##__VA_ARGS__);  { __asm { int 3 } } }
	#else
		#define OFAssert(condition, message, ...) if(!(condition)) { *((int*)NULL) = 0; }
	#endif
#else
	#define OFAssert(condition, message, ...) (void)0
#endif

//////////////////////////////////////////////////////////////////////////
/// Defines a macro which automates making a class non-copyable.
///
/// @note	This must be in a private or protected access section.
///
/// @note	If disabling copying of a class hierarchy is desired, place
///			this in the protected section of a parent.
//////////////////////////////////////////////////////////////////////////
#define OFDeclareNonCopyable(className)		\
	className(const className&);			\
	bool operator=(const className&);

//////////////////////////////////////////////////////////////////////////
/// Defines a macro which automates declaring a class as a singleton.
///
/// @warning	The singleton DOES NOT USE LAZY INITIALIZATION. This means
///				it must be explicitly initialized and shutdown. In most
///				situations, this will be used for a singleton which is part
///				of a larger plug-in.
///
/// @note	onAutoPtr is used. So the appropriate header file must be
///			included.
///
/// @warning	This should be placed before any access specifiers in the 
///				class declaration. The access type is modified.
///
/// @note This should be used in conjunction with OFDefineSingleton.
//////////////////////////////////////////////////////////////////////////
#define OFDeclareSingleton(className)					\
	private:											\
		className();									\
		className(const className&);					\
		className& operator=(const className&);			\
		static std::auto_ptr<className> s_UniqueInstance;	\
	public:												\
		static void Initialize();						\
		static className* Instance();					\
		void Shutdown()							

//////////////////////////////////////////////////////////////////////////
/// Defines a macro which automates defining a class as a singleton.
///
/// @note This should be used in conjunction with OFDeclareSingleton.
//////////////////////////////////////////////////////////////////////////
#define OFDefineSingleton(className)						\
		void className::Initialize()								\
		{															\
			s_UniqueInstance.reset(new className());				\
		}															\
																	\
		className* className::Instance()							\
		{															\
			return s_UniqueInstance.get();							\
		}															\
																	\
		void className::Shutdown()									\
		{															\
			s_UniqueInstance.reset(0);								\
		}															\
		std::auto_ptr<className> className::s_UniqueInstance(0)


//////////////////////////////////////////////////////////////////////////
/// Defines a macro which releases an objective C class and sets it to nil
//////////////////////////////////////////////////////////////////////////
#define OFSafeRelease(ocObject) [ocObject release]; \
								ocObject = nil;

#endif