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

#include "OFCallbackable.h"
#include "OFRetainedPtr.h"

/// @note Any interfaces that wish to receive callbacks from an OFDelegate must implement the OFCallbackable protocol.
///		  If you forget, the error will be caught with a runtime assertion.

class OFDelegate
{
public:
	OFDelegate();
	~OFDelegate();

	OFDelegate(OFDelegate const& otherDelegate);
	OFDelegate& operator=(const OFDelegate& otherDelegate);

	OFDelegate(NSObject<OFCallbackable>* target, SEL selector);	
	OFDelegate(NSObject<OFCallbackable>* target, SEL selector, NSObject* userParam);

	/// @warning	when using manual chaining, the invoked selector has a second paramter of type OFDelegateChained*.
	///				you are required to explicitly invoke the chained delegate when ready!
	OFDelegate(NSObject<OFCallbackable>* target, SEL selector, const OFDelegate& manuallyChainedCall);	

	OFDelegate(NSObject<OFCallbackable>* target, SEL selector, NSThread* targetThread);
	OFDelegate(NSObject<OFCallbackable>* target, SEL selector, NSThread* targetThread, NSObject* userParam);
	
	void invoke(NSObject* parameter = 0) const;
	void invoke(NSObject* parameter, NSTimeInterval afterDelay) const;

	bool isValid() const;

private:
	NSObject<OFCallbackable>* mTarget;
	NSObject* mUserParam;
	NSThread* mTargetThread;
	SEL mSelector;
};
