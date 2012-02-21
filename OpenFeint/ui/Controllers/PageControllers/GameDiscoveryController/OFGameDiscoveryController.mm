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
#import "OFGameDiscoveryController.h"
#import "OFGameDiscoveryService.h"
#import "OFFramedContentWrapperView.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"

@implementation OFGameDiscoveryController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.scope = kPlayedGameScopeTargetServiceIndex;
	self.targetDiscoveryPageName = @"";
}

- (void)doIndexActionWithPage:(unsigned int)oneBasedPageNumber onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure
{
	[OFGameDiscoveryService getGameDiscoveryCategoriesOnSuccess:success onFailure:failure];
}

- (NSString*)getNoDataFoundMessage
{
	return @"No game categories were found. This is probably an error.";
}

- (void)_createAndDisplayTableHeader
{
	[super _createAndDisplayTableHeader];
	
	float width = self.view.frame.size.width;
	if ([self.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		OFFramedContentWrapperView* wrapperView = (OFFramedContentWrapperView*)self.view;
		width = wrapperView.wrappedView.frame.size.width;
	}

	CGRect frame = CGRectMake(0.f, 0.f, width, 32.f);
	UIView* footer = [[[UIView alloc] initWithFrame:frame] autorelease];
	footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	footer.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryGreyBG.png"]];
	
	frame.size.height = 1.f;
	
	UIView* topDivider = [[[UIView alloc] initWithFrame:frame] autorelease];
	topDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	topDivider.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryDividerTop.png"]];
	[footer addSubview:topDivider];

	frame.origin.y = 31.f;
	
	UIView* bottomDivider = [[[UIView alloc] initWithFrame:frame] autorelease];
	bottomDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	bottomDivider.backgroundColor = [UIColor colorWithPatternImage:[OFImageLoader loadImage:@"OFGameDiscoveryDividerBottom.png"]];
	[footer addSubview:bottomDivider];
	
	frame.origin = CGPointZero;
	frame.size = footer.frame.size;
	
	UILabel* message = [[[UILabel alloc] initWithFrame:frame] autorelease];
	message.backgroundColor = [UIColor clearColor];
	message.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	message.font = [UIFont boldSystemFontOfSize:14.f];
	message.textColor = [UIColor whiteColor];
	message.shadowColor = [UIColor blackColor];
	message.shadowOffset = CGSizeMake(0.f, -1.f);
	message.textAlignment = UITextAlignmentCenter;
    message.minimumFontSize = 10.f;
    message.adjustsFontSizeToFitWidth = YES;
	message.text = @"For more games visit www.openfeint.com!";
	[footer addSubview:message];
	
	self.tableView.tableFooterView = footer;
}

@end
