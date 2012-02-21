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

#include "OFOutputSerializer.h"
#include <list>
#include "OFStringUtility.h"

class OFHttpQueryStringWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFHttpQueryStringWriter();

	bool supportsKeys() const;
			
	NSString* getQueryString();
	NSData* getQueryStringAsData();
	
private:
	void nviIo(OFISerializerKey* keyName, bool& value)							{ mParameters.push_back([NSString stringWithFormat:@"%s=%d", keyName->getAsString(), value ? 1 : 0]); }	
	void nviIo(OFISerializerKey* keyName, int& value)								{ mParameters.push_back([NSString stringWithFormat:@"%s=%d", keyName->getAsString(), value]); }	
	void nviIo(OFISerializerKey* keyName, unsigned int& value)					{ mParameters.push_back([NSString stringWithFormat:@"%s=%d", keyName->getAsString(), value]); }
	void nviIo(OFISerializerKey* keyName, float& value)							{ mParameters.push_back([NSString stringWithFormat:@"%s=%f", keyName->getAsString(), value]); }
	void nviIo(OFISerializerKey* keyName, double& value)							{ mParameters.push_back([NSString stringWithFormat:@"%s=%f", keyName->getAsString(), value]); }
	void nviIo(OFISerializerKey* keyName, std::string& value)
	{
		OFRetainedPtr<NSString> str([NSString stringWithCString:value.c_str()]);
		nviIo(keyName, str);
	}
	
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)	
	{
		mParameters.push_back([NSString stringWithFormat:@"%s=%@", keyName->getAsString(), OFStringUtility::convertToValidParameter(value).get()]);		
	}

	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();
	
	typedef std::list<OFRetainedPtr<NSString> > ParameterList;
	ParameterList mParameters;
};