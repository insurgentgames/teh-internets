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

#include "OFHttpQueryParameter.h"
#include "OFOutputSerializer.h"
#import "MPURLRequestParameter.h"

OFHttpQueryParameter::OFHttpQueryParameter(NSString* name)
: mName(name)
{
}

NSString* OFHttpQueryParameter::getName() const
{
	return mName;
}

void OFHttpQueryParameter::rename(NSString* newName)
{
	mName = newName;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

OFHttpAsciiParameter::OFHttpAsciiParameter(NSString* parameterName, NSString* parameterValue)
: OFHttpQueryParameter(parameterName)
, mValue(parameterValue)
{
}

NSString* OFHttpAsciiParameter::getAsUrlParameter() const
{
	return [NSString stringWithFormat:@"%@=%@", mName.get(), mValue.get()];
}

MPURLRequestParameter* OFHttpAsciiParameter::getAsMPURLRequestParameter() const
{
	NSString* value = mValue.get() ? mValue.get() : @"";
	return [[[MPURLRequestParameter alloc] initWithName:getName() andValue:value] autorelease];
}

void OFHttpAsciiParameter::appendToMultipartFormData(NSMutableData* multipartStream) const
{
	const NSString* headerContentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", mName.get()];
	const NSString* headerSpacer = @"\r\n";
	
	[multipartStream appendData:[headerContentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
	[multipartStream appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
	[multipartStream appendData:[mValue.get() dataUsingEncoding:NSUTF8StringEncoding]];	
	[multipartStream appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
}

NSString* OFHttpAsciiParameter::getValueAsString() const
{
	return mValue.get();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
#pragma mark OFHttpBinaryParameter

OFHttpBinaryParameter::OFHttpBinaryParameter(NSString* parameterName, OFPointer<OFBinaryMemorySink> binaryData, NSString* dataType)
: OFHttpQueryParameter(parameterName)
, mDataType(dataType)
, mData(binaryData)
{
}

NSString* OFHttpBinaryParameter::getAsUrlParameter() const
{
	OFAssert(0, "Something proably went wrong. Attempting to get a binary data parameter for use in a URL query string.");
	return @"";
}

MPURLRequestParameter* OFHttpBinaryParameter::getAsMPURLRequestParameter() const
{
	return [[[MPURLRequestParameter alloc] initWithName:getName() andBlob:mData->getNSData() andDataType:mDataType.get()] autorelease];
}

void OFHttpBinaryParameter::appendToMultipartFormData(NSMutableData* multipartStream) const
{
	const NSString* headerContentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.%@\"\r\n", mName.get(), mName.get(), mDataType.get()];
	const NSString* headerContentType =  [NSString stringWithFormat:@"Content-Type: %@\r\n", mDataType.get()];
	const NSString* headerContentEncoding =  [NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n"];	
	const NSString* headerSpacer = @"\r\n";
	
	[multipartStream appendData:[headerContentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
	[multipartStream appendData:[headerContentType dataUsingEncoding:NSUTF8StringEncoding]];
	[multipartStream appendData:[headerContentEncoding dataUsingEncoding:NSUTF8StringEncoding]];
	[multipartStream appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];
	[multipartStream appendBytes:mData->getDataBuffer() length:mData->getDataSize()];
	[multipartStream appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
}

NSString* OFHttpBinaryParameter::getValueAsString() const
{
	OFAssert(0, "Something proably went wrong. Attempting to get a binary data parameter for use in a URL query string.");
	return @"";
}