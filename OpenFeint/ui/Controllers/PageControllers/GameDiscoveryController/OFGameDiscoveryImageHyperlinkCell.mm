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
#import "OFGameDiscoveryImageHyperlinkCell.h"
#import "OFGameDiscoveryImageHyperlink.h"
#import "OFImageView.h"
#import "OFPlayedGameController.h"
#import "OFApplicationDescriptionController.h"
#import "OFControllerLoader.h"

@implementation OFGameDiscoveryImageHyperlinkCell

@synthesize imageView;

- (void)onResourceChanged:(OFResource*)resource
{
	OFGameDiscoveryImageHyperlink* hyperlink = (OFGameDiscoveryImageHyperlink*)resource;
	self.imageView.imageUrl = hyperlink.imageUrl;
	self.imageView.useSharpCorners = YES;
	self.imageView.unframed = YES;
	self.imageView.shouldScaleImageToFillRect = NO;
}

- (void)dealloc
{
	self.imageView = nil;

	[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UINavigationController* owningNav = self.bannerProvider.navigationController;
	if (!owningNav)
	{
		owningNav = owningTable.navigationController;
	}
	
	[self onCellWasClicked:owningNav];
}

- (void)onCellWasClicked:(UINavigationController*)owningNav;
{
	UIViewController* nextController = nil;

	OFGameDiscoveryImageHyperlink* hyperlink = (OFGameDiscoveryImageHyperlink*)self.resource;
	if(hyperlink == nil)
	{
		return;
	}
	
	if([hyperlink isIPurchaseLink])
	{
		NSString* displayContext = [NSString stringWithFormat:@"gameDiscoveryImageHyperlink_%@", hyperlink.appBannerPlacement];
		nextController = [OFApplicationDescriptionController applicationDescriptionForId:hyperlink.targetApplicationIPurchaseId appBannerPlacement:displayContext];
	}
	else if([hyperlink isCategoryLink])
	{
		OFPlayedGameController* gameList = (OFPlayedGameController*)OFControllerLoader::load(@"PlayedGame", nil);
		[gameList setTargetDiscoveryPageName:hyperlink.targetDiscoveryActionName];
		gameList.navigationItem.title = hyperlink.targetDiscoveryPageTitle;
		nextController = gameList;
	}

	// adill note: pushing nil crashes on 2.x devices
	if (nextController != nil)
	{
		[owningNav pushViewController:nextController animated:YES];
	}
}

@end
