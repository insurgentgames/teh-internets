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

#import "OFTableSequenceControllerHelper.h"
#import "OFTabBar.h"
#import "OFProfileFrame.h"
#import <CoreLocation/CoreLocation.h>
#import "OFImportFriendsController.h"
#import "OFShareLocationController.h"

@class OFLeaderboard;
@class OFGameProfilePageInfo;

@interface OFHighScoreController : OFTableSequenceControllerHelper<OFProfileFrame, UINavigationControllerDelegate, OFShareLocationControllerCallback>
{
@package
	OFLeaderboard* leaderboard;
	BOOL friendsOnly;
	BOOL local;
	BOOL geolocation;
	IBOutlet OFTabBar* tabBar;
	NSString* noDataFoundMessage;
	OFGameProfilePageInfo* gameProfileInfo;
	OFImportFriendsController* importFriendsController;
	OFShareLocationController* shareLocationController;
    #ifdef __IPHONE_3_0
	IBOutlet UIButton* mapButton;
	#endif
}

- (void)showGlobalLeaderboard;
- (void)showFriendsLeaderboard;
- (void)showLocalLeaderboard;
- (void)showLocationLeaderboard;

- (void)onCellWasClicked:(OFResource*)cellResource indexPathInTable:(NSIndexPath*)indexPath;
- (void)doIndexActionWithPageForLocation:(CLLocation*)origin radius:(int)radius pageIndex:(NSInteger)pageIndex onSuccess:(const OFDelegate&)success onFailure:(const OFDelegate&)failure;
- (IBAction) _clickedMap;

@property (nonatomic, retain) OFLeaderboard* leaderboard;
@property (nonatomic, retain) NSString* noDataFoundMessage;
@property (nonatomic, retain) OFGameProfilePageInfo* gameProfileInfo;

@end
