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
#import "OFFormControllerHttpServiceObserver.h"
#import "OFFormControllerHelper+Submit.h"

// citron todo: hack
@interface OFFormControllerHelper ()
- (void)_onRequestResponded:(OFHttpServiceRequestContainer*)response;
- (void)_onRequestErrored:(OFHttpServiceRequestContainer*)response;
@end

OFFormControllerHttpServiceObserver::OFFormControllerHttpServiceObserver(OFFormControllerHelper* owner)
: mOwner(owner)
{
}
	
void OFFormControllerHttpServiceObserver::onFinishedDownloading(OFHttpServiceRequestContainer* info)
{
	[mOwner _onRequestResponded:info];
}

void OFFormControllerHttpServiceObserver::onFailedDownloading(OFHttpServiceRequestContainer* info)
{
	[mOwner _onRequestErrored:info];	
}

