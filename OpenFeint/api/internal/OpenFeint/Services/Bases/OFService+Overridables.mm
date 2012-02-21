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

#import "OFDependencies.h"
#import "OFService+Overridables.h"
#import "OFControllerHelpersCommon.h"
#import "OFResourceNameMap.h"
#import "OFPointer.h"

@implementation OFService ( Overridables )

+ (void) getIndexOnSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	/// @note	if having a default index action does not make sense for your resource, consider
	///			overriding the location that this request is being made from to invoke your
	///			own custom request.
	
	ASSERT_OVERRIDE_MISSING;
}

+ (void) getShowWithId:(NSString*)resourceId onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	ASSERT_OVERRIDE_MISSING;
}

- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	ASSERT_OVERRIDE_MISSING;
}

- (OFService*)sharedInstance
{
	ASSERT_OVERRIDE_MISSING;
	return NULL;
}

- (void)registerPolledResources:(OFPoller*)poller
{
}

@end
