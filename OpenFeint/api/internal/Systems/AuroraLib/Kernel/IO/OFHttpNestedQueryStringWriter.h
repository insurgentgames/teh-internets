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
#include "OFHttpQueryParameter.h"

class OFHttpNestedQueryStringWriter : public OFOutputSerializer
{
OFDeclareRTTI;
public:
	OFHttpNestedQueryStringWriter();

	void setShouldEscapeStrings(bool escapeStrings);
	bool supportsKeys() const;
	
	NSArray* getQueryParameters() const;
	NSArray* getQueryParametersAsMPURLRequestParameters() const;
	NSString* getQueryString() const;
		
private:
	void assertPagesAreOneBase(OFISerializerKey* keyName, int value);
	void nviIo(OFISerializerKey* keyName, bool& value)						{ addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%d", value ? 1 : 0]); }	
	
	void nviIo(OFISerializerKey* keyName, int& value)							
	{
#ifdef _DEBUG
		assertPagesAreOneBase(keyName, value);
#endif
		addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%d", value]); 
	}	
	void nviIo(OFISerializerKey* keyName, unsigned int& value)				
	{ 
#ifdef _DEBUG
		assertPagesAreOneBase(keyName, value);
#endif
		addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%d", value]); 
	}
	void nviIo(OFISerializerKey* keyName, int64_t& value)						{ addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%qi", value]); }
	void nviIo(OFISerializerKey* keyName, float& value)						{ addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%f", value]); }
	void nviIo(OFISerializerKey* keyName, double& value)						{ addAsciiParameter(formatScoped(keyName), [NSString stringWithFormat:@"%f", value]); }
	void nviIo(OFISerializerKey* keyName, std::string& value)
	{
		OFRetainedPtr<NSString> str([NSString stringWithUTF8String:value.c_str()]);
		nviIo(keyName, str);
	}
	
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSData>& value)
	{
		addBlobParameter([NSString stringWithUTF8String:keyName->getAsString()], value);
	}
	
	void nviIo(OFISerializerKey* keyName, OFRetainedPtr<NSString>& value)	
	{
		addAsciiParameter(
			formatScoped(keyName), 
			mEscapeStrings ? OFStringUtility::convertToValidParameter(value).get() : value.get()
		);
	}

	void addAsciiParameter(NSString* name, NSString* value);
	void addBlobParameter(NSString* name, NSData* value);
	void serializeNumElementsInScopeSeries(unsigned int& count);
	
	const OFRTTI* beginDecodeType();
	void endDecodeType();	
	void beginEncodeType(const OFRTTI* typeToEncode);
	void endEncodeType();
	
	NSString* formatScoped(OFISerializerKey* keyName);
	NSMutableString* getCurrentScope();

	OFPointer<OFISerializer> createSerializerForInnerStreamOfType(const OFRTTI* type);
	void storeInnerStreamOfType(OFISerializer* innerResourceStream, const OFRTTI* type);
	
	typedef std::vector< OFPointer<OFHttpQueryParameter> > ParameterList;
	ParameterList mParameters;
	bool mEscapeStrings;
};