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

#import "OFExpandableSinglelineTextField.h"

#pragma mark Internal Text View

@interface OFTextView : UITextView
{
	CGFloat lineHeight;
}

@property (assign) CGFloat lineHeight;

@end

@implementation OFTextView

@synthesize lineHeight;

- (void)setContentSize:(CGSize)size
{
	size.height = floorf(size.height / lineHeight) * lineHeight;
	[super setContentSize:size];
}

- (void)setContentInset:(UIEdgeInsets)insets
{
	insets = UIEdgeInsetsMake(3.f, 0.f, 3.f, 0.f);
	[super setContentInset:insets];
}

@end

#pragma mark Multiline Text Field

@implementation OFExpandableSinglelineTextField

@synthesize minLines, maxLines, multilineTextFieldDelegate;

#pragma mark Boilerplate

- (void)dealloc
{
	[internalTextView removeFromSuperview];
	OFSafeRelease(internalTextView);
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	NSString* testString = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	lineHeight = [testString sizeWithFont:self.font constrainedToSize:CGSizeMake(FLT_MAX, 0)].height;
	
	minLines = MAX(1, minLines);
	maxLines = MAX(1, maxLines);

	CGRect textViewFrame = self.frame;
	textViewFrame.origin = CGPointZero;
	internalTextView = [[OFTextView alloc] initWithFrame:textViewFrame];
	internalTextView.delegate = self;
	internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	internalTextView.backgroundColor = [UIColor clearColor];
	internalTextView.font = self.font;
	internalTextView.lineHeight = lineHeight;
	internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	internalTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;

	[self addSubview:internalTextView];
	[self bringSubviewToFront:internalTextView];
}

#pragma mark Public Methods

- (void)setText:(NSString*)text
{
	internalTextView.text = text;
	[self textView:internalTextView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@""];
}

- (NSString*)text
{
	return internalTextView.text;
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder
{
	return [internalTextView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	return [internalTextView becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
	return [internalTextView canResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [internalTextView resignFirstResponder];
}

- (BOOL)isFirstResponder
{
	return [internalTextView isFirstResponder];
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSString* modifiedText = [[textView.text stringByReplacingCharactersInRange:range withString:text] stringByAppendingString:@" "];

	CGSize modifiedSize = [modifiedText sizeWithFont:textView.font constrainedToSize:CGSizeMake(textView.contentSize.width - 14.f, FLT_MAX)];
	modifiedSize.height = MIN(modifiedSize.height, maxLines * lineHeight);
	modifiedSize.height = MAX(modifiedSize.height, minLines * lineHeight);
	
	CGRect myFrame = self.frame;
	myFrame.size.height = modifiedSize.height + 7.f;
	self.frame = myFrame;

	[multilineTextFieldDelegate multilineTextFieldDidResize:self];
	
	return YES;
}

@end
