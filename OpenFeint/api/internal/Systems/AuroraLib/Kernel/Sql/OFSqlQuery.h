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

class OFSqlQuery
{
OFDeclareNonCopyable(OFSqlQuery);
	
public:
	OFSqlQuery();
	OFSqlQuery(struct sqlite3* dbHandle, const char* queryString);
	OFSqlQuery(struct sqlite3* dbHandle, const char* queryString, bool doAssert);
	~OFSqlQuery();
	
	void reset(struct sqlite3* dbHandle, const char* queryString);
	void reset(struct sqlite3* dbHandle, const char* queryString, bool doAssert);
	void destroyQueryNow();
	
	// ------------------------------------------------------------
	// These should be invoked before calling execute to set named
	// parameters (if any) in the query
	// ------------------------------------------------------------
	void bind(const char* namedParameter, NSString* value);
	void bind(const char* namedParameter, const void* value, unsigned int size);
		
	// ------------------------------------------------------------
	// Sample multi-row usage:
	//
	//	OFSqlQuery example(...)
	// ...
	// while(example.execute())
	// {
	//		// Do stuff
	// }
	//
	// ------------------------------------------------------------		
	bool execute();
	bool execute(bool doAssert);
	void resetQuery();
	bool hasReachedEnd();
	void step();
	
	int getLastStepResult() { return mLastStepResult; }

	// ------------------------------------------------------------
	// These act on the current row in the result set
	// ------------------------------------------------------------
	int getInt(const char* columnName);
	int64_t getInt64(const char* columnName);
	int getBool(const char* columnName);
	const char* getText(const char* columnName);
	void getBlob(const char* columnName, const char*& blobData, unsigned int& blobSizeInBytes);
	
private:
	unsigned int safeGetParamIndex(const char* namedParameter) const;
	unsigned int safeGetColumnIndex(const char* columnName) const;
	void ensureQueryIsReset();
	
	int mLastStepResult;
	struct sqlite3* mDbHandle;
	struct sqlite3_stmt* mCompiledStatement;
	const char* mQueryString;
	
	std::vector<OFSdbmHashedString> mColumnIndices;
};
