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
#import "IPhoneOSIntrospection.h"

#include <sys/types.h>
#include <sys/sysctl.h>

bool is2PointOhSystemVersion()
{
	static bool is2PointOh = false;
	static bool hasDoneTheWork = false;
	
	if (!hasDoneTheWork)
	{
		hasDoneTheWork = true;
		NSArray* versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
		NSString* majorVersionNumber = (NSString*)[versionComponents objectAtIndex:0];
		is2PointOh = [majorVersionNumber isEqualToString:@"2"];
	}
	
	return is2PointOh;
}

bool is3PointOhSystemVersion()
{
	static bool is3PointOh = false;
	static bool hasDoneTheWork = false;
	
	if (!hasDoneTheWork)
	{
		hasDoneTheWork = true;
		NSArray* versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
		NSString* majorVersionNumber = (NSString*)[versionComponents objectAtIndex:0];
		is3PointOh = [majorVersionNumber isEqualToString:@"3"];
	}
	
	return is3PointOh;
}

NSString* getHardwareVersion()
{
	size_t size = 0;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	
	char* tempString = (char*)malloc(size);
	sysctlbyname("hw.machine", tempString, &size, NULL, 0);
	
	NSString* hardwareType = [NSString stringWithUTF8String:tempString];
	free(tempString);
	
	return hardwareType;
}