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

#import "OFAbuseReporter.h"
#import "OFProvider.h"
#import "OpenFeint+Private.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFHttpNestedQueryStringWriter.h"

namespace  
{
	static NSString* sAbuseTypeToNSStringMap[] = 
	{
		@"chat",	// kAbuseType_Chat
		@"forum"	// kAbuseType_Forum
	};
}

@interface OFAbuseReporter (Internal)
- (id)initWithUserId:(NSString*)_userId andType:(OFAbuseType)type andController:(UIViewController*)_viewController;
- (void)report;
- (void)_reportSuccess:(MPOAuthAPIRequestLoader*)response;
- (void)_reportFailed:(MPOAuthAPIRequestLoader*)response;
- (void)_reportFinished;
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;
@end

@implementation OFAbuseReporter

@synthesize flaggableId, flaggableType;

+ (void)reportAbuseByUser:(NSString*)userId fromController:(UIViewController*)viewController
{
	[[[OFAbuseReporter alloc] initWithUserId:userId andType:kAbuseType_Chat andController:viewController] report];
}

+ (void)reportAbuseByUser:(NSString*)userId forumPost:(NSString*)forumPostId fromController:(UIViewController*)viewController
{
	OFAbuseReporter* abuse = [[OFAbuseReporter alloc] initWithUserId:userId andType:kAbuseType_Forum andController:viewController];
	abuse.flaggableId = forumPostId;
	abuse.flaggableType = @"Post";	
	[abuse report];
}

+ (void)reportAbuseByUser:(NSString*)userId forumThread:(NSString*)forumThreadId fromController:(UIViewController*)viewController
{
	OFAbuseReporter* abuse = [[OFAbuseReporter alloc] initWithUserId:userId andType:kAbuseType_Forum andController:viewController];
	abuse.flaggableId = forumThreadId;
	abuse.flaggableType = @"Discussion";	
	[abuse report];
}

- (id)initWithUserId:(NSString*)_userId andType:(OFAbuseType)_type andController:(UIViewController*)_viewController
{
	self = [super init];
	if (self != nil)
	{
		userId = [_userId retain];
		viewController = [_viewController retain];
		abuseType = _type;
		reported = NO;
	}
	
	return self;
}

- (void)dealloc
{
	self.flaggableId = nil;
	self.flaggableType = nil;
	
	OFSafeRelease(userId);
	OFSafeRelease(viewController);
	[super dealloc];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)report
{
	if ([userId length] == 0 || !viewController)
	{
		[self _reportFinished];
		return;
	}
	
	UIView* viewToUse = viewController.view;
	[[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to submit an abuse report?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes, Report" otherButtonTitles:nil] showInView:viewToUse];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		reported = YES;
		
		if ([viewController respondsToSelector:@selector(showLoadingScreen)])
		{
			[viewController performSelector:@selector(showLoadingScreen)];
		}

		OFPointer<OFHttpNestedQueryStringWriter> queryStream = new OFHttpNestedQueryStringWriter;
		queryStream->io("abuse_flag[abuse_type]", sAbuseTypeToNSStringMap[abuseType]);
		
		if ([flaggableId length] && [flaggableType length])
		{
			queryStream->io("abuse_flag[flaggable_id]", flaggableId);
			queryStream->io("abuse_flag[flaggable_type]", flaggableType);
		}

		[[OpenFeint provider] performAction:[NSString stringWithFormat:@"users/%@/abuse_flags.xml", userId]
							  withParameters:queryStream->getQueryParametersAsMPURLRequestParameters()
							  withHttpMethod:@"POST"
							  withSuccess:OFDelegate(self, @selector(_reportSuccess:))
							  withFailure:OFDelegate(self, @selector(_reportFailed:))
							  withRequestType:OFActionRequestSilent
							  withNotice:nil
							  requiringAuthentication:true];
	}
	else
	{
		[self _reportFinished];
	}
}

- (void)_reportSuccess:(MPOAuthAPIRequestLoader*)response
{
	[self _reportFinished];
}

- (void)_reportFailed:(MPOAuthAPIRequestLoader*)response
{
	[self _reportFinished];
}

- (void)_reportFinished
{
	if (reported && [viewController respondsToSelector:@selector(hideLoadingScreen)])
	{
		[viewController performSelector:@selector(hideLoadingScreen)];
	}
	
	[self release];
}

@end