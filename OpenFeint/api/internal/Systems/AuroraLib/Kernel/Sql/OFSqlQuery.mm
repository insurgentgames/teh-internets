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


#include "OFSqlQuery.h"

#include <sqlite3.h>

#define SQLITE_CHECK(x,doAssert)											\
	{																	\
		int result = x;											\
		if(doAssert && result != SQLITE_OK)									\
		{																\
			OFLog(@"Failed executing: %s", ""#x);			\
			OFLog(@"   Result code: %d", result);			\
			OFLog(@"   %s", sqlite3_errmsg(mDbHandle));	\
			OFLog(@"   in query: %s", mQueryString);		\
			OFAssert(0, "");										\
		}																\
	}

OFSqlQuery::OFSqlQuery()
: mLastStepResult(SQLITE_OK)
, mDbHandle(0)
, mCompiledStatement(0)
, mQueryString(NULL)
{
}

OFSqlQuery::OFSqlQuery(sqlite3* dbHandle, const char* queryString)
: mLastStepResult(SQLITE_OK)
, mDbHandle(dbHandle)
, mCompiledStatement(0)
, mQueryString(queryString)
{		
	reset(dbHandle, queryString);
}


OFSqlQuery::OFSqlQuery(sqlite3* dbHandle, const char* queryString, bool doAssert)
: mLastStepResult(SQLITE_OK)
, mDbHandle(dbHandle)
, mCompiledStatement(0)
, mQueryString(queryString)
{		
	reset(dbHandle, queryString, doAssert);
}

void OFSqlQuery::reset(sqlite3* dbHandle, const char* queryString)
{
	reset(dbHandle, queryString, true);
}

void OFSqlQuery::reset(sqlite3* dbHandle, const char* queryString, bool doAssert)
{	
	destroyQueryNow();
	
	mDbHandle = dbHandle;
	mQueryString = queryString;
	mLastStepResult = SQLITE_OK;

	const unsigned int queryLength = strlen(queryString);
	SQLITE_CHECK(sqlite3_prepare_v2(dbHandle, queryString, queryLength, &mCompiledStatement, NULL), doAssert);
	
	mColumnIndices.clear();
	const unsigned int numColumnsInRow = sqlite3_column_count(mCompiledStatement);
	for(unsigned int i = 0; i < numColumnsInRow; ++i)
	{	
		mColumnIndices.push_back(OFSdbmHashedString(sqlite3_column_name(mCompiledStatement, i)));
	}	
}

OFSqlQuery::~OFSqlQuery()
{
	destroyQueryNow();
}

void OFSqlQuery::destroyQueryNow()
{
	if(mCompiledStatement)
	{
		sqlite3_finalize(mCompiledStatement);
	}
	
	mCompiledStatement = NULL;
	mDbHandle = NULL;	
	mQueryString = NULL;
}

bool OFSqlQuery::execute()
{
	return execute(true);
}

bool OFSqlQuery::execute(bool doAssert)
{	
	mLastStepResult = sqlite3_step(mCompiledStatement);

	if( doAssert && 
	   !(mLastStepResult == SQLITE_OK ||
		 mLastStepResult == SQLITE_ROW || 
		 mLastStepResult == SQLITE_DONE ||
		 mLastStepResult == SQLITE_CONSTRAINT))
	{
		OFLog(@"Failed stepping query");
		OFLog(@"   Result code: %d", mLastStepResult);	
		OFLog(@"   %s", sqlite3_errmsg(mDbHandle));
		OFLog(@"   in query: %s", mQueryString);	
		OFAssert(0, "");
	}

	if(mLastStepResult == SQLITE_DONE)
	{
		resetQuery();
	}

	return mLastStepResult == SQLITE_ROW;
}

void OFSqlQuery::resetQuery()
{
	sqlite3_reset(mCompiledStatement);
	mLastStepResult = SQLITE_OK;
}

bool OFSqlQuery::hasReachedEnd()
{
	return mLastStepResult != SQLITE_ROW;
}

void OFSqlQuery::step()
{
	execute();
}

int OFSqlQuery::getInt(const char* columnName)
{
	const unsigned int columnIndex = safeGetColumnIndex(columnName);
	return sqlite3_column_int(mCompiledStatement, columnIndex);
}

int64_t OFSqlQuery::getInt64(const char* columnName)
{
	const unsigned int columnIndex = safeGetColumnIndex(columnName);
	return sqlite3_column_int64(mCompiledStatement, columnIndex);
}

int OFSqlQuery::getBool(const char* columnName)
{
	return getInt(columnName) != 0;
}

const char* OFSqlQuery::getText(const char* columnName)
{
	const unsigned int columnIndex = safeGetColumnIndex(columnName);
	return (const char*)sqlite3_column_text(mCompiledStatement, columnIndex);
}

void OFSqlQuery::getBlob(const char* columnName, const char*& blobData, unsigned int& blobSizeInBytes)
{
	const unsigned int columnIndex = safeGetColumnIndex(columnName);
	
	blobData = static_cast<const char*>(sqlite3_column_blob(mCompiledStatement, columnIndex));
	blobSizeInBytes = sqlite3_column_bytes(mCompiledStatement, columnIndex);
}

void OFSqlQuery::bind(const char* namedParameter, NSString* value)
{	
	ensureQueryIsReset();
	
	SQLITE_CHECK(sqlite3_bind_text(mCompiledStatement, safeGetParamIndex(namedParameter), [value UTF8String], -1, SQLITE_TRANSIENT),true);
}

void OFSqlQuery::bind(const char* namedParameter, const void* value, unsigned int valueSize)
{	
	ensureQueryIsReset();
	
	SQLITE_CHECK(sqlite3_bind_blob(mCompiledStatement, safeGetParamIndex(namedParameter), value, valueSize, SQLITE_TRANSIENT), true);
}

void OFSqlQuery::ensureQueryIsReset()
{
}

unsigned int OFSqlQuery::safeGetParamIndex(const char* namedParameter) const
{
	unsigned int index =	sqlite3_bind_parameter_index(mCompiledStatement, [[NSString stringWithFormat:@":%s", namedParameter] UTF8String]);
	if(index == 0)
	{
		OFLog(@"Invalid named parameter :%s in query: %s", namedParameter, mQueryString);
		OFAssert(0, "");
	}
	
	return index;
}

unsigned int OFSqlQuery::safeGetColumnIndex(const char* columnName) const
{	
	const OFSdbmHashedString hashedName(columnName);
	for(unsigned int i = 0; i < mColumnIndices.size(); ++i)
	{
		if(mColumnIndices[i] == hashedName)
		{
			return i;
		}
	}
	
	OFLog(@"Invalid column name in result-set for: %s", mQueryString);
	OFAssert(0, "");
	return mColumnIndices.size();
}