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

#include "OFHttpService.h"
#include "OFHttpRequest.h"

OFImplementRTTI(OFIHttpRequestUserData, OFSmartObject);

OFHttpService::OFHttpService(OFRetainedPtr<NSString> baseUrl, bool cookies)
: mBaseUrl(baseUrl)
, mHandleCookies(cookies)
{
}

void OFHttpService::startRequest(NSString* path, NSString* httpMethod, NSData* httpBody, OFHttpServiceObserver* requestSpecificObserver)
{
	startRequest(path, httpMethod, httpBody, nil, nil, NULL, nil, requestSpecificObserver);
}

void OFHttpService::startRequest(NSString* path, NSString* httpMethod, NSData* httpBody, NSString* email, NSString* password, OFPointer<OFIHttpRequestUserData> userData, NSString* multiPartBoundary, OFHttpServiceObserver* requestSpecificObserver)
{
	OFRetainedPtr<OFHttpRequest> request = [OFHttpRequest httpRequestWithBase:mBaseUrl withObserver:this withCookies:mHandleCookies];
		
	OFHttpServiceRequestContainer container(request, userData, requestSpecificObserver);
	mRequests.push_back(container);
	
	[request.get() 
		startRequestWithPath:path
		withMethod:httpMethod
		withBody:httpBody
		withEmail:email
		withPassword:password
		multiPartBoundary:multiPartBoundary];
}

void OFHttpService::onFinishedDownloading(OFHttpRequest* info)
{
	RequestContainerSeries::iterator sit = std::find(mRequests.begin(), mRequests.end(), info);
	if(sit == mRequests.end())
	{
		return;
	}
	
	if(sit->getObserver())
	{
		sit->getObserver()->onFinishedDownloading(&(*sit));
	}	
	
	sit = std::find(mRequests.begin(), mRequests.end(), info);
	mRequests.erase(sit);
}

void OFHttpService::onFailedDownloading(OFHttpRequest* info)
{
	RequestContainerSeries::iterator sit = std::find(mRequests.begin(), mRequests.end(), info);
	if(sit == mRequests.end())
	{
		return;
	}
	
	if(sit->getObserver())
	{
		sit->getObserver()->onFailedDownloading(&(*sit));
	}	
	
	sit = std::find(mRequests.begin(), mRequests.end(), info);
	mRequests.erase(sit);
}

bool OFHttpService::hasCookies() const
{
	return [OFHttpRequest hasCookies:mBaseUrl];
}

int OFHttpService::countCookies() const
{
	return [OFHttpRequest countCookies:mBaseUrl];
}

NSArray* OFHttpService::getCookies() const
{
	return [OFHttpRequest getCookies:mBaseUrl];
}

void OFHttpService::addCookies(NSArray* cookies)
{
	return [OFHttpRequest addCookies:cookies withBase:mBaseUrl];
}

void OFHttpService::cancelAllRequests()
{
	RequestContainerSeries::iterator it = mRequests.begin();
	RequestContainerSeries::iterator itEnd = mRequests.end();	
	for(; it != itEnd; ++it)
	{
		OFHttpServiceRequestContainer& request = *it;
		request.cancelImmediately();
	}
}