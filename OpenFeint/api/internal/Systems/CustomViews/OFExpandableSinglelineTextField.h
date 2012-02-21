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

@class OFTextView;
@class OFExpandableSinglelineTextField;

@protocol OFExpandableSinglelineTextFieldDelegate
@required
- (void)multilineTextFieldDidResize:(OFExpandableSinglelineTextField*)multilineTextField;
@end

@interface OFExpandableSinglelineTextField : UITextField< UITextViewDelegate >
{
	OFTextView* internalTextView;
	CGFloat lineHeight;
	NSInteger minLines;
	NSInteger maxLines;
	
	id<OFExpandableSinglelineTextFieldDelegate> multilineTextFieldDelegate;
}

@property (assign) NSInteger minLines;
@property (assign) NSInteger maxLines;

@property (assign) id<OFExpandableSinglelineTextFieldDelegate> multilineTextFieldDelegate;

- (void)setText:(NSString*)text;
- (NSString*)text;

@end
