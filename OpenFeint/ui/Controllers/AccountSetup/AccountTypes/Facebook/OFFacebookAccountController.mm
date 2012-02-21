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
#import "OFFacebookAccountController.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+Submit.h"
#import "OpenFeint+Settings.h"
#import "OpenFeint+Private.h"
#import "MPOAuthAPIRequestLoader.h"
#import "OFSettings.h"
#import "OFImageLoader.h"
#import "OpenFeint+Private.h"

@interface OFUIInvisibleKeyboardTrap : UIView
@end

@implementation OFUIInvisibleKeyboardTrap

- (void)didAddSubview:(UIView*)subview
{
	[self.superview bringSubviewToFront:self];
}

- (void)willRemoveSubview:(UIView*)subview
{
	[self.superview sendSubviewToBack:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* trappedKeyboard = [self.subviews objectAtIndex:0];
	CGPoint convertedPoint = [self convertPoint:point toView:trappedKeyboard];
	return [trappedKeyboard hitTest:convertedPoint withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* trappedKeyboard = [self.subviews objectAtIndex:0];
	CGPoint convertedPoint = [self convertPoint:point toView:trappedKeyboard];
	return [trappedKeyboard pointInside:convertedPoint withEvent:event];
}

@end


static bool is2PointOhSystemVersion()
{
	NSArray* versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
	NSString* majorVersionNumber = (NSString*)[versionComponents objectAtIndex:0];
	return [majorVersionNumber isEqualToString:@"2"];
}

static bool is3PointOhSystemVersion()
{
	NSArray* versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
	NSString* majorVersionNumber = (NSString*)[versionComponents objectAtIndex:0];
	return [majorVersionNumber isEqualToString:@"3"];
}

@implementation OFFacebookAccountController

@synthesize fbuid;
@synthesize urlToLaunch;
@synthesize fbLoggedInStatusImageView;
@synthesize fbSession;

- (void)setupFixForBrokenWebKit
{	
	if(is3PointOhSystemVersion())
	{
		orientationBeforeFix = [UIApplication sharedApplication].statusBarOrientation;
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
	} 
	else if(is2PointOhSystemVersion())
	{
		invisibleKeyboardTrap = [[OFUIInvisibleKeyboardTrap alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
		[[OpenFeint getTopApplicationWindow] insertSubview:invisibleKeyboardTrap atIndex:0];
	}
}

- (void)cleanFixForBrokenWebKit
{	
	if(is3PointOhSystemVersion())
	{
		[[UIApplication sharedApplication] setStatusBarOrientation:orientationBeforeFix animated:NO];
	}
	else if(is2PointOhSystemVersion())
	{
		[invisibleKeyboardTrap removeFromSuperview];
		OFSafeRelease(invisibleKeyboardTrap);
	}

}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	[super addHiddenParameters:parameterStream];
	
	OFRetainedPtr <NSString> credentialsType = @"fbconnect"; 
	parameterStream->io("credential_type", credentialsType);	
}

- (void)closeLoginDialog
{
	if (loginDialog)
	{
		[loginDialog.session.delegates removeObject:self];
		loginDialog.delegate = nil;
		[loginDialog dismissWithSuccess:NO animated:YES];
		OFSafeRelease(loginDialog);
		
		[self cleanFixForBrokenWebKit];
	}
}

- (bool)shouldUseOAuth
{
	return self.addingAdditionalCredential;
}

- (void)registerActionsNow
{
}

- (void)logoutFromFacebook
{
	[self.fbSession logout];
	self.fbuid = nil;
	self.fbSession = nil;
}

- (void)promptToLogin
{	
	[self logoutFromFacebook];
	
	NSString* facebookApplicationKey = OFSettings::Instance()->getFacebookApplicationKey();
	NSString* sessionProxy = [NSString stringWithFormat:@"%@fbconnect/get_session", OFSettings::Instance()->getFacebookCallbackServerUrl()];
	FBSession* session = [FBSession sessionForApplication:facebookApplicationKey getSessionProxy:sessionProxy delegate:self];	
	
	loginDialog = [[FBLoginDialog alloc] initWithSession:session];
	loginDialog.delegate = self;
	

	[self setupFixForBrokenWebKit];
	
	[loginDialog show];
}

- (void)viewDidLoad
{
	self.navigationItem.hidesBackButton = YES;
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.fbLoggedInStatusImageView.image = [OFImageLoader loadImage:@"OpenFeintStatusIconNotificationFailure.png"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];	
	if (!skipLoginOnAppear)
	{
		[self promptToLogin];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self closeLoginDialog];
	[super viewWillDisappear:animated];
}

- (void)session:(FBSession*)session didLogin:(FBUID)uid
{
	[self closeLoginDialog];
	self.fbuid = uid;
	self.fbSession = session;
	self.fbLoggedInStatusImageView.image = [OFImageLoader loadImage:@"OpenFeintStatusIconNotificationSuccess.png"];
}

- (void)displayError:(NSString*)errorString
{
	OFSafeRelease(loginDialog);
	[[[[UIAlertView alloc] 
		initWithTitle:@"Facebook Connect Error"
		message:errorString
		delegate:nil
		cancelButtonTitle:@"Ok"
		otherButtonTitles:nil] autorelease] show];
	[self cleanFixForBrokenWebKit];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	[self displayError:[error localizedDescription]];
}

- (void)requestWasCancelled
{
	[self displayError:@"Unable to get your name from Facebook. Please make sure the proper permissions are set on your profile at http://www.facebook.com/"]; 
}
	
- (void)dialogDidCancel:(FBDialog*)dialog
{
	[self closeLoginDialog];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error
{
	[self displayError:[error localizedDescription]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:self.urlToLaunch];
	}
}

- (void)onPresentingErrorDialog
{
	[self promptToLogin];
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url
{
	self.urlToLaunch = url;
	
	NSString* message = [NSString stringWithFormat:@"Exit %@ and open %@ in Safari?", [OpenFeint applicationDisplayName], [url host]];
	
	UIAlertView* openAlert = [[[UIAlertView alloc] 
		initWithTitle:@"Open Link In Safari"
		message:message
		delegate:self
		cancelButtonTitle:@"Cancel"
		otherButtonTitles:nil] autorelease];
	[openAlert addButtonWithTitle:@"Open Link"];
	[openAlert show];
	
	return NO;
}

- (void)dealloc
{
	self.urlToLaunch = nil;
	self.fbSession = nil;
	self.fbuid = nil;
	self.fbLoggedInStatusImageView = nil;
	OFSafeRelease(loginDialog);
	[super dealloc];
}

@end