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
#import "OFActionRequest.h"
#import "OpenFeint+Private.h"
#import "OFProvider.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFDelegateChained.h"
#import "MPOAuthURLResponse.h"
#import "OFServerMaintenanceNoticeController.h"
#import "OFNotification.h"
#import "OFNotificationData.h"
#import "OFReachability.h"

// If this changes, the server configrations must be updated. 
const int OpenFeintHttpStatusCodeSeriousError = 400;
const int OpenFeintHttpStatusCodeNotAcceptable = 406;
const int OpenFeintHttpStatusCodeForServerMaintanence = 450;
const int OpenFeintHttpStatusCodeNotAuthorized = 401;
const int OpenFeintHttpStatusCodeUpdateRequired = 426;
const int OpenFeintHttpStatusCodePermissionsRequired = 430;
const int OpenFeintHttpStatusCodeNotFound = 404;
const int OpenFeintHttpStatusCodeForbidden = 403;
const int OpenFeintHttpStatusCodeOK = 200;

@implementation OFActionRequest

@synthesize notice = mNoticeData;
@synthesize requiresAuthentication = mRequiresAuthentication;
@dynamic failedNotAuthorized;

- (bool)failedNotAuthorized
{
	return mPreviousHttpStatusCode == OpenFeintHttpStatusCodeNotAuthorized;
}

+ (id)actionRequestWithLoader:(MPOAuthAPIRequestLoader*)loader withRequestType:(OFActionRequestType)requestType withNotice:(OFNotificationData*)noticeData requiringAuthentication:(bool)requiringAuthentication
{
	return [[[self alloc] initWithLoader:loader withRequestType:requestType withNotice:noticeData requiringAuthentication:requiringAuthentication] autorelease];
}

- (bool) _checkAndHandleHttpErrors:(MPOAuthAPIRequestLoader*)request
{
	bool errorsEnabled = [OpenFeint areErrorScreensAllowed];
	
	if([request.oauthResponse.urlResponse isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)request.oauthResponse.urlResponse;
		
		mPreviousHttpStatusCode = httpResponse.statusCode;		
		
		switch(mPreviousHttpStatusCode)
		{
			case OpenFeintHttpStatusCodeUpdateRequired:
			{
				[OpenFeint displayUpgradeRequiredErrorMessage:request.data];
				return errorsEnabled;
			}			
			case OpenFeintHttpStatusCodeForServerMaintanence:
			{
				[OpenFeint displayServerMaintenanceNotice:request.data]; 
				return errorsEnabled;
			}
			case OpenFeintHttpStatusCodeNotAuthorized:
			{
				if (self.requiresAuthentication)
				{
					[OpenFeint displayErrorMessage:@"An unknown error has occurred. Please try again."];
					return true;
				}
				return false;
			}
			case OpenFeintHttpStatusCodePermissionsRequired:
			{
				[OpenFeint launchGetExtendedCredentialsFlowForRequest:self withData:request.data andNoticeUserData:mNoticeData.notificationUserData];
				mLoader = [request retain];
				return true;
			}
		}		

		if (mPreviousHttpStatusCode >= OpenFeintHttpStatusCodeSeriousError && 
			mPreviousHttpStatusCode != OpenFeintHttpStatusCodeForbidden && 
			mPreviousHttpStatusCode != OpenFeintHttpStatusCodeNotAcceptable &&
			!request.error)
		{
			[OpenFeint displayErrorMessage:@"Please try your request again in a few moments."];
			return true;
		}
	}
	
	return false;
}

- (void) _onFailure:(MPOAuthAPIRequestLoader*)request nextCall:(OFDelegateChained*)nextCall
{
	if([self _checkAndHandleHttpErrors:request])
	{
		// Handled
	}
	else if(request.error)
	{
		NSError* error = request.error;						
		NSString* errorMessage = [NSString stringWithFormat:@"%@ (%d[%d])", [error localizedDescription], error.domain, error.code];			
		if ([OpenFeint isDashboardHubOpen] && (error.code == -1009 || error.code == -1004)) //no internet
		{
			[OpenFeint displayErrorMessageAndOfflineButton:errorMessage];
		}
		else
		{
			[OpenFeint displayErrorMessage:errorMessage];
		}
	}

	[nextCall invokeWith:request];
}

- (id)initWithLoader:(MPOAuthAPIRequestLoader*)loader withRequestType:(OFActionRequestType)requestType withNotice:(OFNotificationData*)noticeData requiringAuthentication:(bool)requiringAuthentication
{
	self = [super init];
	if (self != nil)
	{
		// adill Note: We retain the loader, then proceed to set it's failure delegate with an OFDelegate (that is retaining us)
		//		thus we have a circular reference. To remedy this situation we're releasing the loader in dispatch (which will
		//		deallocate the failure delegate which releases the reference to ourself)
		mLoader = [loader retain];
		[mLoader setOnFailure:OFDelegate(self, @selector(_onFailure:nextCall:), [mLoader getOnFailure])];
		mRequestType = requestType;
		mNoticeData = [noticeData retain];
		mRequiresAuthentication = requiringAuthentication;
	}
	
	return self;
}

- (void)setRequestDoesNotExpectAuthentication
{
	mRequiresAuthentication = false;
}

- (void)dealloc 
{
	OFSafeRelease(mLoader);
	OFSafeRelease(mNoticeData);
    [super dealloc];
}

- (void)dispatch
{
	OFAssert(mLoader != nil, "Cannot dispatch a request twice!");
		
	if (!OFReachability::Instance()->isGameServerReachable() ||
		!self.requiresAuthentication || 
		(self.requiresAuthentication && [[OpenFeint provider] isAuthenticated]))
	{
		if([OpenFeint isShowingFullScreen] == false)
		{
			NSAssert(OFActionRequestCount == 3, @"Number of action request types changed. Make sure this if statement is up to date");
			
			if(mRequestType == OFActionRequestBackground)
			{
				[[OFNotification sharedInstance] showBackgroundNoticeForLoader:mLoader withNotice:mNoticeData];
			}
			else if(mRequestType == OFActionRequestForeground)
			{
				[[OFNotification sharedInstance] showBackgroundNoticeForLoader:mLoader withNotice:mNoticeData];
			}
			else if(mRequestType == OFActionRequestSilent)
			{
				[mLoader loadSynchronously:NO];
			}
		}
		else
		{
			// citron note: for now, all dashboard screens are managing their own "loading" state. Should this change?
			[mLoader loadSynchronously:NO];
		}
		
		OFSafeRelease(mLoader);
	}
	else
	{
		[OpenFeint launchLoginFlowForRequest:self];
	}
}

// adill: mLoader has a reference to us, so we *have* to release it before we'll be released
- (void)abandonInLightOfASeriousError
{
	OFSafeRelease(mLoader);
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

@end
