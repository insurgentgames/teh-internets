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

#import "OFFormControllerHelper.h"

@class OFShowMessageAndReturnController;

@interface OFAccountSetupBaseController : OFFormControllerHelper
{
@private
	UILabel* privacyDisclosure;
	BOOL mAddingAdditionalCredential;
	
@package
	OFDelegate mCancelDelegate;
	OFDelegate mCompletionDelegate;
}

+ (OFShowMessageAndReturnController*)getStandardLoggedInController;

@property (nonatomic, retain) IBOutlet UILabel* privacyDisclosure;
@property (assign) BOOL addingAdditionalCredential;

- (void)cancelSetup;
- (void)addHiddenParameters:(OFISerializer*)parameterStream;
- (UIViewController*)getControllerToPopTo;
- (OFShowMessageAndReturnController*)getStandardLoggedInController;

- (void)setCancelDelegate:(OFDelegate const&)delegate;
- (void)setCompletionDelegate:(OFDelegate const&)delegate;

@end
