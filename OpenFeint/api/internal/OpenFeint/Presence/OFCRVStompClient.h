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


#import <Foundation/Foundation.h>
#import "OFAsyncSocket.h"

@class OFCRVStompClient;

typedef enum {
	CRVStompAckModeAuto,
	CRVStompAckModeClient
} CRVStompAckMode;

@protocol OFCRVStompClientDelegate <NSObject>
- (void)stompClient:(OFCRVStompClient *)stompService messageReceived:(NSString *)body withHeader:(NSDictionary *)messageHeader;

@optional
- (void)stompClientDidDisconnect:(OFCRVStompClient *)stompService;
- (void)stompClientDidConnect:(OFCRVStompClient *)stompService;
- (void)serverDidSendReceipt:(OFCRVStompClient *)stompService withReceiptId:(NSString *)receiptId;
- (void)serverDidSendError:(OFCRVStompClient *)stompService withErrorMessage:(NSString *)description detailedErrorMessage:(NSString *) theMessage;
@end

@interface OFCRVStompClient : NSObject {
	@private
	id<OFCRVStompClientDelegate> delegate;
	OFAsyncSocket *socket;
	NSString *host;
	NSUInteger port;
	NSString *login;
	NSString *passcode;
	NSString *sessionId;
	BOOL doAutoconnect;
}

@property (nonatomic, assign) id<OFCRVStompClientDelegate> delegate;

- (id)initWithHost:(NSString *)theHost 
			  port:(NSUInteger)thePort 
			 login:(NSString *)theLogin
		  passcode:(NSString *)thePasscode 
		  delegate:(id<OFCRVStompClientDelegate>)theDelegate;

- (id)initWithHost:(NSString *)theHost 
			  port:(NSUInteger)thePort 
			 login:(NSString *)theLogin
		  passcode:(NSString *)thePasscode 
		  delegate:(id<OFCRVStompClientDelegate>)theDelegate
	   autoconnect:(BOOL) autoconnect;

- (void)connect;
- (void)sendMessage:(NSString *)theMessage toDestination:(NSString *)destination;

- (void)pipeHttpRequest:(NSString *)theRequest withMethod:(NSString *)theMethod andContentType:(NSString *)theContentType andUrl:(NSString *)theUrl andBody:(NSString *)theBody;

- (void)subscribeToDestination:(NSString *)destination;
- (void)subscribeToDestination:(NSString *)destination withAck:(CRVStompAckMode) ackMode;
- (void)subscribeToDestination:(NSString *)destination withHeader:(NSDictionary *) header;
- (void)unsubscribeFromDestination:(NSString *)destination;
- (void)begin:(NSString *)transactionId;
- (void)commit:(NSString *)transactionId;
- (void)abort:(NSString *)transactionId;
- (void)ack:(NSString *)messageId;
- (void)disconnect;
- (void)retrySocket;

@end