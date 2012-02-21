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

#import "OFService.h"
#import "OFDelegate.h"

@class OFPoller;
class OFResourceNameMap;
template <typename _T> class OFPointer;

@interface OFService ( Overridables )

- (void) populateKnownResources:(OFResourceNameMap*)namedResources;
- (OFService*)sharedInstance;

// This is optional
+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
+ (void) getShowWithId:(NSString*)resourceId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;
- (void)registerPolledResources:(OFPoller*)poller;

@end
