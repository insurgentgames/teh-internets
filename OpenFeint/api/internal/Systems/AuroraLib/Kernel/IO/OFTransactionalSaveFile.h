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

class OFISerializer;

class OFTransactionalSaveFile : public OFSmartObject
{
public:
	OFTransactionalSaveFile() {}
	
	OFTransactionalSaveFile(
		OFRetainedPtr<NSString> fileName,
		OFRetainedPtr<NSObject> delegate,
		SEL onLoad,
		SEL onSave,
		SEL onFailedPreviousSave
	);
	
	void attemptLoad();
	void writeAndCommit();

	void writeNewFile();
	void commitNewFile();
	
	static NSString* getSavePathForFile(NSString* fileName);
	
private:
	NSString* getNewFileFullPath() const;
	NSString* getBackupPath() const;
	
	OFRetainedPtr<NSString> mFileName;
	OFRetainedPtr<NSObject> mDelegate;
	SEL mOnLoad;
	SEL mOnSave;
	SEL mOnFailedPreviousSave;
};

///////////////////////////////////////////////////////////////////////////

@interface OFISerializerOCWrapper : NSObject
{
	OFISerializer* mStream;
}

@property (readonly) OFISerializer* stream;

- (id) initWithStream:(OFISerializer*)stream;

@end