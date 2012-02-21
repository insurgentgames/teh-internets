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
#import "OFFavoriteThisGameController.h"
#import "OFClientApplicationService+Private.h"
#import "OFMultilineTextField.h"
#import "NSObject+WeakLinking.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserOptions.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+Overridables.h"
#import "OFFramedNavigationController.h"
#import "OFGameProfilePageInfo.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"

#define kOFFavoriteThisGameReviewAreaHeight 181.f

@implementation OFFavoriteThisGameController

@synthesize favoriteButton, reviewTextField, descriptionLabel, reviewArea;

- (void) dealloc
{
	OFSafeRelease(favoriteButton);
	OFSafeRelease(reviewTextField);
	OFSafeRelease(descriptionLabel);
	OFSafeRelease(reviewArea);
	[super dealloc];
}

- (NSString*)getClientApplicationId
{
	OFGameProfilePageInfo* gameProfile = [(OFFramedNavigationController*)self.navigationController currentGameContext];
	return gameProfile.resourceId;
}

- (NSString*)getClientApplicationName
{
	OFGameProfilePageInfo* gameProfile = [(OFFramedNavigationController*)self.navigationController currentGameContext];
	return gameProfile.name;
}

- (void)setReviewAreaAvailable:(BOOL)available animate:(BOOL)animate
{
    if ([OpenFeint isInLandscapeMode])
    {
        float totalWidth = self.view.frame.size.width;
        float buttonAreaWidth = available ? (totalWidth * 0.3f) : totalWidth;
        CGPoint buttonTarget = CGPointMake(buttonAreaWidth * 0.5f, self.favoriteButton.center.y);
        CGPoint reviewAreaTarget = CGPointMake(buttonAreaWidth + self.reviewArea.frame.size.width * 0.5f, self.reviewArea.center.y);        
        
        if (animate)
        {
            [UIView beginAnimations:@"slidingIn" context:nil];
            [UIView setAnimationDuration:0.325f];
            [UIView setAnimationDelegate:nil];
            self.favoriteButton.center = buttonTarget;
            self.reviewArea.center = reviewAreaTarget;
            [UIView commitAnimations];
            
        }
        else
        {
            self.favoriteButton.center = buttonTarget;
            self.reviewArea.center = reviewAreaTarget;
        }
    }
    else
    {
        self.reviewArea.userInteractionEnabled = available;
        
        if (animate)
        {
            [UIView beginAnimations:@"fadingIn" context:nil];
            [UIView setAnimationDuration:0.325f];
            [UIView setAnimationDelegate:nil];
        }
        
        self.reviewArea.alpha = available ? 1.f : 0.f;
        
        if (animate)
        {
            [UIView commitAnimations];
        }
    }
    
    
    
    if (!available)
	{
		[self.reviewTextField resignFirstResponder];
		self.navigationItem.rightBarButtonItem = nil;
	} 
	else
	{
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
												   initWithTitle:@"Submit" 
												   style:UIBarButtonItemStylePlain 
												   target:self 
												   action:@selector(onSubmitReviewPressed)] autorelease];
		
	}    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setReviewAreaAvailable:NO animate:NO];
	[self showLoadingScreen];
	[OFClientApplicationService getPlayerReviewForGame:[self getClientApplicationId] 
												byUser:nil 
											 onSuccess:OFDelegate(self, @selector(onReviewLoaded:)) 
											 onFailure:OFDelegate(self, @selector(onRequestFailed))];
}

- (void)setButtonImage:(NSString*)imageName
{
	UIImage* buttonImage = [OFImageLoader loadImage:imageName];
	[self.favoriteButton setImage:buttonImage forState:UIControlStateNormal];
	[self.favoriteButton setImage:buttonImage forState:UIControlStateHighlighted];
}

- (void)onGameIsFavorite:(NSString*)review
{
	isFavorite = YES;
	[self setButtonImage:@"OFButtonStarFilled.png"];
	self.reviewTextField.text = review;
	self.descriptionLabel.text = [NSString stringWithFormat:@"You've added %@ to your Favorites. From now on when your friends view your list of games, this one will be marked with a star. Press the star again to remove it from your Favorites.", [self getClientApplicationName]];
	
	[self setReviewAreaAvailable:YES animate:YES];
}

- (void)onGameIsNotFavorite
{
	isFavorite = NO;
	self.descriptionLabel.text = @"Love the game? Press the star below to make it a Favorite. You'll help support the developer and share your Favorites with your friends.";
	[self setButtonImage:@"OFButtonStarEmpty.png"];
	[self setReviewAreaAvailable:NO animate:YES];
}

- (void)onReviewLoaded:(OFPaginatedSeries*)series
{
	if ([series count] > 0)
	{
		OFPlayerReview* playerReview = [series objectAtIndex:0];
		if (playerReview.favorite)
		{
			[self onGameIsFavorite:playerReview.review];
		}
		else
		{
			[self onGameIsNotFavorite];
		}
	}
	else
	{
		[self onGameIsNotFavorite];
	}
	
	[self hideLoadingScreen];
}

- (void)onRequestSucceeded
{
	if (isFavorite)
	{
		[self onGameIsFavorite:self.reviewTextField.text];
	}
	else
	{
		[self onGameIsNotFavorite];
	}
	[self hideLoadingScreen];
}

- (void)onIsFavoriteChanged
{
	isFavorite = !isFavorite;
	[self onRequestSucceeded];
}

- (void)onRequestFailed
{
	[self hideLoadingScreen];
}

- (void)updateState:(BOOL)includeText makeFavorite:(BOOL)makeFavorite successDelegate:(OFDelegate)successDelegate
{
	[self showLoadingScreen];
	if (makeFavorite)
	{
		NSString* review = nil;
		if (includeText && [reviewTextField.text length] > 0)
		{
			review = reviewTextField.text;
		}
		[OFClientApplicationService makeGameFavorite:[self getClientApplicationId]
										  reviewText:review
										   onSuccess:successDelegate
										   onFailure:OFDelegate(self, @selector(onRequestFailed))];
	}
	else
	{
		[OFClientApplicationService unfavoriteGame:[self getClientApplicationId]
										 onSuccess:successDelegate 
										 onFailure:OFDelegate(self, @selector(onRequestFailed))];
	}
	
}

- (void)onReviewSubmitted
{
	[self hideLoadingScreen];
	[[[[UIAlertView alloc] initWithTitle:nil message:@"Your comment has been submitted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}

- (IBAction) onFavoritePressed
{
	[self updateState:NO makeFavorite:!isFavorite successDelegate:OFDelegate(self, @selector(onIsFavoriteChanged))];
}

- (IBAction) onSubmitReviewPressed
{
    [reviewTextField resignFirstResponder];
	if ([reviewTextField.text length] > 0)
	{
		[self updateState:YES makeFavorite:YES successDelegate:OFDelegate(self, @selector(onReviewSubmitted))];
	}
	else
	{
		[[[[UIAlertView alloc] initWithTitle:nil message:@"You must enter a comment before submitting." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	}
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (NSString*)getFormSubmissionUrl
{
	return [NSString stringWithFormat:@"client_applications/%@/users/review.xml", [self getClientApplicationId]];
}

- (void)registerActionsNow
{

}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	{
		OFISerializer::Scope scope(parameterStream, "client_application_user");
		if ([self.reviewTextField.text length] > 0)
		{
			parameterStream->io("review", self.reviewTextField.text);	
		}
		bool favorite = isFavorite;
		parameterStream->io("favorite", favorite);	
	}
}

- (NSString*)singularResourceName
{
	
	return @"";
}

- (void)onFormSubmitted
{
	[self.reviewTextField resignFirstResponder];
	[self hideLoadingScreen];
	
	UIAlertView* alertSheet = [[[UIAlertView alloc] initWithTitle:nil
														  message:@"Your comment has been submitted successfully." 
														 delegate:nil 
												cancelButtonTitle:@"OK" 
												otherButtonTitles:nil] autorelease];
	[alertSheet show];
}


@end
