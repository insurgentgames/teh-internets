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

#import "OFCloudStorageBlob.h"
#import "OFCloudStorageService.h"
#import "OFResourceDataMap.h"

#import "OFDependencies.h"
#import "OpenFeint.h"
#import "OpenFeint+Private.h"
#import "OFService+Private.h"
#import "OFActionRequestType.h"
#import "OFNotificationData.h"
#import "OFBlobDownloadObserver.h"
#import "OFProvider.h"
#import "OFDelegateChained.h"
#import "MPOAuthAPIRequestLoader.h"

#import "OFHttpNestedQueryStringWriter.h"
//class OFHttpNestedQueryStringWriter;

#define kCloudStorageBlobSizeMax	(256 * 1024)

OPENFEINT_DEFINE_SERVICE_INSTANCE(OFCloudStorageService)

@implementation OFCloudStorageService

OPENFEINT_DEFINE_SERVICE(OFCloudStorageService);


- (void) populateKnownResources:(OFResourceNameMap*)namedResources
{
	// I don't think we need CloudStorageBlob to be a full fledged resource yet.
	// Maybe we will if this service tries to get more sophisticated.
	// In the meantime we can pacify OFResource checks by registering it anyway.
	//
	namedResources->addResource([OFCloudStorageBlob getResourceName], [OFCloudStorageBlob class]);
}


+ (void)uploadBlob:(NSData*) blob withKey:(NSString*) keyStr onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	if ( blob ) {
		NSUInteger blobLen = [blob length];
		
		// Enable the following line for diagnostic purposes.
		//OFLog(@"blob size: %i", (int)blobLen);
		
		if ( blobLen <= kCloudStorageBlobSizeMax ) {
			if ( [OFCloudStorageService keyIsValid: keyStr] ) {
				OFRetainedPtr<NSData> retainedData = blob;
				OFPointer<OFHttpNestedQueryStringWriter> params = new OFHttpNestedQueryStringWriter;
				
				params->io("key", keyStr);
				params->io("blob", retainedData);
				
				[[self sharedInstance] 
				 postAction:@"/cloud_stores"
				 withParameters:params
				 withSuccess:onSuccess
				 withFailure:onFailure
				 withRequestType:OFActionRequestSilent // OFActionRequestForeground would require non-nil notice
				 withNotice:nil
				];
			}else{
				onFailure.invoke();
			}
		}else{
			onFailure.invoke();
		}
	}else{
		onFailure.invoke();
	}
}


+ (void)downloadBlobWithKey:(NSString*) keyStr onSuccess:(const OFDelegate&)onSuccess onFailure:(const OFDelegate&)onFailure
{
	if ( [OFCloudStorageService keyIsValid: keyStr] ) {
		NSString *actionStr = [NSString stringWithFormat:@"cloud_stores/%@.blob", keyStr];
		
		[[OpenFeint provider] 
		 performAction:actionStr //@"cloud_stores/wa3.blob"
		 withParameters:nil
		 withHttpMethod:@"GET"
		 withSuccess:OFDelegate([self sharedInstance], @selector(onBlobDownloaded:nextCall:), onSuccess)
		 withFailure:onFailure
		 withRequestType:OFActionRequestSilent
		 withNotice:nil
		 requiringAuthentication:YES
		];
	}else{
		onFailure.invoke();
	}
}


- (void)onBlobDownloaded:(MPOAuthAPIRequestLoader*)loader nextCall:(OFDelegateChained*)nextCall
{
	[nextCall invokeWith:loader.data];
}


+ (BOOL)keyIsValid:(NSString*) keyStr{
	BOOL	validated = NO;
	int		keyLen = [keyStr length];
	int		idx;
	unichar	character;
	
	do { // once through
		if (keyLen <= 0) {
			break;
		}
		if (! [OFCloudStorageService charIsAlpha:[keyStr characterAtIndex:0]] ) {
			break;
		}
		for (idx = 1; idx < keyLen; idx++) {
			character = [keyStr characterAtIndex:idx];
			if (	! [OFCloudStorageService charIsAlpha:character]
				&&	! [OFCloudStorageService charIsNum:character]
				&&	! [OFCloudStorageService charIsPunctAllowedInKey:character]
			){
				break;
			}
		}
		if (idx < keyLen){
			break;
		}
		// Made it past all validation steps.
		validated = YES;
	} while (false); // once through
	
	return validated;
}


+ (BOOL)charIsAlpha:(unichar) character{
	return (	(0x0041 <= character)
			&&	(character <= 0x005A)
	)||(		(0x0061 <= character)
			&&	(character <= 0x007A)
	);
}


+ (BOOL)charIsNum:(unichar) character{
	return (	(0x0030 <= character)
			&&	(character <= 0x0039)
	);
}


+ (BOOL)charIsPunctAllowedInKey:(unichar) character{
	return (	(0x005F == character) // Underscore
			||	(0x002D == character) // Dash
		//	||	(0x002E == character) // Period (trouble?)
	);
}


@end
