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
#import "OFAchievementNotificationView.h"
#import "OFControllerLoader.h"
#import "OFAchievement.h"
#import "OFImageView.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"

@implementation OFAchievementNotificationView

@synthesize achievementIcon, achievementDetailText, achievementValueText;

+ (NSString*)notificationViewName
{
	return @"AchievementNotificationView";
}

+ (void)showAchievementNotice:(OFUnlockedAchievementNotificationData*)notificationData inView:(UIView*)containerView withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	OFAchievementNotificationView* view = (OFAchievementNotificationView*)OFControllerLoader::loadView([self notificationViewName]);

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
	[achievementIcon setImageDownloadFinishedDelegate:OFDelegate()];
}

- (void)configureWithNotificationData:(OFUnlockedAchievementNotificationData*)notificationData 
							   inView:(UIView*)containerView 
					withInputResponse:(OFNotificationInputResponse*)inputResponse
{
	mInputResponse = [inputResponse retain];
	disclosureIndicator.hidden = (inputResponse == nil);
	
	[self _setPresentationView:containerView];

	notice.text = notificationData.notificationText;
	
	[backgroundImage setContentMode:UIViewContentModeScaleToFill];
	[backgroundImage setImage:[backgroundImage.image stretchableImageWithLeftCapWidth:(backgroundImage.image.size.width - 18) topCapHeight:0]];
	
	[achievementIcon setDefaultImage:[OFImageLoader loadImage:@"OFUnlockedAchievementIcon.png"]];

	OFDelegate showAndDismissDelegate(self, @selector(_iconFinishedDownloading));

	if (notificationData.unlockedAchievement)
	{
		achievement = [notificationData.unlockedAchievement retain];
		achievementDetailText.text = [NSString stringWithFormat:@"'%@'", achievement.title];
		achievementValueText.text = [NSString stringWithFormat:@"%d", achievement.gamerscore];

		UIImage* localImage = [OFImageLoader loadImage:[NSString stringWithFormat:@"AchievementIcon_%@.jpg", notificationData.unlockedAchievement.resourceId]];
		if (localImage)
		{
			[achievementIcon setDefaultImage:localImage];
			showAndDismissDelegate.invoke();
		}
        else if (!achievement.iconUrl || [achievement.iconUrl isEqualToString:@""])
        {
            showAndDismissDelegate.invoke();
        }
		else
		{
            [achievementIcon setImageDownloadFinishedDelegate:showAndDismissDelegate];
			achievementIcon.imageUrl = achievement.iconUrl;
		}
	}
	else
	{
		CGRect noticeFrame = notice.frame;
		noticeFrame.origin = CGPointMake(61.0f, 24.0f);
		[notice setFrame:noticeFrame];
		
		statusIndicator.hidden = YES;
		achievementDetailText.hidden = YES;
		achievementValueText.hidden = YES;

		achievement = nil;
		showAndDismissDelegate.invoke();
	}
}

- (void)dealloc 
{
	OFSafeRelease(achievement);
	OFSafeRelease(achievementIcon);
	OFSafeRelease(achievementDetailText);
	OFSafeRelease(achievementValueText);
    [super dealloc];
}

@end
