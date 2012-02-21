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

#import "OFPresenceService.h"
#import "OFCRVStompClient.h"
#import "OFSettings.h"
#import "OFUser.h"
#import "OpenFeint+NSNotification.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+Dashboard.h"
#import "OFPresenceQueue.h"
#import "OFReachability.h"

#import "OFXmlDocument.h"
#import "OFPaginatedSeries.h"
#import "OFNotification.h"
#import "OFInputResponseOpenDashboard.h"
#import "OFInboxController.h"
#import "OFForumPost.h"
#import "OFPoller.h"
#import "OFService+Private.h"

#import "OpenFeint+Private.h"
#import "MPOAuthAPI.h"
#import "NSURL+MPURLParameterAdditions.h"
#import "OFConversationController.h"


const NSAutoreleasePool *presencePool;


OPENFEINT_DEFINE_SERVICE_INSTANCE(OFPresenceService)

@interface OFPresenceHTTPResponse : NSHTTPURLResponse
{
	NSInteger secretSauceStatusCode;
}
-(id)initWithSecretSauceStatusCode:(NSInteger)theStatusCode;
@end


@implementation OFPresenceHTTPResponse 
-(id)initWithSecretSauceStatusCode:(NSInteger)theStatusCode {
	self = [super init];
	if (self != nil) {
		secretSauceStatusCode = theStatusCode;
	}
	return self;
}
-(NSInteger)statusCode {
	return secretSauceStatusCode;
}
@end

@implementation OFPresenceService

@synthesize isConnected;
@synthesize isHttpPipeEnabled;
@synthesize isShuttingDown;
@synthesize isBroadcastingStatus;

@synthesize currentThread;
@synthesize accessToken;
@synthesize presenceQueue;
@synthesize httpRequests;
@synthesize stompClient;

-(void)dealloc
{
	//OFLog(@"OFPresenceService::dealloc");
	
	[httpRequests removeAllObjects];
	[httpRequests release];
	
	[presenceQueue release];
	[accessToken release];
	[currentThread release];
	
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		retriesAttempted = 0;
		isConnected = NO;
		isShuttingDown = NO;
		isBroadcastingStatus = NO;
		[self setHttpRequests:[NSMutableDictionary dictionaryWithCapacity:0]];
	}
	
	return self;
}

- (void)populateKnownResources:(OFResourceNameMap*)namedResources
{
	namedResources->addResource([OFUser getResourceName], [OFUser class]);
	namedResources->addResource([OFForumPost getResourceName], [OFForumPost class]);
	namedResources->addResource([OFPresenceQueue getResourceName], [OFPresenceQueue class]);
}

-(void)connectToPresenceQueue:(NSString*)thePresenceQueue withOAuthAccessToken:(NSString *)theOAuthAccessToken andHttpPipeEnabled:(BOOL)theHttpPipeEnabled andBroadcastStatus:(BOOL)initializePresenceService
{
	if ([[OpenFeint provider] isAuthenticated]) {
		[self setIsBroadcastingStatus:initializePresenceService];
		[self setIsHttpPipeEnabled:theHttpPipeEnabled];
		[self setAccessToken:theOAuthAccessToken];
		[self setPresenceQueue:thePresenceQueue];
		if (isBroadcastingStatus) {
			[self connect];
		}
	}
}

-(void)connect
{
	//OFLog(@"should connect?");
	if (retriesAttempted++ < 6 && !isShuttingDown) {
		//OFLog(@"going to connect");
		if (currentThread) {
			[self performSelector:@selector(connectInBackground:) onThread:currentThread withObject:nil waitUntilDone:NO];
		} else {
			[NSThread detachNewThreadSelector:@selector(connectInBackground:) toTarget:self withObject:nil];
		}
	}
}

-(void)requestNewPresenceQueue
{
	OFDelegate success = OFDelegate(self, @selector(onPresenceQueueLoaded:));
	OFDelegate failure = OFDelegate(self, @selector(onFailedToLoadPresenceQueue));
	
	[self postAction:@"presence/queue.xml"
	  withParameters:nil
		 withSuccess:success
		 withFailure:failure
	 withRequestType:OFActionRequestSilent
		  withNotice:nil];
}

-(void)onPresenceQueueLoaded:(OFPaginatedSeries *)resources
{
	//OFLog(@"gotPresenceQueue success response... %d %@", [resources count], [resources objectAtIndex:0]);
	if ([resources count] == 1) {
		if ([[resources objectAtIndex:0] isKindOfClass:[OFPresenceQueue class]]) {
			//OFLog(@"got new presence_queue: %@", [[resources objectAtIndex:0] name]);
			[self setPresenceQueue:[[resources objectAtIndex:0] name]];
			[self connect];
		}
	}
}

-(void)onFailedToLoadPresenceQueue
{
	//OFLog(@"gotPresenceQueue failed response...");
	[self performSelector:@selector(connect) withObject:nil afterDelay:15.0];
}

- (void)connectInBackground:(id)userInfo
{
	if (!isShuttingDown) {
		if (presenceQueue && OFReachability::Instance()->isGameServerReachable()) {
			if (presencePool) {
				[presencePool release];
				presencePool = nil;
			}
			
			presencePool = [[NSAutoreleasePool alloc] init];
			
			if (currentThread) {
			} else {
				[self setCurrentThread:[NSThread currentThread]];
			}
			
			if (stompClient) {
				[stompClient release];
				stompClient = nil;
			}
			
			stompClient = [[OFCRVStompClient alloc] initWithHost:OFSettings::Instance()->getPresenceHost() port:61613 login:[[OpenFeint localUser] resourceId] passcode:accessToken delegate:self autoconnect:YES];

		} else {
			[self performSelector:@selector(requestNewPresenceQueue) withObject:nil afterDelay:15.0];
		}
	}
	[[NSRunLoop currentRunLoop] run];
}

-(void)postInMainThread:(id)resource
{
	//OFLog(@"got push");
	NSString *notice;

	[[NSNotificationCenter defaultCenter] postNotificationName:[[resource class] getResourceDiscoveredNotification] object:nil userInfo:[NSDictionary dictionaryWithObject:[NSArray arrayWithObject:resource] forKey:OFPollerNotificationKeyForResources]];	
	if ([resource isKindOfClass:[OFForumPost class]]) {
		
		//OFTabbedDashboardPageController
		////OFGameProfileController
		////OFMyFeintController
		//////OFInboxController
		////////OFConversationController
		id tabBarController = [OpenFeint getActiveNavigationController];
		if (tabBarController) {
			id topViewController = [tabBarController topViewController];
			if ([topViewController isKindOfClass:[OFInboxController class]]) {
				[topViewController reloadDataFromServer];
				return;
			} else if ([topViewController isKindOfClass:[OFConversationController class]]) {
				return;
			} else {
				if ([OpenFeint unreadInboxCount] == 0) {
					[OpenFeint setUnreadInboxCount:[OpenFeint unreadInboxCount] + 1];
				}
				return;
			}
		}
		
		OFInboxController *inboxController = [[OFInboxController alloc] initAndBeginConversationWith:[resource author]];
		
		OFNotificationData *notificationData;
		OFNotificationInputResponse* inputResponse;
		notice = [NSString stringWithFormat:@"New message from %@", [[resource author] name]];
		inputResponse = [[[OFInputResponseOpenDashboard alloc] 
						  initWithTab:OpenFeintDashBoardTabMyFeint
						  andController:inboxController] autorelease];
		notificationData = [OFNotificationData dataWithText:notice andCategory:kNotificationCategoryPresence andType:kNotificationTypeNewMessage];
		[[OFNotification sharedInstance] showBackgroundNotice:notificationData andStatus:OFNotificationStatusSuccess andInputResponse:inputResponse];
		[inboxController release];
	} else if ([resource isKindOfClass:[OFUser class]]) {
		OFNotificationData *notificationData;
		OFNotificationType notificationType;
		OFNotificationInputResponse* inputResponse;
		if ([resource online]) {
			notice = [NSString stringWithFormat:@"%@ is online", [resource name]];
			notificationType = kNotificationTypeUserPresenceOnline;
			OFInboxController *inboxController = [[OFInboxController alloc] initAndBeginConversationWith:resource];
			inputResponse = [[[OFInputResponseOpenDashboard alloc] 
							  initWithTab:OpenFeintDashBoardTabMyFeint
							  andController:inboxController] autorelease];
			notificationData = [OFNotificationData dataWithText:notice andCategory:kNotificationCategoryPresence andType:notificationType];
			[[OFNotification sharedInstance] showBackgroundNotice:notificationData andStatus:OFNotificationStatusSuccess andInputResponse:inputResponse];
			[inboxController release];
		}
	}
}

- (void)stompClient:(OFCRVStompClient *)theStompClient messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader
{
	if ([messageHeader objectForKey:@"X-HTTP-REQUEST"]) {
		NSString *theRequest = [messageHeader objectForKey:@"X-HTTP-REQUEST"];
		NSArray *httpRequest = [httpRequests objectForKey:theRequest];
		if (httpRequest) {
			OFPresenceHTTPResponse *theResponse = [[OFPresenceHTTPResponse alloc] initWithSecretSauceStatusCode:[[messageHeader objectForKey:@"X-HTTP-STATUS"] intValue]];
			NSData *data = [[body stringByReplacingOccurrencesOfString:@"\0" withString:@""] dataUsingEncoding:NSUTF8StringEncoding];
			[[httpRequest objectAtIndex:2] connection:[httpRequest objectAtIndex:0] didReceiveResponse:theResponse];
			[[httpRequest objectAtIndex:2] connection:[httpRequest objectAtIndex:0] didReceiveData:data];
			[[httpRequest objectAtIndex:2] connectionDidFinishLoading:[httpRequest objectAtIndex:0]];
			[theResponse release];
			[httpRequests removeObjectForKey:theRequest];
		}
	} else {
		OFXmlDocument *doc = [OFXmlDocument xmlDocumentWithString:[body stringByReplacingOccurrencesOfString:@"\0" withString:@""]];
		OFPaginatedSeries *resources = [OFResource resourcesFromXml:doc withMap:[self getKnownResources]];
		for (id resource in [resources objects]) {
			[self performSelectorOnMainThread:@selector(postInMainThread:) withObject:resource waitUntilDone:NO];
		}

	}
	[theStompClient ack: [messageHeader valueForKey:@"message-id"]];
}

- (void)stompClientDidDisconnect:(OFCRVStompClient *)theStompClient
{
	//OFLog(@"didDisconnect");
	isConnected = NO;
	[self connect];
}

- (void)stompClientDidConnect:(OFCRVStompClient *)theStompClient
{
	//OFLog(@"didConnect, subscribing to: %@", presenceQueue);
	isConnected = YES;
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"true", @"auto-delete",
							 @"true", @"exclusive"
							 , nil];
	[theStompClient subscribeToDestination:presenceQueue withHeader:headers];
	[presenceQueue release];
	presenceQueue = nil;
}

- (void)serverDidSendReceipt:(OFCRVStompClient *)theStompClient withReceiptId:(NSString *)receiptId
{
	OFLog(@"didSendReceipt");
}

- (void)serverDidSendError:(OFCRVStompClient *)theStompClient withErrorMessage:(NSString *)description detailedErrorMessage:(NSString *) theMessage
{
	[self disconnectAndShutdown:YES];
}

-(void)disconnectAndShutdown:(BOOL)shutdown
{
	//OFLog(@"disconnectAndShutdown? %d", shutdown);

	isConnected = NO;
	isShuttingDown = shutdown;
	if (stompClient) {
		[stompClient release];
		stompClient = nil;
	}
}

-(void)wrapUrlConnection:(id)theUrlConnection andRequest:(id)theRequest andDelegate:(id)theDelegate
{	
	NSString *generatedNonce = nil;
	CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
	generatedNonce = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, generatedUUID);
	CFRelease(generatedUUID);
	NSArray *httpRequest = [NSArray arrayWithObjects:theUrlConnection, theRequest, theDelegate, nil];
	[httpRequests setObject:httpRequest forKey:generatedNonce];
	[self performSelector:@selector(sendHttpRequest:) onThread:currentThread withObject:generatedNonce waitUntilDone:NO];
	CFRelease(generatedNonce);
}

- (NSString *)stringFromStreamData:(NSData *)data
{
	
	if (data == nil) return @"";
	
	// optimistically, see if the whole data block is UTF-8
	NSString *streamDataStr = [[[NSString alloc] initWithData:data
													 encoding:NSUTF8StringEncoding] autorelease];
	if (streamDataStr) return streamDataStr;
	
	// Munge a buffer by replacing non-ASCII bytes with underscores,
	// and turn that munged buffer an NSString.  That gives us a string
	// we can use with NSScanner.
	NSMutableData *mutableData = [NSMutableData dataWithData:data];
	unsigned char *bytes = (unsigned char *)[mutableData mutableBytes];
	
	for (NSUInteger idx = 0; idx < [mutableData length]; idx++) {
		if (bytes[idx] > 0x7F || bytes[idx] == 0) {
			bytes[idx] = '_';
		}
	}
	
	NSString *mungedStr = [[[NSString alloc] initWithData:mutableData
												 encoding:NSUTF8StringEncoding] autorelease];
	if (mungedStr != nil) {
		
		// scan for the boundary string
		NSString *boundary = nil;
		NSScanner *scanner = [NSScanner scannerWithString:mungedStr];
		
		if ([scanner scanUpToString:@"\r\n" intoString:&boundary]
			&& [boundary hasPrefix:@"--"]) {
			
			// we found a boundary string; use it to divide the string into parts
			NSArray *mungedParts = [mungedStr componentsSeparatedByString:boundary];
			
			// look at each of the munged parts in the original string, and try to 
			// convert those into UTF-8
			NSMutableArray *origParts = [NSMutableArray array];
			NSUInteger offset = 0;
			for (NSUInteger partIdx = 0; partIdx < [mungedParts count]; partIdx++) {
				
				NSString *mungedPart = [mungedParts objectAtIndex:partIdx];
				NSUInteger partSize = [mungedPart length];
				
				NSRange range = NSMakeRange(offset, partSize);
				NSData *origPartData = [data subdataWithRange:range];
				
				NSString *origPartStr = [[[NSString alloc] initWithData:origPartData
															   encoding:NSUTF8StringEncoding] autorelease];
				if (origPartStr) {
					// we could make this original part into UTF-8; use the string
					[origParts addObject:origPartStr];
				} else {
					// this part can't be made into UTF-8; scan the header, if we can
					NSString *header = nil;
					NSScanner *headerScanner = [NSScanner scannerWithString:mungedPart];
					if (![headerScanner scanUpToString:@"\r\n\r\n" intoString:&header]) {
						// we couldn't find a header
						header = @"";
					}
					
					// make a part string with the header and <<n bytes>>
					NSString *binStr = [NSString stringWithFormat:@"\r%@\r<<%u bytes>>\r",
										header, partSize - [header length]];
					[origParts addObject:binStr];
				}
				offset += partSize + [boundary length];
			}
			
			// rejoin the original parts
			streamDataStr = [origParts componentsJoinedByString:boundary];
		}
	}  
	
	if (!streamDataStr) {
		// give up; just make a string showing the uploaded bytes
		streamDataStr = [NSString stringWithFormat:@"<<%u bytes>>", [data length]];
	}
	return streamDataStr;
}

-(void)sendHttpRequest:(NSString *)theRequest
{
	NSArray *httpRequest = [httpRequests objectForKey:theRequest];	
	NSString *contentType = [[httpRequest objectAtIndex:1] valueForHTTPHeaderField:@"Content-Type"];
	if (contentType == nil) {
		NSString *method = [[httpRequest objectAtIndex:1] HTTPMethod];
		NSString *absolute_url = [[[httpRequest objectAtIndex:1] URL] absoluteNormalizedString];
		NSString *body = [self stringFromStreamData:[[httpRequest objectAtIndex:1] HTTPBody]];
		contentType = @"application/x-www-form-urlencoded";
		[[httpRequest objectAtIndex:0] cancel];
		[stompClient pipeHttpRequest:theRequest withMethod:method andContentType:contentType andUrl:absolute_url andBody:body];
	} else {
		[[httpRequest objectAtIndex:0] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[[httpRequest objectAtIndex:0] start];
		[httpRequests removeObjectForKey:theRequest];
	}
	
	/*
	NSArray *httpRequest = [httpRequests objectForKey:theRequest];	
	NSString *contentType = [[httpRequest objectAtIndex:1] valueForHTTPHeaderField:@"Content-Type"];
	NSString *method = [[httpRequest objectAtIndex:1] HTTPMethod];
	NSString *absolute_url = [[[httpRequest objectAtIndex:1] URL] absoluteNormalizedString];
	NSString *body = [self stringFromStreamData:[[httpRequest objectAtIndex:1] HTTPBody]];

	
	if (contentType == nil) {

		contentType = @"application/x-www-form-urlencoded";

	}
	
	[[httpRequest objectAtIndex:0] cancel];
	[[stompClients objectAtIndex:0] pipeHttpRequest:theRequest withMethod:method andContentType:contentType andUrl:absolute_url andBody:body];
	 */
}

+(BOOL)isHttpPipeEnabled
{
	return ([self sharedInstance] != nil) && ([[self sharedInstance] isConnected]) && ([[self sharedInstance] isHttpPipeEnabled]);
}

+ (OFPresenceService *)sharedInstance
{
	return OFPresenceServiceInstance;
}

+ (void)initializeService
{
	OFPresenceServiceInstance = [[OFPresenceService alloc] init];
}

+ (void)releasePP
{
	OFSafeRelease(presencePool);
}

+ (void)shutdownService
{
	NSThread* otherThread = [self sharedInstance].currentThread;
	
	[[self sharedInstance] disconnectAndShutdown:YES];
	int retainCount = [OFPresenceServiceInstance retainCount];
	if (retainCount > 1) {
		OFLog(@"OFPresenceService has outstanding references during shtudown! %d", retainCount);
	}
	[OFPresenceServiceInstance autorelease];
	
	if (otherThread)
	{
		[self performSelector:@selector(releasePP) onThread:otherThread withObject:nil waitUntilDone:YES];
	}
}

@end
