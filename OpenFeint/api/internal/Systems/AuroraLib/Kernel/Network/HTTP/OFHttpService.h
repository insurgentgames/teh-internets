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

#include "OFSmartObject.h"
#include "OFHttpServiceObserver.h"
#include "OFHttpRequestObserver.h"
#include "OFHttpServiceRequestContainer.h"

class OFHttpService : public OFSmartObject, public OFHttpRequestObserver
{
public:
	OFHttpService(OFRetainedPtr<NSString> baseUrl, bool cookies = false);

	virtual void startRequest(NSString* path, NSString* httpMethod, NSData* httpBody, NSString* email, NSString* password, OFPointer<OFIHttpRequestUserData> userData, NSString* multiPartBoundary, OFHttpServiceObserver* requestSpecificObserver);
	virtual void startRequest(NSString* path, NSString* httpMethod, NSData* httpBody, OFHttpServiceObserver* requestSpecificObserver);

	// Note: No callbacks are invoked on any observers. All outstanding request are just closed
	virtual void cancelAllRequests();

	void onFinishedDownloading(OFHttpRequest* info);
	void onFailedDownloading(OFHttpRequest* info);	
	
	bool handlesCookies() const { return mHandleCookies; }
	void setHandlesCookies(bool cookies) { mHandleCookies = cookies; }
	bool hasCookies() const;
	int countCookies() const;
	NSArray* getCookies() const;
	void addCookies(NSArray* cookies);
		
private:
	OFRetainedPtr<NSString> mBaseUrl;
	bool mHandleCookies;
	
	typedef std::vector<OFHttpServiceRequestContainer> RequestContainerSeries;
	RequestContainerSeries mRequests;
};