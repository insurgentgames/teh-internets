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
#import "OFServerMaintenanceNoticeController.h"
#import "OFControllerLoader.h"
#import "OFXmlDocument.h"
#import "OFActionRequest.h"

@implementation OFServerMaintenanceNoticeController

+ (id)maintenanceControllerWithHtmlData:(NSData*)data
{
	OFServerMaintenanceNoticeController* controller = (OFServerMaintenanceNoticeController*)OFControllerLoader::load(@"ServerMaintenanceNotice");
	
	OFXmlDocument* errorDocument = [OFXmlDocument xmlDocumentWithData:data];	
	controller.message = [errorDocument getElementValue:"server_interruption_notice"];
	
	return controller;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.hidesBackButton = YES;
	self.title = @"Maintenance";
	self.messageView.font = [UIFont systemFontOfSize:14.0f];
}

@end
