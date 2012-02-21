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

#include <map>
#include "OFHashedString.h"

#ifdef _DEBUG

#define DEBUG_SHOW_FULLPATH NO

enum OFLogLevel
{
	OFErrorLogLevel = 0,
	OFWarningLogLevel = 1,
	OFInfoLogLevel = 2,
	OFDebugLogLevel = 3,
};

@interface OFLogger : NSObject
{
	const char* mTypeString;
	OFSdbmHashedString mType;
	OFLogLevel mLevel;
	OFLogLevel mDefaultLevel;
	std::map<OFSdbmHashedString, OFLogLevel> mLevels;
}

+ (OFLogger*)Instance;
- (void)setDefaultLevel:(OFLogLevel)level;
- (void)setLevel:(const char*)strName level:(OFLogLevel)level;
- (bool)hasLevel:(const char*)strName level:(OFLogLevel)level;
- (void)output:(char const*)fileName lineNumber:(int)lineNumber input:(const char*)input, ...;
@end

#define OFLogDefaultLevel(lvl)				[[OFLogger Instance] setDefaultLevel:lvl]
#define OFLogLevel(type,lvl)				[[OFLogger Instance] setLevel:#type level:lvl]
#define OFLogWithLevel(lvl,type,format,...)	{ if ([[OFLogger Instance] hasLevel:#type level:lvl]) [[OFLogger Instance] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]; }
#define OFLogError(type,format,...)			OFLogWithLevel(OFErrorLogLevel, type, format, ##__VA_ARGS__)
#define OFLogWarning(type,format,...)		OFLogWithLevel(OFWarningLogLevel, type, format, ##__VA_ARGS__)
#define OFLogInfo(type,format,...)			OFLogWithLevel(OFInfoLogLevel, type, format, ##__VA_ARGS__)
#define OFLogDebug(type,format,...)			OFLogWithLevel(OFDebugLogLevel, type, format, ##__VA_ARGS__)

#else //_DEBUG

#define OFLogDefaultLevel(lvl)				(void)0
#define OFLogLevel(type,lvl)				(void)0
#define OFLogWithLevel(lvl,type,format,...)	(void)0
#define OFLogError(type,format,...)			(void)0
#define OFLogWarning(type,format,...)		(void)0
#define OFLogInfo(type,format,...)			(void)0
#define OFLogDebug(type,format,...)			(void)0
	
#endif //_DEBUG
