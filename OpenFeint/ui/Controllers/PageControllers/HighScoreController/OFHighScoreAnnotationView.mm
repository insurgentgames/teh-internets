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

#ifdef __IPHONE_3_0
#import "OFHighScoreAnnotationView.h"
#import "OFHighScore.h"
#import "OFImageLoader.h"
#import "OpenFeint+UserOptions.h"

@interface OFHighScoreAnnotationView ()
@end


#pragma mark -
#pragma mark OFHighScoreAnnotationView implementation

@implementation OFHighScoreAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ( (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) ) {
		self.enabled = YES;
		self.canShowCallout = YES;
		self.multipleTouchEnabled = NO;
		
		self.image = (UIImage*)[OFImageLoader loadImage:@"OFBlankIcon.png"];
				
		OFSafeRelease(profilePictureView);
		
		[self setHighScoreAnnotation: (OFHighScoreAnnotation*) annotation];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        self.rightCalloutAccessoryView = rightButton;
	}
	return self;
}

-(void) setHighScoreAnnotation:(OFHighScoreAnnotation*) highScoreAnnotation;
{
	OFHighScore* highScore = highScoreAnnotation.highScore;
	
	//image for callout
	OFSafeRelease(profilePictureView)
	profilePictureView = [[OFImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f)];
	mapImageView.shouldScaleImageToFillRect = YES;
	[profilePictureView useProfilePictureFromUser:highScore.user];
	self.leftCalloutAccessoryView = profilePictureView;

	//image for map
	[mapImageView removeFromSuperview];
	OFSafeRelease(mapImageView)
	
	CGPoint p = self.centerOffset;	
	mapImageView= [[OFImageView alloc] initWithFrame:CGRectMake(p.x - 15, p.y - 15, 30.f, 30.f)];
	mapImageView.shouldScaleImageToFillRect = YES;
	[mapImageView useProfilePictureFromUser:highScore.user];
	//[mapImageView addSubview:highScoreAnnotation.rankBadge];
	[self addSubview:mapImageView];
	[self addSubview:highScoreAnnotation.rankBadge];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	//mapImageView.hidden = selected;
	[super setSelected:selected animated:animated];
}

- (void) dealloc
{
	OFSafeRelease(profilePictureView);

	[mapImageView removeFromSuperview];
	OFSafeRelease(mapImageView);	

	[super dealloc];
}

@end
#endif
