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

class OFSettings 
{
OFDeclareSingleton(OFSettings);
public:
	NSString* getServerUrl() const						{ return mServerUrl; }
	NSString* getPresenceHost() const					{ return mPresenceHost; }
	NSString* getFacebookApplicationKey() const			{ return mFacebookApplicationKey; }
	NSString* getFacebookCallbackServerUrl() const		{ return mFacebookCallbackServerUrl; }
	NSString* getClientBundleIdentifier() const			{ return mClientBundleIdentifier; }
	NSString* getClientBundleVersion() const			{ return mClientBundleVersion; }
	NSString* getClientLocale() const					{ return mClientLocale; }
	NSString* getClientDeviceType() const				{ return mClientDeviceType; }
	NSString* getClientDeviceSystemName() const			{ return mClientDeviceSystemName; }
	NSString* getClientDeviceSystemVersion() const		{ return mClientDeviceSystemVersion; }	
	
private:
	void discoverLocalConfiguration();
	void loadSettingsFile();
	
	OFRetainedPtr<NSString> mServerUrl;
	OFRetainedPtr<NSString> mPresenceHost;
	OFRetainedPtr<NSString> mFacebookCallbackServerUrl;
	OFRetainedPtr<NSString> mFacebookApplicationKey;
	OFRetainedPtr<NSString> mClientBundleIdentifier;
	OFRetainedPtr<NSString> mClientBundleVersion;
	OFRetainedPtr<NSString> mClientLocale;
	OFRetainedPtr<NSString> mClientDeviceType;
	OFRetainedPtr<NSString> mClientDeviceSystemName;
	OFRetainedPtr<NSString> mClientDeviceSystemVersion;	
};