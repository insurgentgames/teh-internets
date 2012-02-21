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

#define MIN_LABEL_HEIGHT 20.0
#define MAX_LABEL_HEIGHT 9999
#define MAX_LABEL_WIDTH_PORTRAIT 210.0
#define MAX_LABEL_WIDTH_LANDSCAPE 370.0
#define VIEW_BUFFER 10

#import "OFDependencies.h"
#import "OFSendChallengeHeaderController.h"
#import "OFViewHelper.h"
#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionService.h"
#import "OFPaginatedSeries.h"
#import "OFSendChallengeController.h"
#import "OpenFeint+Private.h"
#import "OFDefaultTextField.h"
#import "OFImageLoader.h"

@implementation OFSendChallengeHeaderController

@synthesize sendChallengeController,titleLabel,descriptionLabel,sendChallengeButton,challengeIconImageView, descriptionContainer, userMessageTextField, tryAgainButton;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	if (!finishedDownloadingChallenge)
	{
		self.titleLabel.text = @"Loading...";
		self.descriptionLabel.text = @"";
	}
}

- (void)dealloc
{
	self.sendChallengeController = nil;
	self.titleLabel = nil;
	self.descriptionLabel = nil;
	self.sendChallengeButton = nil;
	self.challengeIconImageView = nil;
	self.descriptionContainer = nil;
	self.userMessageTextField = nil;
	self.tryAgainButton = nil;
	[super dealloc];
}

- (BOOL)allowCreateStrongerChallenge
{
	return [[OpenFeint getChallengeDelegate] respondsToSelector:@selector(userRestartedCreateChallenge)];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// If the user closes the modal we must still stay valid until we get the callback.
	selfRetainer = self;
	parentRetainer = sendChallengeController;
	OFDelegate success(self, @selector(_newChallengeDefinitionDownloaded:));
	OFDelegate failure(self, @selector(_challengeDefinitionDownloadFailed));
	[OFChallengeDefinitionService getChallengeDefinitionWithId:sendChallengeController.challengeDefinitionId onSuccess:success onFailure:failure];	
	self.userMessageTextField.closeKeyboardOnReturn = YES;
	self.userMessageTextField.manageScrollViewOnFocus = YES;
	
	self.tryAgainButton.hidden = ![self allowCreateStrongerChallenge];
}

- (void)_challengeDefinitionDownloadFailed
{
	[[[[UIAlertView alloc] initWithTitle:@"Error Occurred" 
								 message:@"OpenFeint failed downloading data. Please check your connection and try again." 
								delegate:nil 
					   cancelButtonTitle:@"OK" 
					   otherButtonTitles:nil] autorelease] show];
	
	selfRetainer = nil;
	parentRetainer = nil;
}

- (void)_newChallengeDefinitionDownloaded:(OFPaginatedSeries*)resouces
{
	if ([resouces count] > 0)
	{
		OFChallengeDefinition* challengeDefinition = [resouces.objects objectAtIndex:0];
		[self setChallenge:challengeDefinition];
	}
	else
	{
		[self _challengeDefinitionDownloadFailed];
	}
	selfRetainer = nil;
	parentRetainer = nil;
}

- (void)setChallenge:(OFChallengeDefinition*)newChallengeDefinition
{
	finishedDownloadingChallenge = YES;
	
	UIImage* defaultChallengeIcon = [OFImageLoader loadImage:@"OFDefaultChallengeIcon.png"];
	[self.challengeIconImageView setDefaultImage:defaultChallengeIcon];
	self.challengeIconImageView.imageUrl = newChallengeDefinition.iconUrl;
	
	self.titleLabel.text = newChallengeDefinition.title;
	
	self.descriptionLabel.text = sendChallengeController.challengeText;
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (void)cancel
{
	[OpenFeint dismissDashboard];
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], sendChallengeScreenClosed);
}

- (IBAction)createStrongerChallenge
{
	OF_OPTIONALLY_INVOKE_DELEGATE([OpenFeint getChallengeDelegate], createStrongerChallenge);
	[self cancel];
}

- (void)resizeView:(UIView*)parentView
{
	CGRect lastElementFrame = [self allowCreateStrongerChallenge] ?  self.tryAgainButton.frame : self.userMessageTextField.frame;
	float viewHeight = lastElementFrame.origin.y + lastElementFrame.size.height + 20.f;
	CGRect myRect = CGRectMake(0.0f, 0.0f, parentView.frame.size.width, viewHeight);	
	self.view.frame = myRect;
	[self.view layoutSubviews];
}

@end