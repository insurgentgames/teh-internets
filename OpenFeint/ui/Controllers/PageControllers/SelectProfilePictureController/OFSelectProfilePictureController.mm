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

#import "OFSelectProfilePictureController.h"

#import "OFControllerLoader.h"
#import "OFUsersCredential.h"
#import "OFUsersCredentialCell.h"
#import "OFUsersCredentialService.h"
#import "OFUser.h"
#import "OFTableSectionDescription.h"
#import "OFAccountSetupBaseController.h"
#import "OFFramedContentWrapperView.h"
#import "OFRootController.h"

#import "IPhoneOSIntrospection.h"
#import "NSObject+WeakLinking.h"

#import "OpenFeint+Private.h"
#import "OpenFeint+UserOptions.h"

#import <QuartzCore/QuartzCore.h>

#pragma mark OFCustomImagePickerController

// adill note: this entire class is a huge hack for the image picker 
// when in landscape mode on 2.x devices
@interface OFCustomImagePickerController : UIImagePickerController
{
	UIWindow* windowFor2x;
	UIViewController* controllerFor2x;
	BOOL statusBarWasHiddenFor2x;
	UIInterfaceOrientation statusBarOrientationFor2x;
	UIStatusBarStyle statusBarStyleFor2x;
}

- (void)show;
- (void)hide;

@end

@implementation OFCustomImagePickerController

- (void)show
{
	if (is3PointOhSystemVersion())
	{
		[[OpenFeint getRootController] presentModalViewController:self animated:YES];
	}
	else
	{
		UIApplication* sharedApp = [UIApplication sharedApplication];
		statusBarWasHiddenFor2x = sharedApp.statusBarHidden;
		statusBarOrientationFor2x = sharedApp.statusBarOrientation;
		statusBarStyleFor2x = sharedApp.statusBarStyle;

		[sharedApp setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
		[sharedApp setStatusBarHidden:(self.sourceType != UIImagePickerControllerSourceTypeCamera) animated:NO];
		[sharedApp setStatusBarOrientation:UIInterfaceOrientationPortrait];

		UIView* clearView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
		clearView.backgroundColor = [UIColor clearColor];

		controllerFor2x = [[UIViewController alloc] initWithNibName:nil bundle:nil];
		[controllerFor2x setView:clearView];
		
		windowFor2x = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[windowFor2x addSubview:controllerFor2x.view];
		[windowFor2x makeKeyAndVisible];
		
		[controllerFor2x presentModalViewController:self animated:YES];
	}
}

- (void)hide
{
	if (is3PointOhSystemVersion())
	{
		[[OpenFeint getRootController] dismissModalViewControllerAnimated:YES];
	}
	else
	{
		OFSafeRelease(controllerFor2x);
		OFSafeRelease(windowFor2x);

		// yes, it will pop away on 2.x devices
		[controllerFor2x dismissModalViewControllerAnimated:NO];
		[windowFor2x resignKeyWindow];

		UIApplication* sharedApp = [UIApplication sharedApplication];
		[sharedApp setStatusBarStyle:statusBarStyleFor2x animated:NO];
		[sharedApp setStatusBarHidden:statusBarWasHiddenFor2x animated:NO];
		[sharedApp setStatusBarOrientation:statusBarOrientationFor2x];
	}
}

@end

#pragma mark OFSelectProfilePictureController

enum OFPictureUpdateMask
{
	kUpdateFacebookPicture = 1 << 0,
	kUpdateTwitterPicture = 1 << 1,
	kUpdateCustomPicture = 1 << 2,
	kUpdateAll = (kUpdateFacebookPicture | kUpdateTwitterPicture | kUpdateCustomPicture)
};

@implementation OFSelectProfilePictureController

#pragma mark Boilerplate

- (void)dealloc
{
	OFSafeRelease(refreshButton);
	[super dealloc];
}

#pragma mark OFTableSequenceControllerHelper Overrides

- (void)populateResourceMap:(OFResourceControllerMap*)resourceMap
{
	resourceMap->addResource([OFUsersCredential class], @"ProfilePicture");
}

- (OFService*)getService
{
	return [OFUsersCredentialService sharedInstance];
}

- (void)doIndexActionOnSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
{
	[OFUsersCredentialService getProfilePictureCredentialsForLocalUserOnSuccess:success onFailure:failure];
}

- (NSString*)getNoDataFoundMessage
{
	return nil;
}

- (NSString*)getTableHeaderViewName
{
	return @"SelectProfilePictureHeader";
}

- (void)onTableHeaderCreated:(UIViewController*)headerController
{
	float width = self.view.frame.size.width;
	if ([self.view isKindOfClass:[OFFramedContentWrapperView class]])
	{
		OFFramedContentWrapperView* wrapperView = (OFFramedContentWrapperView*)self.view;
		width = wrapperView.wrappedView.frame.size.width;
	}

	CGRect frame = mTableHeaderView.frame;
	frame.size.width = width;
	mTableHeaderView.frame = frame;
}

- (void)onBeforeResourcesProcessed:(OFPaginatedSeries*)resources
{
	[resources.objects addObject:[[OFUsersCredential new] autorelease]];
}

#pragma mark Refresh Logic

- (void)_redownloadCredentials
{
	refreshCount++;
	OFDelegate success(self, @selector(_refreshSuccess:));
	OFDelegate failure(self, @selector(_refreshFailure));
	[OFUsersCredentialService getProfilePictureCredentialsForLocalUserOnSuccess:success onFailure:failure];
}

- (void)_refreshFailure
{
	[self hideLoadingScreen];
	refreshButton.enabled = YES;

	[[[[UIAlertView alloc]
		initWithTitle:@"Oops! There was a problem"
		message:@"Something went wrong and we weren't able to refresh your profile pictures. Please try again later."
		delegate:nil
		cancelButtonTitle:@"Ok"
		otherButtonTitles:nil] autorelease] show];
}

- (void)_refreshSuccess:(OFPaginatedSeries*)credentials
{
	if (refreshOnNextRedownload)
	{
		[super _onDataLoaded:credentials isIncremental:NO];
		refreshOnNextRedownload = NO;
		[self _clickedRefresh];
		return;
	}

	BOOL facebookUpdated = NO;
	BOOL twitterUpdated = NO;
    BOOL httpBasicUpdated = NO;

	for (OFUsersCredential* newCredential in credentials)
	{
		if ([newCredential isFacebook] && facebookCredentialWaitingForUpdate != nil)
		{
			facebookUpdated = ![facebookCredentialWaitingForUpdate.profilePictureUpdatedAt isEqualToString:newCredential.profilePictureUpdatedAt];
		}

		if ([newCredential isTwitter] && twitterCredentialWaitingForUpdate != nil)
		{
			twitterUpdated = ![twitterCredentialWaitingForUpdate.profilePictureUpdatedAt isEqualToString:newCredential.profilePictureUpdatedAt];
		}
        
        if ([newCredential isHttpBasic] && httpBasicCredentialWaitngForUpdate != nil)
        {
            httpBasicUpdated = ![httpBasicCredentialWaitngForUpdate.profilePictureUpdatedAt isEqualToString:newCredential.profilePictureUpdatedAt];
			// hack for uploading profile picture. without this every time we hit refresh we'd change back to the default OF icon.
			if (!twitterCredentialWaitingForUpdate && !facebookCredentialWaitingForUpdate)
			{
				OFUser* localUser = [OpenFeint localUser];
				[localUser changeProfilePictureUrl:newCredential.credentialProfilePictureUrl facebook:NO twitter:NO uploaded:YES];
				[OpenFeint setLocalUser:localUser];
			}
        }
	}
	
	if (facebookUpdated)
		facebookCredentialWaitingForUpdate = nil;
		
	if (twitterUpdated)
		twitterCredentialWaitingForUpdate = nil;
    
    if (httpBasicUpdated)
        httpBasicCredentialWaitngForUpdate = nil;
    
	if (facebookCredentialWaitingForUpdate || twitterCredentialWaitingForUpdate || httpBasicCredentialWaitngForUpdate)
	{
		if (refreshCount == 3)
		{
			[super _onDataLoaded:credentials isIncremental:NO];
			[self _refreshFailure];
		}
		else
		{
			[self performSelector:@selector(_redownloadCredentials) withObject:nil afterDelay:3.f];
		}
	}
	else
	{
		[self hideLoadingScreen];
		refreshButton.enabled = YES;
        
		[super _onDataLoaded:credentials isIncremental:NO];
	}
}

- (void)_refreshProfilePictures:(NSUInteger)credentialTypeMask
{
	refreshCount = 0;
	refreshButton.enabled = NO;
	
	facebookCredentialWaitingForUpdate = nil;
	twitterCredentialWaitingForUpdate = nil;
	httpBasicCredentialWaitngForUpdate = nil;

	if ([mSections count] > 0)
	{
		OFPaginatedSeries* currentCredentials = [(OFTableSectionDescription*)[mSections objectAtIndex:0] page];
		for (OFUsersCredential* credential in currentCredentials)
		{
			if ([credential isLinked] && [credential isFacebook])
				facebookCredentialWaitingForUpdate = credential;
			else if ([credential isLinked] && [credential isTwitter])
				twitterCredentialWaitingForUpdate = credential;
            else if ([credential isHttpBasic])
                httpBasicCredentialWaitngForUpdate = credential;
		}
	}
	
	facebookCredentialWaitingForUpdate = (credentialTypeMask & kUpdateFacebookPicture) ? facebookCredentialWaitingForUpdate : nil;
	twitterCredentialWaitingForUpdate = (credentialTypeMask & kUpdateTwitterPicture) ? twitterCredentialWaitingForUpdate : nil;
	httpBasicCredentialWaitngForUpdate = (credentialTypeMask & kUpdateCustomPicture) ? httpBasicCredentialWaitngForUpdate : nil;
	
	[self showLoadingScreen];

	OFDelegate success(self, @selector(_redownloadCredentials));
	OFDelegate failure(self, @selector(_refreshFailure));
	[OFUsersCredentialService requestProfilePictureUpdateForLocalUserOnSuccess:success onFailure:failure];
}

- (IBAction)_clickedRefresh
{
	[self _refreshProfilePictures:kUpdateAll];
}

#pragma mark UIViewController Overrides

- (void)viewDidLoad
{
	self.title = @"Change Profile Picture";

	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
		initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
		target:self 
		action:@selector(_clickedRefresh)] autorelease];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (redownloadOnNextAppear)
	{
		redownloadOnNextAppear = NO;
		refreshOnNextRedownload = YES;
		[self _redownloadCredentials];
	}
}

#pragma mark Choose Profile Picture Logic

- (void)_selectSourceSuccessWithIgnored:(id)ignored andCredential:(OFUsersCredential*)credential
{
	OFUser* localUser = [OpenFeint localUser];
	[localUser changeProfilePictureUrl:credential.credentialProfilePictureUrl
                              facebook:[credential isFacebook]
                               twitter:[credential isTwitter]
                              uploaded:[credential isHttpBasic]];
	[OpenFeint setLocalUser:localUser];
	
	[self.tableView reloadData];
	
	[self hideLoadingScreen];
}

- (void)_uploadSuccessWithIgnored:(id)ignored
{
	[self _refreshProfilePictures:kUpdateCustomPicture];
}

- (void)_selectSourceFailure
{
	[self hideLoadingScreen];
    
	[[[[UIAlertView alloc]
		initWithTitle:@"Oops! There was a problem"
		message:@"Something went wrong and we weren't able to save your change. Please try again later."
		delegate:nil
		cancelButtonTitle:@"Ok"
		otherButtonTitles:nil] autorelease] show];
}

#pragma mark Cell Click Handler

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath
{
    OFUsersCredential* credential = (OFUsersCredential*)cellResource;
    
	if ([credential isKindOfClass:[OFUsersCredential class]])
	{
		if (![credential isLinked] && ([credential isFacebook] || [credential isTwitter]))
		{
			redownloadOnNextAppear = YES;
			
			OFAccountSetupBaseController* controller = (OFAccountSetupBaseController*)OFControllerLoader::load([OFUsersCredentialCell getCredentialControllerName:[credential credentialType]]);
			controller.addingAdditionalCredential = YES;
			[self.navigationController pushViewController:controller animated:YES];
		}
        else
        {
			if ([credential.credentialType length] == 0)
			{
				[self showLoadingScreen];

				OFDelegate success(self, @selector(_uploadSuccessWithIgnored:));
				OFDelegate failure(self, @selector(_selectSourceFailure));

				[OFUsersCredentialService
				 uploadProfilePictureLocalUser:nil
				 onSuccess:success
				 onFailure:failure];
			}
			else if ([credential isHttpBasic])
			{
				[self _presentCustomImageActionSheet];
			}
			else
			{
				[self showLoadingScreen];

				OFDelegate success(self, @selector(_selectSourceSuccessWithIgnored:andCredential:), credential);
				OFDelegate failure(self, @selector(_selectSourceFailure));
				
				[OFUsersCredentialService
				 selectProfilePictureSourceForLocalUser:credential.credentialType
				 onSuccess:success
				 onFailure:failure];
			}

			[[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
        }        
	}
}

#pragma mark Custom Icon Handling

- (IBAction)_presentCustomImageActionSheet
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	
	if (hasCamera)
	{
		UIActionSheet *sheet = [[UIActionSheet alloc] init];
		sheet.delegate = self;
		sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		
		[sheet addButtonWithTitle:@"Take Photo With Camera"];
		[sheet addButtonWithTitle:@"Choose From Library"];
		[sheet addButtonWithTitle:@"Cancel"];
		
		sheet.cancelButtonIndex = 2;
		
		[sheet showInView:[OpenFeint getTopLevelView]];
		[sheet release];
	}
	else
	{
		[self actionSheet:nil clickedButtonAtIndex:1];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [actionSheet cancelButtonIndex])
		return;

    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        
	OFCustomImagePickerController* picker = [[[OFCustomImagePickerController alloc] init] autorelease];
	picker.sourceType = sourceType;
    [picker trySet:@"allowsEditing" elseSet:@"allowsImageEditing" with:(id)YES];
	picker.delegate = self;

	[picker show];
}

- (void)_imageSelected:(UIImage*)image
{
	UIGraphicsBeginImageContext(CGSizeMake(50.f, 50.f));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(ctx, 1.f, -1.f);
	CGContextDrawImage(ctx, CGRectMake(0.f, 0.f, 50.f, -50.f), image.CGImage);
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    OFDelegate success(self, @selector(_uploadSuccessWithIgnored:));
    OFDelegate failure(self, @selector(_selectSourceFailure));
    [OFUsersCredentialService
        uploadProfilePictureLocalUser:image
        onSuccess:success
        onFailure:failure];
  
    [self showLoadingScreen];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[(OFCustomImagePickerController*)picker hide];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[(OFCustomImagePickerController*)picker hide];

	[self _imageSelected:image];
}

#ifdef __IPHONE_3_0

// this delegate method is only existant in iPhoneSDK3.0+
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[(OFCustomImagePickerController*)picker hide];
    
    // String version UIImagePickerControllerEditedImage so that 3.x with a deploy target of 2.x doesn't crash on the missing symbol
    UIImage* chosenImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (chosenImage == nil) {
        chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    
	[self _imageSelected:chosenImage];
}

#endif

@end