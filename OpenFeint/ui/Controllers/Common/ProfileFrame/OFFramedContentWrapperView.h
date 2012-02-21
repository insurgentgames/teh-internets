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

@class OFFramedContentWrapperView;

@protocol OFFramedContentWrapperViewDelegate<NSObject>
@required
- (BOOL)frameWasSet:(OFFramedContentWrapperView*)wrapperView;
@end

@interface OFFramedContentWrapperView : UIView
{
@package
	UIView* wrappedView;
	UIEdgeInsets contentInsets;
	id<OFFramedContentWrapperViewDelegate> delegate;
}

@property (nonatomic, retain) UIView* wrappedView;
@property (nonatomic, assign) id<OFFramedContentWrapperViewDelegate> delegate;

- (id)initWithWrappedView:(UIView*)_wrappedView;
- (void)setContentInsets:(UIEdgeInsets)_contentInsets;

@end
