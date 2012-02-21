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

#import "OFOnlineStatusCell.h"


@implementation OFOnlineStatusCell

@synthesize status, textLabel;

- (void)dealloc
{
    self.status = nil;
    self.textLabel = nil;
    [super dealloc];
}

- (void)onResourceChanged:(OFResource*)resource
{
    OFAssert([resource isKindOfClass:[OFOnlineStatus class]], @"Expected resource to be an OFOnlineStatus");
    self.status = (OFOnlineStatus*)resource;
    
    NSString *statusText = status.isOnline ? @"ONLINE" : @"offline";
    textLabel.text = [NSString stringWithFormat:@"%@ is %@", status.user.name, statusText];
}

@end
