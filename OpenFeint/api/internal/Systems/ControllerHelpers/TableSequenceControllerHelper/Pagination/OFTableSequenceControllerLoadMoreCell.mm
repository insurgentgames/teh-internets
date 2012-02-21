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
#import "OFTableSequenceControllerLoadMoreCell.h"
#import "OFViewHelper.h"
#import "OFPaginatedSeries.h"
#import "OFPaginatedSeriesHeader.h"
#import "OFTableSectionDescription.h"

@implementation OFTableSequenceControllerLoadMoreCell

@dynamic isLoading;
@synthesize lastLoadedPageHeader;

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)dealloc
{
	OFSafeRelease(backgroundImageView);
	self.lastLoadedPageHeader = nil;
	[super dealloc];
}

- (void)onResourceChanged:(OFResource*)resource
{
	self.lastLoadedPageHeader = ((OFTableSectionDescription*)resource).page.header;
	[self setIsLoading:false];
}

- (void)setIsLoading:(bool)value
{
	UIActivityIndicatorView* loadingIcon = (UIActivityIndicatorView*)OFViewHelper::findViewByTag(self, 1);
	if(value)
	{
		[loadingIcon startAnimating];
	}
	else
	{
		[loadingIcon stopAnimating];
	}
	
	UILabel* loadingText = (UILabel*)OFViewHelper::findViewByTag(self, 2);
	UILabel* showingText = (UILabel*)OFViewHelper::findViewByTag(self, 3);
		
	if(value)
	{
		loadingText.text = @"Loading";
		showingText.text = @"";
		
		float const kHeightWhileLoading = 26.f;
		CGRect loadingFrame = loadingText.frame;
		loadingFrame.size.height = kHeightWhileLoading;
		loadingText.frame = loadingFrame;
	}
	else
	{				
		unsigned int amountShowing = self.lastLoadedPageHeader.currentPage * self.lastLoadedPageHeader.perPage;

		float const kStandardHeight = 15.f;
		CGRect loadingFrame = loadingText.frame;
		loadingFrame.size.height = kStandardHeight;
		loadingText.frame = loadingFrame;

		if([self.lastLoadedPageHeader isLastPageLoaded])
		{
			amountShowing = self.lastLoadedPageHeader.totalObjects;
			
			loadingText.text = [NSString stringWithFormat:@"No More To Load", self.lastLoadedPageHeader.perPage];
//			loadingText.textColor = [UIColor darkGrayColor];
						
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else
		{
			unsigned int amountToLoad = self.lastLoadedPageHeader.perPage;
			if(self.lastLoadedPageHeader.currentPage == self.lastLoadedPageHeader.totalPages - 1)
			{
				amountToLoad = self.lastLoadedPageHeader.totalObjects - amountShowing;
			}
		
			loadingText.text = [NSString stringWithFormat:@"Load %d More", amountToLoad];
//			loadingText.textColor = [UIColor whiteColor];
		}		
		
		showingText.text = [NSString stringWithFormat:@"Showing %d of %d", amountShowing, self.lastLoadedPageHeader.totalObjects];		
	}
			
	[self setSelected:NO animated:YES];
}

@end
