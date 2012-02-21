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

#import "OFPostNewMessage.h"

#import "OFForumService.h"
#import "OFForumTopic.h"
#import "OFForumThread.h"

#import "OFViewHelper.h"
#import "OFControllerLoader.h"
#import "OFNavigationController.h"
#import "OFISerializer.h"
#import "OFFormControllerHelper+Submit.h"

#import "OpenFeint.h"
#import "OpenFeint+UserOptions.h"

#import "UIButton+OpenFeint.h"

@interface OFPostNewMessage (Internal)
- (void)toggleSubjectView:(BOOL)visible;
@end

@implementation OFPostNewMessage

@synthesize topic, thread;

#pragma mark Boilerplate

+ (id)postNewMessageInTopic:(OFForumTopic*)_topic
{
	OFPostNewMessage* post = (OFPostNewMessage*)OFControllerLoader::load(@"PostNewMessage");
	post.topic = _topic;
	[post toggleSubjectView:YES];
	return post;
}

+ (id)postNewMessageInThread:(OFForumThread*)_thread topic:(OFForumTopic*)_topic
{
	OFPostNewMessage* post = (OFPostNewMessage*)OFControllerLoader::load(@"PostNewMessage");
	post.topic = _topic;
	post.thread = _thread;
	[post toggleSubjectView:NO];
	return post;
}

- (void)dealloc
{
	OFSafeRelease(subjectView);
	OFSafeRelease(bodyView);

	OFSafeRelease(subjectField);
	OFSafeRelease(bodyField);
	
	self.topic = nil;
	self.thread = nil;
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
		initWithTitle:@"Post" 
		style:UIBarButtonItemStylePlain 
		target:self 
		action:@selector(onSubmitForm:)] autorelease];

	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (thread == nil)
	{
		self.title = @"New Post";
		[subjectField becomeFirstResponder];
	}
	else
	{
		self.title = @"Reply";
		[bodyField becomeFirstResponder];
	}
}

#pragma mark OFCallbackable

- (bool)canReceiveCallbacksNow
{
	return true;
}

#pragma mark OFFormControllerHelper

- (IBAction)onSubmitForm:(UIView*)sender
{
	if ([subjectField.text length] == 0 && thread == nil)
	{
		[[[[UIAlertView alloc]
			initWithTitle:@"Incomplete" 
			message:@"Please enter a subject and try again." 
			delegate:nil 
			cancelButtonTitle:@"Ok" 
			otherButtonTitles:nil] autorelease] show];
	}
	else if ([bodyField.text length] == 0)
	{
		[[[[UIAlertView alloc]
			initWithTitle:@"Incomplete" 
			message:@"Please enter a message body and try again." 
			delegate:nil 
			cancelButtonTitle:@"Ok" 
			otherButtonTitles:nil] autorelease] show];
	}
	else
	{
		[super onSubmitForm:sender];
	}
}

- (void)registerActionsNow
{
}

- (NSString*)getFormSubmissionUrl
{
	if (thread == nil)
	{
		return [NSString stringWithFormat:@"topics/%@/discussions.xml", topic.resourceId];
	}
	else
	{
		return [NSString stringWithFormat:@"discussions/%@/posts.xml", thread.resourceId];
	}
}

- (void)onFormSubmitted
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSString*)singularResourceName
{
	return (thread ? @"post" : @"discussion");
}

- (void)addHiddenParameters:(OFISerializer*)parameterStream
{
	if (thread == nil)
	{
		parameterStream->io("discussion[subject]", subjectField.text);
		parameterStream->io("discussion[body]", bodyField.text);
	}
	else
	{
		parameterStream->io("post[body]", bodyField.text);
	}
}

#pragma mark Internal Methods

- (void)toggleSubjectView:(BOOL)visible
{
	if (visible == !subjectView.hidden)
		return;
		
	if (visible)
	{
		subjectView.hidden = NO;
		
		CGRect frame = bodyView.frame;
		frame.origin.y = subjectView.frame.size.height;
		frame.size.height -= subjectView.frame.size.height - 5.f;
		bodyView.frame = frame;
	}
	else
	{
		subjectView.hidden = YES;

		CGRect frame = bodyView.frame;
		frame.origin.y = 5.f;
		frame.size.height += subjectView.frame.size.height - 5.f;
		bodyView.frame = frame;
	}
}

@end
