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

#import "OFDashboardNotificationView.h"
#import "OpenFeint+Private.h"
#import "OFNotificationInputResponse.h"
#import "OFImageLoader.h"

@implementation OFDashboardNotificationView

- (id)initWithText:(NSString*)text andInputResponse:(OFNotificationInputResponse*)inputResponse
{
	const float viewWidth = [OpenFeint isInLandscapeMode] ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
	CGRect noticeFrame = CGRectMake(0.f, 0.f, viewWidth, 21.f);
	self = [super initWithFrame:noticeFrame];
	if (self)
	{
		UIImage* bgImage = [OFImageLoader loadImage:@"OpenFeintDashboardNotificationBackground.png"];
		UIImageView* bgView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
		bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		bgView.frame = noticeFrame;
		[self addSubview:bgView];

		UIImage* disclosureImage = [OFImageLoader loadImage:@"OpenFeintNotificationDisclosureArrow.png"];

		UIFont* font = [UIFont boldSystemFontOfSize:11.f];

		CGSize infoSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(viewWidth, bgImage.size.height)];
		infoSize.width += disclosureImage.size.width + 2.0f;
		infoSize.width = MIN(infoSize.width, viewWidth);

		CGRect labelFrame = noticeFrame;
		labelFrame.origin.x = floorf((viewWidth - infoSize.width) * 0.5f);
		labelFrame.origin.y = 2.f;
		UILabel* noticeLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
		noticeLabel.font = font;
		noticeLabel.text = text;
		noticeLabel.textColor = [UIColor colorWithWhite:157.f/255.f alpha:1.f];
		noticeLabel.shadowColor = [UIColor colorWithWhite:43.f/255.f alpha:1.f];
		noticeLabel.shadowOffset = CGSizeMake(1.f, 0.f);
		noticeLabel.backgroundColor = [UIColor clearColor];
		noticeLabel.opaque = NO;
		[self addSubview:noticeLabel];

		UIImageView* disclosureView = [[[UIImageView alloc] initWithImage:disclosureImage] autorelease];
		disclosureView.autoresizingMask = UIViewAutoresizingNone;
		CGRect disclosureRect = disclosureView.frame;
		disclosureRect.origin.x = infoSize.width - disclosureImage.size.width + labelFrame.origin.x;
		disclosureRect.origin.y = (noticeFrame.size.height * 0.5f) - (disclosureRect.size.height * 0.5f) + 2.f;
		disclosureView.frame = disclosureRect;
		[self addSubview:disclosureView];

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

		mInputResponse = [inputResponse retain];
	}
	return self;
}

+ (OFDashboardNotificationView*)notificationWithText:(NSString*)text andInputResponse:(OFNotificationInputResponse*)inputResponse
{
	return [[[OFDashboardNotificationView alloc] initWithText:text andInputResponse:inputResponse] autorelease];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* hitView = [super hitTest:point withEvent:event];
	if (hitView == self)
	{
		[mInputResponse respondToInput];
	}
	return hitView;
}

- (void)dealloc
{
	OFSafeRelease(mInputResponse);
	[super dealloc];
}

@end

