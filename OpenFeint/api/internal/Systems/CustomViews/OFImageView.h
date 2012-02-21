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

#pragma once

#include <UIKit/UIKit.h>

class OFHttpService;
class OFImageViewHttpServiceObserver;
@class OFUser;

@interface OFImageView : UIControl< OFCallbackable >
{
@private
	UIImage* mDefaultImage;
	
	NSString* mImageUrl;
	UIImage* mImage;

	BOOL mShouldScaleImageToFillRect;
	BOOL mShouldShowLoadingIndicator;
	
	float mCrossFadeDuration;	
	UIImage* mImageFadingIn;
	float mFadingImageAlpha;
	NSTimer* mFadingTimer;
	
	UIActivityIndicatorView* mLoadingView;
	
	OFPointer<OFHttpService> mHttpService;
	OFPointer<OFImageViewHttpServiceObserver> mHttpServiceObserver;
	
	CGPathRef mBorderPath;
	BOOL mUseSharpCorners;
	BOOL mUsingCustomBorderPath;
	
	OFDelegate mDelegate;
	BOOL mUseFacebookOverlay;
	UIImageView* mFacebookOverlay;
	
	NSString* mImageFrameFileName;
	BOOL mUnframed;
	UIImageView* mImageFrame;
}

- (bool)canReceiveCallbacksNow;

@property (nonatomic, assign) BOOL shouldScaleImageToFillRect;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) NSString* imageUrl;
@property (nonatomic, assign) BOOL useFacebookOverlay;
@property (nonatomic, assign) BOOL useSharpCorners;
@property (nonatomic, assign) BOOL unframed;
@property (nonatomic, assign) float crossFadeDuration;
@property (nonatomic, assign) BOOL shouldShowLoadingIndicator;

- (void)setImageUrl:(NSString*)imageUrl crossFading:(BOOL)shouldCrossFade;

- (void)showLoadingIndicator;

- (void)setDefaultImage:(UIImage*)defaultImage;

- (void)useLocalPlayerProfilePictureDefault;
- (void)useOtherPlayerProfilePictureDefault;

- (void)useProfilePictureFromUser:(OFUser*)user;

- (void)setImageDownloadFinishedDelegate:(OFDelegate const&)delegate;

- (void)setCustomClippingPath:(CGPathRef)path;

@end