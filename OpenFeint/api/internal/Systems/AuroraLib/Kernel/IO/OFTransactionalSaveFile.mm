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

#include "OFTransactionalSaveFile.h"
#include "OFBinarySdbmKeyedWriter.h"
#include "OFBinarySdbmKeyedReader.h"
#include "OFBinarySink.h"
#include "OFBinarySource.h"

OFTransactionalSaveFile::OFTransactionalSaveFile(
	OFRetainedPtr<NSString> fileName,
	OFRetainedPtr<NSObject> delegate,
	SEL onLoad,
	SEL onSave,
	SEL onFailedPreviousSave
)
: mFileName(fileName)
, mDelegate(delegate)
, mOnLoad(onLoad)
, mOnSave(onSave)
, mOnFailedPreviousSave(onFailedPreviousSave)
{
}

NSString* OFTransactionalSaveFile::getBackupPath() const
{
	return getSavePathForFile([NSString stringWithFormat:@"%@.bak", mFileName.get()]);
}

NSString* OFTransactionalSaveFile::getSavePathForFile(NSString* fileName)
{
	NSArray* folders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);	
	return [[folders objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

void OFTransactionalSaveFile::attemptLoad()
{
	NSString* backupFilePath = getBackupPath();
	NSString* newFilePath = getNewFileFullPath();
	NSString* liveFilePath = getSavePathForFile(mFileName.get());
		
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if([fileManager fileExistsAtPath:newFilePath])
	{
		OFLog(@"Detected previous save failed (%@). Continuing anyway...", mFileName.get());
		[mDelegate.get() performSelector:mOnFailedPreviousSave withObject:nil];
	}
	
	
	NSString* fileToLoad = liveFilePath;
	if(![fileManager fileExistsAtPath:liveFilePath])
	{	
		OFLog(@"Missing live version of file (%@). Attempting to load archive...", mFileName.get());
		
		if([fileManager fileExistsAtPath:backupFilePath])
		{
			fileToLoad = backupFilePath;
		}
		else
		{
			// We could attempt to load an archive here. But, realistically, this will never happen.
			OFLog(@"Failed to find a valid file to load %@. Critical Error.", mFileName.get());
		}
	}

	std::auto_ptr<OFISerializer> stream(new OFBinarySdbmKeyedReader(new OFBinaryFileSource([fileToLoad UTF8String])));
	[mDelegate.get() performSelector:mOnLoad withObject:[[[OFISerializerOCWrapper alloc] initWithStream:stream.get()] autorelease]];
}

void OFTransactionalSaveFile::writeAndCommit()
{
	writeNewFile();
	commitNewFile();
}	

NSString* OFTransactionalSaveFile::getNewFileFullPath() const
{
	return getSavePathForFile([NSString stringWithFormat:@"%@.new", mFileName.get()]);
}

void OFTransactionalSaveFile::writeNewFile()
{
	NSString* fileName = getNewFileFullPath();
		
	std::auto_ptr<OFISerializer> stream(new OFBinarySdbmKeyedWriter(new OFBinaryFileSink([fileName UTF8String])));
	[mDelegate.get() performSelector:mOnSave withObject:[[[OFISerializerOCWrapper alloc] initWithStream:stream.get()] autorelease]];
}

void OFTransactionalSaveFile::commitNewFile()
{
	NSString* backupFilePath = getBackupPath();
	NSString* newFilePath = getNewFileFullPath();
	NSString* liveFilePath = getSavePathForFile(mFileName.get());
		
	NSFileManager* fileManager = [NSFileManager defaultManager];

	NSError* error = nil;

	if([fileManager fileExistsAtPath:backupFilePath])
	{
		NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterLongStyle];

		NSString* archiveFileName = [NSString stringWithFormat:@"%@.archive.%@", mFileName.get(), [dateFormatter stringFromDate:[NSDate date]]];
		OFLog(@"Detected previous commit has failed on file: %@. Moving out of the way as timestamped archive: %@", mFileName.get(), archiveFileName);

		NSString* archiveFilePath = getSavePathForFile(archiveFileName);		
		[fileManager moveItemAtPath:backupFilePath toPath:archiveFilePath error:&error];
	}
	
	if(![fileManager moveItemAtPath:liveFilePath toPath:backupFilePath error:&error])
	{
		OFLog(@"Failed backing up %@. Error: %@", mFileName.get(), [error localizedDescription]);
	}
	
	if(![fileManager moveItemAtPath:newFilePath toPath:liveFilePath error:&error])
	{
		OFLog(@"Failed committing new version. Restoring previous. (%@) Error: %@", mFileName.get(), [error localizedDescription]);
		
		if(![fileManager moveItemAtPath:backupFilePath toPath:liveFilePath error:&error])
		{
			OFLog(@"Failed restoring previous version. A critical error has occurred. (%@) Error: %@", mFileName.get(), [error localizedDescription]);
		}
		
		return;
	}
	
	if(![fileManager removeItemAtPath:backupFilePath error:&error])
	{
		OFLog(@"Failed removing backup of %@. Error: %@", mFileName.get(), [error localizedDescription]);
		return;
	}
}

@implementation OFISerializerOCWrapper

@synthesize stream = mStream;

- (id) initWithStream:(OFISerializer*)stream
{
	self = [super init];
	if (self != nil)
	{
		mStream = stream;
	}
	return self;
}

@end

