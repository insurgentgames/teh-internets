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

#include "OFBinarySink.h"

class OFOutputSerializer;
@class MPURLRequestParameter;
class OFHttpQueryParameter : public OFSmartObject
	{
	public:
		OFHttpQueryParameter(NSString* name);
		
		virtual NSString* getAsUrlParameter() const = 0;
		virtual void appendToMultipartFormData(NSMutableData* multipartStream) const = 0;
		virtual MPURLRequestParameter* getAsMPURLRequestParameter() const = 0;
		
		virtual NSString* getValueAsString() const = 0;
		NSString* getName() const;
		void rename(NSString* newName);
		
	protected:
		OFRetainedPtr<NSString> mName;
	};

class OFHttpAsciiParameter : public OFHttpQueryParameter
	{
	public:
		OFHttpAsciiParameter(NSString* parameterName, NSString* parameterValue);
		
		NSString* getValueAsString() const;
		NSString* getAsUrlParameter() const;
		MPURLRequestParameter* getAsMPURLRequestParameter() const;
		void appendToMultipartFormData(NSMutableData* multipartStream) const;
		
	private:
		OFRetainedPtr<NSString> mValue;	
	};

class OFHttpBinaryParameter : public OFHttpQueryParameter
	{
	public:
		OFHttpBinaryParameter(NSString* parameterName, OFPointer<OFBinaryMemorySink> binaryData, NSString* dataType);
		
		NSString* getValueAsString() const;
		NSString* getAsUrlParameter() const;
		MPURLRequestParameter* getAsMPURLRequestParameter() const;
		void appendToMultipartFormData(NSMutableData* multipartStream) const;
		
	private:
		OFRetainedPtr<NSString> mDataType;
		OFPointer<OFBinaryMemorySink> mData;
	};