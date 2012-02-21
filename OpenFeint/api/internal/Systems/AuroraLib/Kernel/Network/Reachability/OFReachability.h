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

#import <SystemConfiguration/SystemConfiguration.h>

#import <list>
#import "OFBase.h"
#import "OFIReachabilityObserver.h"

class OFReachability
{
OFDeclareSingleton(OFReachability);
public:
	~OFReachability();

	NetworkReachability gameServerReachability();
	bool isGameServerReachable();
	
	// Warning: You cannot invoke these from an OFIReachabilityObserver callback
	void addObserver(OFIReachabilityObserver* observer);
	void removeObserver(OFIReachabilityObserver* observer);
	
private:
	static void setIsTargetReachableAccordingToFlags(OFReachability* me, SCNetworkReachabilityFlags flags);
	static void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);
	void updateNetworkReachabilityNow();
	void notifyObservers(NetworkReachability oldReachbilityFlags);
	
	NetworkReachability mGameServerReachability;
	SCNetworkReachabilityRef mReachabilityRef;
	
	typedef std::list<OFIReachabilityObserver*> ObserverSeries;
	ObserverSeries mObservers;
};