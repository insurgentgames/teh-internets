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

#import "OFImportFriendsController.h"
#import "OFFriendImporter.h"

@implementation OFImportFriendsController

- (IBAction)onImportFromTwitter
{
	[mImporter.get() importFromTwitter];
}

- (IBAction)onImportFromFacebook
{
	[mImporter.get() importFromFacebook];
}

- (IBAction)onFindByName
{
	[mImporter.get() findByName];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		mImporter = [OFFriendImporter friendImporterWithController:self];
	}
	
	return self;
}

- (void)dealloc
{
	[mImporter.get() controllerDealloced];
	mImporter = NULL;
	[super dealloc];
}

- (void) setController:(UIViewController*)viewController
{
	mImporter->mController = viewController;
}

@end

