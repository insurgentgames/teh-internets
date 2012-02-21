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
#import "OFTabbedDashboardPageController.h"
#import "OpenFeint.h"
#import "OFControllerLoader.h"
#import "OpenFeint+Settings.h"
#import "OFResumeView.h"

@implementation OFTabbedDashboardPageController

+ (UIViewController*)pageWithController:(NSString*)controllerName
{
	OFTabbedDashboardPageController* page = [[OFTabbedDashboardPageController new] autorelease];
	[page pushViewController:OFControllerLoader::load(controllerName) animated:NO];
	return page;
}

+ (UIViewController*)pageWithInstantiatedController:(UIViewController*)controller
{
	OFTabbedDashboardPageController* page = [[OFTabbedDashboardPageController new] autorelease];
	[page pushViewController:controller animated:NO];
	return page;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{	
	[super navigationController:navigationController willShowViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{	
	[super navigationController:navigationController didShowViewController:viewController animated:animated];
}

- (void)_orderViewDepths
{
	[super _orderViewDepths];
	if (self.visibleViewController.navigationItem.rightBarButtonItem)
	{
		[self.navigationBar bringSubviewToFront:self.visibleViewController.navigationItem.rightBarButtonItem.customView];
	}
}

@end
