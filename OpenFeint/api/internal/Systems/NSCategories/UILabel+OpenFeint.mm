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

#import "UILabel+OpenFeint.h"

@implementation UILabel (OpenFeint)

+ (id)labelForTableHeader
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:17.f];
	label.textColor = [UIColor colorWithWhite:231.f/255.f alpha:1.f];
	label.shadowColor = [UIColor colorWithWhite:134.f/255.f alpha:1.f];
	label.shadowOffset = CGSizeMake(0.f, 1.f);
	return label;
}

+ (id)labelForTableItem
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:16.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForTableItemWithSubtext
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:14.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForTableSubtext1
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:12.f];
	label.textColor = [UIColor colorWithWhite:119.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForTableSubtext2
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont italicSystemFontOfSize:12.f];
	label.textColor = [UIColor colorWithWhite:119.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForSmallText
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:12.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForHeadlineText
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:18.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForExplanationText
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont systemFontOfSize:12.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

+ (id)labelForTitleText
{
	UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.font = [UIFont boldSystemFontOfSize:14.f];
	label.textColor = [UIColor colorWithWhite:89.f/255.f alpha:1.f];
	return label;
}

@end
