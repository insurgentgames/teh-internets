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
#import "OFFormControllerHelper+Submit.h"
#import "OFFormControllerHelper+Overridables.h"

#import "OFViewDataGetter.h"
#import "OFHttpNestedQueryStringWriter.h"
#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OFXmlDocument.h"
#import "OFXmlElement.h"
#import "OFProvider.h"
#import "OpenFeint+Private.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFLoadingController.h"

static NSString* parseErrorXml(NSData* errorXml)
{
	NSMutableString* theWholeReason = [NSMutableString string];
	
	OFXmlDocument* doc = [OFXmlDocument xmlDocumentWithData:errorXml];
	[doc pushNextScope:"errors"];
	while(OFPointer<OFXmlElement> nextError = [doc readNextElement])
	{
		NSString* field = nextError->getAttributeNamed(@"field");
		NSString* reason = nextError->getAttributeNamed(@"reason");
		
		if([field isEqualToString:@"base"])
		{
			[theWholeReason appendFormat:@"%@\n", reason];
		}
		else
		{
			[theWholeReason appendFormat:@"- %@: %@\n", field, reason];
		}
	}
	[doc popScope];
	
	return theWholeReason;
}

@interface OFFormControllerHelper ()
- (void) submitForm;
@end

@implementation OFFormControllerHelper ( Submit )

- (void)submitForm
{	
	OFPointer<OFHttpNestedQueryStringWriter> queryStream = new OFHttpNestedQueryStringWriter;
	{
		OFISerializer::Scope resource(queryStream, [[self singularResourceName] UTF8String]);
		
		OFViewDataGetter getter(self.view, mViewDataMap);
		getter.serialize(queryStream);
	}
	
	[self addHiddenParameters:queryStream.get()];

	[self onBeforeFormSubmitted];

	[[OpenFeint provider] performAction:[self getFormSubmissionUrl]
					  withParameters:queryStream->getQueryParametersAsMPURLRequestParameters()
						withHttpMethod:[self getHTTPMethod]
						  withSuccess:OFDelegate(self, @selector(_requestRespondedBehavior:))
						   withFailure:OFDelegate(self, @selector(_requestErroredBehavior:))
						   withRequestType:OFActionRequestForeground
						   withNotice:[OFNotificationData foreGroundDataWithText:[self getLoadingScreenText]]
						   requiringAuthentication:[self shouldUseOAuth]];
}

- (void)_requestRespondedBehavior:(MPOAuthAPIRequestLoader*)response
{
 	[self hideLoadingScreen];
	[self onFormSubmitted];
	mIsSubmitting = NO;
}

- (void)_requestErroredBehavior:(MPOAuthAPIRequestLoader*)response
{
	[self hideLoadingScreen];
	[self onPresentingErrorDialog];

	NSString* message = parseErrorXml(response.data);
	NSString* okButtonTitle = @"Ok";
	if ([message length] == 0)
	{
		NSError* error = response.error;						
		message = [NSString stringWithFormat:@"%@ (%d[%d])", [error localizedDescription], error.domain, error.code];
		okButtonTitle = @"Ok.";
	}
	
	[[[[UIAlertView alloc] initWithTitle:@"Oops! There was a problem:" 
								message:message
								delegate:nil
								cancelButtonTitle:okButtonTitle
								otherButtonTitles:nil] autorelease] show];
	mIsSubmitting = NO;
}

- (IBAction)onSubmitForm:(UIView*)sender
{
	if (mIsSubmitting)
		return;
		
	if([self shouldShowLoadingScreenWhileSubmitting])
	{
		[self showLoadingScreen];
	}
	
	if([self shouldDismissKeyboardWhenSubmitting])
	{
		OFViewHelper::resignFirstResponder(self.view);			
	}

	mIsSubmitting = YES;
	[self submitForm];
}

@end
