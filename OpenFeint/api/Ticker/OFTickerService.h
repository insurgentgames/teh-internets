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

@interface OFTickerService : OFService

OPENFEINT_DECLARE_AS_SERVICE(OFTickerService);

////////////////////////////////////////////////////////////
///
/// getPage
/// 
/// @param pageIndex	1 based page index
/// @param onSuccess	Delegate is passed an OFPaginatedSeries with OFTicker objects.
/// @param onFailure	Delegate is called without parameters
///
///
////////////////////////////////////////////////////////////
+ (void) getPage:(NSInteger)pageIndex onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure;

@end
