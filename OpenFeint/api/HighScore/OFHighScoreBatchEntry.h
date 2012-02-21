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

#include "OFDependencies.h"
#include "OFRetainedPtr.h"
#include "OFISerializer.h"


class OFHighScoreBatchEntry : public OFSmartObject
{
public:
	OFHighScoreBatchEntry(OFISerializer* stream);
	OFHighScoreBatchEntry(NSString* _leaderboardId, int64_t _score, NSString* _displayText = nil, NSString* _customData = nil);
	OFHighScoreBatchEntry();
	void serialize(OFISerializer* stream);
	
public:
	OFRetainedPtr<NSString> leaderboardId;
	OFRetainedPtr<NSString> displayText;
	OFRetainedPtr<NSString> customData;
	int64_t score;
};

typedef std::vector<OFPointer<OFHighScoreBatchEntry> >  OFHighScoreBatchEntrySeries;
