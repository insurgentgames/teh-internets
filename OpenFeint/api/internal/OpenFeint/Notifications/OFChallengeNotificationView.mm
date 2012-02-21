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
#import "OFChallengeNotificationView.h"
#import "OFControllerLoader.h"
#import "OFChallengeToUser.h"
#import "OFChallengeDefinition.h"
#import "OFChallenge.h"
#import "OFUser.h"
#import "OFImageView.h"
#import "OFImageLoader.h"

@implementation OFChallengeNotificationView

@synthesize challengeIcon, challengerProfileImage, challengerText;

+ (void)showChallengeNotice:(OFReceivedChallengeNotificationData*)notificationData inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFChallengeNotificationView* view = (OFChallengeNotificationView*)OFControllerLoader::loadView(@"ChallengeNotificationView");

	// ensuring thread-safety by firing the notice on the main thread
	SEL selector = @selector(configureWithNotificationData:inView:withInputResponse:);
	NSMethodSignature* methodSig = [view methodSignatureForSelector:selector];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSig];
	[invocation setTarget:view];
	[invocation setSelector:selector];
	[invocation setArgument:&notificationData atIndex:2];
	[invocation setArgument:&containerView atIndex:3];
	[invocation setArgument:&inputResponse atIndex:4];
	[[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.f invocation:invocation repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (void)_iconFinishedDownloading
{
	[self _presentForDuration:4.f];
	[challengeIcon setImageDownloadFinishedDelegate:OFDelegate()];
}

- (void)configureWithNotificationData:(OFReceivedChallengeNotificationData*)notificationData 
							   inView:(UIView*)containerView 
					withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	mInputResponse = [inputResponse retain];
	
	[self _setPresentationView:containerView];
	
	notice.text = notificationData.notificationText;
	
	[backgroundImage setContentMode:UIViewContentModeScaleToFill];
	[backgroundImage setImage:[backgroundImage.image stretchableImageWithLeftCapWidth:(backgroundImage.image.size.width - 2) topCapHeight:0]];
	
	[challengeIcon setDefaultImage:[OFImageLoader loadImage:@"OFDefaultChallengeIcon.png"]];
	
	OFDelegate showAndDismissDelegate(self, @selector(_iconFinishedDownloading));
	
	if(notificationData.receivedChallengeToUser)
	{
		challengeToUser = [notificationData.receivedChallengeToUser retain];
		[challengeIcon setImageDownloadFinishedDelegate:showAndDismissDelegate];
		challengerProfileImage.useSharpCorners = YES;
		[challengerProfileImage useProfilePictureFromUser:challengeToUser.challenge.challenger];
		challengerText.text = [NSString stringWithFormat:@"%@ has challenged you!", challengeToUser.challenge.challenger.name];
		if(challengeToUser.challenge.challengeDefinition.iconUrl == nil)
		{
			[self _iconFinishedDownloading];
		}
		else
		{
			challengeIcon.imageUrl = challengeToUser.challenge.challengeDefinition.iconUrl;
		}
	}
	else
	{
		CGRect noticeFrame = notice.frame;
		noticeFrame.origin = CGPointMake(65.0f, 37.0f);
		[notice setFrame:noticeFrame];
		
		statusIndicator.hidden = YES;
		challengerProfileImage.hidden = YES;
		challengerText.hidden = YES;
		
		challengeToUser = nil;
		showAndDismissDelegate.invoke();
	}
	
	
}

- (void)dealloc 
{
	OFSafeRelease(challengeToUser);
	OFSafeRelease(challengeIcon);
	OFSafeRelease(challengerProfileImage);
	OFSafeRelease(challengerText);
    [super dealloc];
}

@end
