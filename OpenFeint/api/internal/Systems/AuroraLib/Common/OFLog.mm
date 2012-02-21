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

#import "OFLog.h"

#ifdef _DEBUG

@implementation OFLogger

static OFLogger *sharedDebugInstance = nil;

/*---------------------------------------------------------------------*/
+ (OFLogger *) Instance
{
	@synchronized(self)
	{
		if (sharedDebugInstance == nil)
		{
			[[self alloc] init];
		}
	}
	return sharedDebugInstance;
}

/*---------------------------------------------------------------------*/
+ (id) allocWithZone:(NSZone *) zone
{
	@synchronized(self)
	{
		if (sharedDebugInstance == nil)
		{
			sharedDebugInstance = [super allocWithZone:zone];
			return sharedDebugInstance;
		}
	}
	return nil;
}

/*---------------------------------------------------------------------*/
- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

/*---------------------------------------------------------------------*/
- (id)retain
{
	return self;
}

/*---------------------------------------------------------------------*/
- (void)release
{
	// No action required...
}

/*---------------------------------------------------------------------*/
- (unsigned)retainCount
{
	return UINT_MAX;  // An object that cannot be released
}

/*---------------------------------------------------------------------*/
- (id)autorelease
{
	return self;
}

/*---------------------------------------------------------------------*/
- (void)setDefaultLevel:(OFLogLevel)level
{
	mDefaultLevel = level;
}

/*---------------------------------------------------------------------*/
- (void)setLevel:(const char*)strName level:(OFLogLevel)level
{
	OFSdbmHashedString type(strName);
	mLevels[type] = level;
}

/*---------------------------------------------------------------------*/
- (bool)hasLevel:(const char*)strName level:(OFLogLevel)level
{
	OFSdbmHashedString type(strName);
	int typeLevel = mDefaultLevel;
	std::map<OFSdbmHashedString, OFLogLevel>::iterator itr = mLevels.find(type);
	if (itr != mLevels.end())
	{
		typeLevel = itr->second;
	}
	
	if (typeLevel >= level)
	{
		mTypeString = strName;
		mType = type;
		mLevel = level;
		return true;
	}
	return false;
}

/*---------------------------------------------------------------------*/
- (void)output:(char const*)fileName lineNumber:(int)lineNumber input:(const char*)input, ...
{
	va_list argList;
	NSString *filePath, *formatStr, *nsInput;
	
	// Build the path string
	filePath = [[NSString alloc] initWithBytes:fileName length:strlen(fileName) encoding:NSUTF8StringEncoding];
	nsInput = [[NSString alloc] initWithBytes:input length:strlen(input) encoding:NSUTF8StringEncoding];
	
	// Process arguments, resulting in a format string
	va_start(argList, input);
	formatStr = [[NSString alloc] initWithFormat:nsInput arguments:argList];
	va_end(argList);
	
	// Call NSLog, prepending the filename and line number
	char const* levelStr = "";
	if (mLevel == OFErrorLogLevel)
		levelStr = " ERROR:";
	else if (mLevel == OFWarningLogLevel)
		levelStr = " WARNING:";
	OFLog(@"[%s]%s %@ (%s:%d)", mTypeString, levelStr, formatStr, [((DEBUG_SHOW_FULLPATH) ? filePath : [filePath lastPathComponent]) UTF8String], lineNumber);
	
	[filePath release];
	[formatStr release];
	[nsInput release];
}

@end

#endif //_DEBUG
