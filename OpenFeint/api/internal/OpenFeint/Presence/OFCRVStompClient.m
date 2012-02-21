//
//  CRVStompClient.h
//  Objc-Stomp
//
//
//  Implements the Stomp Protocol v1.0
//  See: http://stomp.codehaus.org/Protocol
// 
//  Requires the AsyncSocket library
//  See: http://code.google.com/p/cocoaasyncsocket/
//
//  This class is in the public domain.
//	Stefan Saasen <stefan@coravy.com>
//  Based on StompService.{h,m} by Scott Raymond <sco@scottraymond.net>.


	
#import <CFNetwork/CFNetwork.h>
#import "OFCRVStompClient.h"


#define kStompDefaultPort			61613
#define kDefaultTimeout				5	//


// ============= http://stomp.codehaus.org/Protocol =============
#define kCommandConnect				@"CONNECT"
#define kCommandSend				@"SEND"
#define kCommandSubscribe			@"SUBSCRIBE"
#define kCommandUnsubscribe			@"UNSUBSCRIBE"
#define kCommandBegin				@"BEGIN"
#define kCommandCommit				@"COMMIT"
#define kCommandAbort				@"ABORT"
#define kCommandAck					@"ACK"
#define kCommandDisconnect			@"DISCONNECT"
#define	kControlChar				[NSString stringWithFormat:@"\n%C", 0] // TODO -> static

#define kAckClient					@"client"
#define kAckAuto					@"auto"

#define kResponseHeaderSession		@"session"
#define kResponseHeaderReceiptId	@"receipt-id"
#define kResponseHeaderErrorMessage @"message"

#define kResponseFrameConnected		@"CONNECTED"
#define kResponseFrameMessage		@"MESSAGE"
#define kResponseFrameReceipt		@"RECEIPT"
#define kResponseFrameError			@"ERROR"
// ============= http://stomp.codehaus.org/Protocol =============

#define CRV_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

@interface OFCRVStompClient()
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, retain) OFAsyncSocket *socket;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *passcode;
@property (nonatomic, copy) NSString *sessionId;
@end

@interface OFCRVStompClient(PrivateMethods)
- (void) sendFrame:(NSString *) command withHeader:(NSDictionary *) header andBody:(NSString *) body;
- (void) sendFrame:(NSString *) command;
- (void) readFrame;
@end

@implementation OFCRVStompClient

@synthesize delegate;
@synthesize socket, host, port, login, passcode, sessionId;

- (id)init {
	return [self initWithHost:@"localhost" port:kStompDefaultPort login:nil passcode:nil delegate:nil];
}

- (id)initWithHost:(NSString *)theHost 
			  port:(NSUInteger)thePort 
			 login:(NSString *)theLogin 
		  passcode:(NSString *)thePasscode 
		  delegate:(id<OFCRVStompClientDelegate>)theDelegate {
	return [self initWithHost:theHost port:thePort login:theLogin passcode:thePasscode delegate:theDelegate autoconnect: NO];
}

- (id)initWithHost:(NSString *)theHost 
			  port:(NSUInteger)thePort 
			 login:(NSString *)theLogin 
		  passcode:(NSString *)thePasscode 
		  delegate:(id<OFCRVStompClientDelegate>)theDelegate
	   autoconnect:(BOOL) autoconnect {
	self = [super init];
	if(self != nil) {
		
		doAutoconnect = autoconnect;
		
		OFAsyncSocket *theSocket = [[OFAsyncSocket alloc] initWithDelegate:self];
		[self setSocket: theSocket];
		[theSocket release];

		
		[self setDelegate:theDelegate];
		[self setHost: theHost];
		[self setPort: thePort];
		[self setLogin: theLogin];
		[self setPasscode: thePasscode];
		
		NSError *err;
		if(![self.socket connectToHost:self.host onPort:self.port error:&err]) {
			NSLog(@"StompService error: %@", err);
		}
	}
	return self;
}


- (void)retrySocket {
	NSError *err;
	if(![self.socket connectToHost:self.host onPort:self.port error:&err]) {
		NSLog(@"StompService retry error: %@", err);
	}
}


#pragma mark -
#pragma mark Public methods
- (void)connect {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: [self login], @"login", [self passcode], @"passcode", nil];
	[self sendFrame:kCommandConnect withHeader:headers andBody: nil];
	[self readFrame];
}

- (void)sendMessage:(NSString *)theMessage toDestination:(NSString *)destination {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", @"amq.topic", @"exchange", nil];
    [self sendFrame:kCommandSend withHeader:headers andBody:theMessage];
}

- (void)pipeHttpRequest:(NSString *)theRequest withMethod:(NSString *)theMethod andContentType:(NSString *)theContentType andUrl:(NSString *)theUrl andBody:(NSString *)theBody {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: @"mcp", @"destination", theRequest, @"X-HTTP-REQUEST", theMethod, @"X-HTTP-METHOD", theContentType, @"X-HTTP-CONTENT-TYPE", theUrl, @"X-HTTP-URL", nil];
    [self sendFrame:kCommandSend withHeader:headers andBody:theBody];
}

- (void)pingMcp {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: @"mcp", @"destination", nil];
    [self sendFrame:kCommandSend withHeader:headers andBody:@"ping"];
}

- (void)subscribeToDestination:(NSString *)destination {
	[self subscribeToDestination:destination withAck: CRVStompAckModeAuto];
}

- (void)subscribeToDestination:(NSString *)destination withAck:(CRVStompAckMode) ackMode {
	NSString *ack;
	switch (ackMode) {
		case CRVStompAckModeClient:
			ack = kAckClient;
			break;
		default:
			ack = kAckAuto;
			break;
	}
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", ack, @"ack", nil];
    [self sendFrame:kCommandSubscribe withHeader:headers andBody:nil];
}

- (void)subscribeToDestination:(NSString *)destination withHeader:(NSDictionary *) header {
	NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:header];
	[headers setObject:destination forKey:@"destination"];
    [self sendFrame:kCommandSubscribe withHeader:headers andBody:nil];
	[headers release];
}

- (void)unsubscribeFromDestination:(NSString *)destination {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: destination, @"destination", nil];
    [self sendFrame:kCommandUnsubscribe withHeader:headers andBody:nil];
}

-(void)begin:(NSString *)transactionId {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: transactionId, @"transaction", nil];
    [self sendFrame:kCommandBegin withHeader:headers andBody:nil];
}

- (void)commit:(NSString *)transactionId {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: transactionId, @"transaction", nil];
    [self sendFrame:kCommandCommit withHeader:headers andBody:nil];
}

- (void)abort:(NSString *)transactionId {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: transactionId, @"transaction", nil];
    [self sendFrame:kCommandAbort withHeader:headers andBody:nil];
}

- (void)ack:(NSString *)messageId {
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys: messageId, @"message-id", nil];
    [self sendFrame:kCommandAck withHeader:headers andBody:nil];
}

- (void)disconnect {
	/*
	[self sendFrame:kCommandDisconnect];
	[[self socket] disconnectAfterReadingAndWriting];
	 */
	[[self socket] disconnect];
}

#pragma mark -
#pragma mark PrivateMethods
- (void) sendFrame:(NSString *) command withHeader:(NSDictionary *) header andBody:(NSString *) body {
    NSMutableString *frameString = [NSMutableString stringWithString: [command stringByAppendingString:@"\n"]];	
	for (id key in header) {
		[frameString appendString:key];
		[frameString appendString:@":"];
		[frameString appendString:[header objectForKey:key]];
		[frameString appendString:@"\n"];
	}
	if (body) {
		[frameString appendString:@"\n"];
		[frameString appendString:body];
	}
	//OFLog(@"sendFrame: %@", frameString);
    [frameString appendString:kControlChar];
	[[self socket] writeData:[frameString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:kDefaultTimeout tag:123];
}

- (void) sendFrame:(NSString *) command {
	[self sendFrame:command withHeader:nil andBody:nil];
}

- (void)receiveFrame:(NSString *)command headers:(NSDictionary *)headers body:(NSString *)body {	
	// Connected
	if([kResponseFrameConnected isEqual:command]) {
		if([[self delegate] respondsToSelector:@selector(stompClientDidConnect:)]) {
			[[self delegate] stompClientDidConnect:self];
		}
		
		// store session-id
		NSString *sessId = [headers valueForKey:kResponseHeaderSession];
		[self setSessionId: sessId];
	
	// Response 
	} else if([kResponseFrameMessage isEqual:command]) {
		[[self delegate] stompClient:self messageReceived:body withHeader:headers];
		
	// Receipt
	} else if([kResponseFrameReceipt isEqual:command]) {		
		if([[self delegate] respondsToSelector:@selector(serverDidSendReceipt:withReceiptId:)]) {
			NSString *receiptId = [headers valueForKey:kResponseHeaderReceiptId];
			[[self delegate] serverDidSendReceipt:self withReceiptId: receiptId];
		}	
	
	// Error
	} else if([kResponseFrameError isEqual:command]) {
		if([[self delegate] respondsToSelector:@selector(serverDidSendError:withErrorMessage:detailedErrorMessage:)]) {
			NSString *msg = [headers valueForKey:kResponseHeaderErrorMessage];
			[[self delegate] serverDidSendError:self withErrorMessage: msg detailedErrorMessage: body];
		}		
	}
}

- (void)readFrame {
	//OFLog(@"readFrame");
	[[self socket] readDataToData:[OFAsyncSocket ZeroData] withTimeout:-1 tag:0];
}

#pragma mark -
#pragma mark AsyncSocketDelegate

- (void)onSocket:(OFAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length])];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    NSMutableArray *contents = (NSMutableArray *)[msg componentsSeparatedByString:@"\n"];
	if([[contents objectAtIndex:0] isEqual:@""]) {
		[contents removeObjectAtIndex:0];
	}
	NSString *command = [[[contents objectAtIndex:0] copy] autorelease];
	NSMutableDictionary *headers = [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableString *body = [[[NSMutableString alloc] init] autorelease];
	BOOL hasHeaders = NO;
    [contents removeObjectAtIndex:0];
	for(NSString *line in contents) {
		if(hasHeaders) {
			[body appendString:line];
			[body appendString:@"\n"];
		} else {
			if ([line isEqual:@""]) {
				hasHeaders = YES;
			} else {
				// message-id can look like this: message-id:ID:macbook-pro.local-50389-1237007652070-5:6:-1:1:1
				NSMutableArray *parts = [NSMutableArray arrayWithArray:[line componentsSeparatedByString:@":"]];
				// key ist the first part
				NSString *key = [parts objectAtIndex:0];
				[parts removeObjectAtIndex:0];
				[headers setObject:[parts componentsJoinedByString:@":"] forKey:key];
			}
		}
	}
	[msg release];
	[self receiveFrame:command headers:headers body:body];
	[self readFrame];
}

- (void)onSocket:(OFAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {	
	NSMutableDictionary * settings = [NSMutableDictionary dictionaryWithCapacity:3];
	
	
	// Use the highest possible security
	[settings setObject:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
				 forKey:(NSString *)kCFStreamSSLLevel];
	
	// Allow self-signed certificates
	[settings setObject:[NSNumber numberWithBool:YES]
				 forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	
	// Dont do certs
	[settings setObject:[NSNumber numberWithBool:NO]
				 forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
	
	[sock startTLS:settings];

}

- (void)onSocket:(OFAsyncSocket *)sock didSecure:(BOOL)flag {
	if(flag && doAutoconnect) {
		[self connect];
	}
}

- (void)onSocket:(OFAsyncSocket *)sock didWriteDataWithTag:(long)tag {
}

- (void)onSocketDidDisconnect:(OFAsyncSocket *)sock {
	if([[self delegate] respondsToSelector:@selector(stompClientDidDisconnect:)]) {
		[[self delegate] stompClientDidDisconnect: self];
	}
}

/*
-(NSTimeInterval)onSocket:(OFAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length {
	OFLog(@"shouldTimeout");
	//[self readFrame];
	return 10;
}
 */

- (void)onSocket:(OFAsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	//OFLog(@"willDisconnect: %@", [err localizedDescription]);
}

#pragma mark -
#pragma mark Memory management
-(void) dealloc {
	//OFLog(@"StompClient::dealloc");

	
	[socket setDelegate:nil];
	[socket disconnectAfterReadingAndWriting];	
	
	[delegate release];
	delegate = nil;
		
	CRV_RELEASE_SAFELY(passcode);
	CRV_RELEASE_SAFELY(login);
	CRV_RELEASE_SAFELY(host);
	CRV_RELEASE_SAFELY(socket);
	CRV_RELEASE_SAFELY(sessionId);
	
	[super dealloc];
}

@end