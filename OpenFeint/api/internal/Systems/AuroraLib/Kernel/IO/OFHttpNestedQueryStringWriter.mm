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

#import "OFHttpNestedQueryStringWriter.h"
#import "OFBinarySdbmKeyedWriter.h"
#import "MPURLRequestParameter.h"

OFImplementRTTI(OFHttpNestedQueryStringWriter, OFOutputSerializer);

OFHttpNestedQueryStringWriter::OFHttpNestedQueryStringWriter()
: mEscapeStrings(false)
{
	setSerializeResourcesExternally(false);
}

void OFHttpNestedQueryStringWriter::setShouldEscapeStrings(bool escapeStrings)
{
	mEscapeStrings = escapeStrings;
}

NSArray* OFHttpNestedQueryStringWriter::getQueryParametersAsMPURLRequestParameters() const
{
	NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:mParameters.size()];
	ParameterList::const_iterator it = mParameters.begin();
	ParameterList::const_iterator itEnd = mParameters.end();
	
	for(; it != itEnd; ++it)
	{
		[parameters addObject:(*it)->getAsMPURLRequestParameter()];
	}
	
	return parameters;
}

NSArray* OFHttpNestedQueryStringWriter::getQueryParameters() const
{
	NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:mParameters.size()];
	
	ParameterList::const_iterator it = mParameters.begin();
	ParameterList::const_iterator itEnd = mParameters.end();
	
	for(; it != itEnd; ++it)
	{
		[parameters addObject:(*it)->getAsUrlParameter()];
	}
	
	return parameters;
}
	
NSString* OFHttpNestedQueryStringWriter::getQueryString() const
{
	ParameterList::const_iterator it = mParameters.begin();
	ParameterList::const_iterator itEnd = mParameters.end();
	
	NSMutableString* data = [[[NSMutableString alloc] init] autorelease];
	
	for(; it != itEnd; ++it)
	{
		if (it != mParameters.begin())
		{
			[data appendString:@"&"];
		}
		
		[data appendString:(*it)->getAsUrlParameter()];		
	}
	
	return data;
}

void OFHttpNestedQueryStringWriter::assertPagesAreOneBase(OFISerializerKey* keyName, int value)
{
	static OFISerializer::StringKey sPageKey("page");
	if (keyName->equals(&sPageKey))
	{
		OFAssert(value > 0, @"All OpenFeint pagination indexes are base one.");
	}
}

const OFRTTI* OFHttpNestedQueryStringWriter::beginDecodeType()
{
	OFAssert(0, "Internal error. An output serializer should not be reading.");
	return 0;
}

void OFHttpNestedQueryStringWriter::endDecodeType()
{
}

void OFHttpNestedQueryStringWriter::beginEncodeType(const OFRTTI* typeToEncode)
{
}

void OFHttpNestedQueryStringWriter::endEncodeType()
{
}

NSMutableString* OFHttpNestedQueryStringWriter::getCurrentScope()
{
	NSMutableString* scoped = [[[NSMutableString alloc] init] autorelease];

	const ScopeDescriptorSeries& activeScopes = getActiveScopes();
	
	if(activeScopes.empty())
	{
		return scoped;
	}
	
	ScopeDescriptorSeries::const_iterator it = activeScopes.begin();
	ScopeDescriptorSeries::const_iterator itEnd = activeScopes.end();
		
	[scoped appendFormat:@"%s", it->scopeName->getAsString()];
	ScopeDescriptorSeries::const_iterator itPrevious = it;
	++it;
	
	for(; it != itEnd; ++it)
	{
		if(itPrevious->containsSeries)
		{
			[scoped appendFormat:@"[]"];
		}
		else
		{
			[scoped appendFormat:@"[%s]", it->scopeName->getAsString()];
		}
		
		itPrevious = it;
	}

	return scoped;
}

NSString* OFHttpNestedQueryStringWriter::formatScoped(OFISerializerKey* keyName)
{
	NSMutableString* scoped = getCurrentScope();
	
	if (getActiveScopes().empty())
	{
		[scoped appendFormat:@"%s", keyName->getAsString()];
	}
	else if(!isCurrentScopeASeries())
	{
		[scoped appendFormat:@"[%s]", keyName->getAsString()];
	}
	else
	{
		[scoped appendFormat:@"[]"];
	}
	
	return scoped;
}

bool OFHttpNestedQueryStringWriter::supportsKeys() const
{
	return true;
}

OFPointer<OFISerializer> OFHttpNestedQueryStringWriter::createSerializerForInnerStreamOfType(const OFRTTI* type)
{
	return new OFBinarySdbmKeyedWriter(new OFBinaryMemorySink(), false);
}

void OFHttpNestedQueryStringWriter::storeInnerStreamOfType(OFISerializer* innerResourceStream, const OFRTTI* type)
{
	OFBinaryKeyedWriter* writer = innerResourceStream->DynamicCast<OFBinaryKeyedWriter>();
	if(!writer)
	{
		OFAssert(0, "Expected type of inner stream writer is invalid. Something horrible went wrong!");
		return;
	}
	
	OFBinaryMemorySink* sink = writer->getDataSink()->DynamicCast<OFBinaryMemorySink>();
	if(!sink)
	{
		OFAssert(0, "Expected stream to have a memory sink. Something horrible went wrong");
		return;	
	}
	
	mParameters.push_back(new OFHttpBinaryParameter(getCurrentScope(), sink, [NSString stringWithUTF8String:writer->GetRTTI()->GetName()]));
}

void OFHttpNestedQueryStringWriter::addAsciiParameter(NSString* name, NSString* value)
{
	mParameters.push_back(new OFHttpAsciiParameter(name, value));
}

void OFHttpNestedQueryStringWriter::addBlobParameter(NSString* name, NSData* value)
{
	mParameters.push_back(new OFHttpBinaryParameter(name, new OFBinaryMemorySink(value), @"blob"));
}

void OFHttpNestedQueryStringWriter::serializeNumElementsInScopeSeries(unsigned int& count)
{
	// Citron note: Do nothing. We don't need to record this value
}