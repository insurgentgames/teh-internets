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

#import "OFHttpRequest.h"
#import "OFHttpRequestObserver.h"
#import "OpenFeintSettings.h"
#import "OFLog.h"

@implementation OFHttpRequest

@synthesize url = mURLConnection;
@synthesize data = mReceivedData;
@dynamic contentType;
@dynamic contentDisposition;
@dynamic urlPath;
@dynamic httpMethod;

- (NSString*)urlPath
{
	return mRequestPath;
}

- (NSString*)httpMethod
{
	return mRequestMethod;
}

- (NSString*)contentType
{	
	return [[mHttpResponse allHeaderFields] objectForKey:@"Content-Type"];
}

- (NSString*)contentDisposition
{
	return [[mHttpResponse allHeaderFields] objectForKey:@"Content-Disposition"];
}

+ (id)httpRequestWithBase:(NSString*)url withObserver:(OFHttpRequestObserver*)observer
{
	return [[[OFHttpRequest alloc] initWithBaseUrl:url withObserver:observer withCookies:false] autorelease];
}

+ (id)httpRequestWithBase:(NSString*)url withObserver:(OFHttpRequestObserver*)observer withCookies:(bool)cookies
{
	return [[[OFHttpRequest alloc] initWithBaseUrl:url withObserver:observer withCookies:cookies] autorelease];
}

- (void)startRequestWithPath:(NSString*)path withMethod:(NSString*)httpMethod withBody:(NSData*)httpBody withEmail:(NSString*)email withPassword:(NSString*)password multiPartBoundary:(NSString*)multiPartBoundary
{
	// OFLog(@"Starting Request: %@:%@ (%d data bytes) [%p]", httpMethod, path, [httpBody length], self);
	OFAssert(mIsRequestInProgress == false, "Attempting to issue a new HTTP Request while an existing one is outstanding");
	
	mIsRequestInProgress = true;
	
	if(httpMethod == HttpMethodPut)
	{
		path = [path stringByAppendingString:@"?_method=put"];
		httpMethod = HttpMethodPost;
	}
	else if(httpMethod == HttpMethodDelete)
	{
		path = [path stringByAppendingString:@"?_method=delete"];
		httpMethod = HttpMethodPost;
	}
		
	NSURL* requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", mBaseUrl, path]];	
	NSMutableURLRequest* theRequest = [NSMutableURLRequest 
		requestWithURL:requestUrl
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:10.0f]; 
	[theRequest setHTTPMethod:httpMethod];
	[theRequest setHTTPBody:httpBody];
	
	mRequestMethod = [httpMethod retain];
	mRequestPath = [path retain];
	
	if(multiPartBoundary != nil)
	{
		[theRequest setValue:@"multipart/form-data"  forHTTPHeaderField:@"Content-type"];
		[theRequest addValue:[NSString stringWithFormat:@"boundary=%@", multiPartBoundary] forHTTPHeaderField:@"Content-type"];
	}
	
	if (mHandleCookies)
	{
		// TODO - which value is correct here? YES = default
		//[theRequest setHTTPShouldHandleCookies:NO];
		NSArray* cookies = [self getCookies];
		if ([cookies count] > 0)
		{
#ifdef _DEBUG
			OFLogDebug(Network, "# of available Cookies: %d", [cookies count]);
			for (NSHTTPCookie *cookie in cookies)
			{
				OFLogDebug(Network, "Name: %@ : Value: %@, Expires: %@", cookie.name, cookie.value, cookie.expiresDate); 
			}
#endif
			NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
			[theRequest setAllHTTPHeaderFields:headers];
		}
	}
	
	[self _releaseConnectionResources];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	mPassword.reset(password);
	mEmail.reset(email);

	mURLConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if(mURLConnection)
	{
		mReceivedData = [[NSMutableData data] retain];
	}
	else if(mObserver)
	{
		mIsRequestInProgress = false;
		mObserver->onFailedDownloading(self);
	}
}

- (void)startRequestWithPath:(NSString*)path withMethod:(NSString*)httpMethod withBody:(NSData*)httpBody 
{	
	[self startRequestWithPath:path withMethod:httpMethod withBody:httpBody withEmail:nil withPassword:nil multiPartBoundary:nil];
}

- (id)initWithBaseUrl:(NSString*)url withObserver:(OFHttpRequestObserver*)observer
{
	return [self initWithBaseUrl:url withObserver:observer withCookies:false];
}

- (void)changeObserver:(OFHttpRequestObserver*)newObserver
{
	mObserver = newObserver;
}

- (id)initWithBaseUrl:(NSString*)url withObserver:(OFHttpRequestObserver*)observer withCookies:(bool)cookies
{
	self = [super init];
	if(self)
	{
		mIsRequestInProgress = false;
		mObserver = observer;
		mBaseUrl = [url retain];
		mHandleCookies = cookies;
	}
	return self;
}

+ (bool)hasCookies:urlBase
{
	return [OFHttpRequest countCookies:urlBase] > 0;
}

+ (int)countCookies:urlBase
{
	return [[OFHttpRequest getCookies:urlBase] count];
}

+ (NSArray*)getCookies:urlBase
{
	return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlBase]];
}

+ (void)addCookies:(NSArray*)cookies withBase:urlBase
{
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:[NSURL URLWithString:urlBase] mainDocumentURL:nil];
}

- (bool)hasCookies
{
	return [OFHttpRequest hasCookies:mBaseUrl];
}

- (int)countCookies
{
	return [OFHttpRequest countCookies:mBaseUrl];
}

- (NSArray*)getCookies
{
	return [OFHttpRequest getCookies:mBaseUrl];
}

- (void)addCookies:(NSArray*)cookies
{
	[OFHttpRequest addCookies:cookies withBase:mBaseUrl];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// OFLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorKey]);
	mIsRequestInProgress = false;
	
	if(mObserver)
	{
		mObserver->onFailedDownloading(self);
	}
	
	if(!mIsRequestInProgress)
	{
		[self _releaseConnectionResources];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	// OFLog(@"Did receive authentication challenge");
	if([challenge previousFailureCount] > 0 || !(mPassword.get() && mEmail.get()))
	{
		mIsRequestInProgress = false;
		[connection cancel];
		if(mObserver)
		{
			mObserver->onFailedDownloading(self);
		}
	}
	else
	{
		NSURLCredential* credential = [NSURLCredential credentialWithUser:mEmail.get() password:mPassword.get() persistence:NSURLCredentialPersistenceNone];
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// OFLog(@"Did finish loading %p", self);
	// OFLog(@"Data: %@", [NSString stringWithCString: (char const*)[mReceivedData bytes] length: [mReceivedData length]]);
	mIsRequestInProgress = false;
	
	if(mObserver)
	{
		if([mHttpResponse statusCode] < 200 || [mHttpResponse statusCode] > 299)
		{
			mObserver->onFailedDownloading(self);
		}
		else
		{
			mObserver->onFinishedDownloading(self);
		}
	}
	
	if(!mIsRequestInProgress)
	{
		[self _releaseConnectionResources];
	}
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
	NSURLRequest *newRequest=request;
	if(redirectResponse)
	{
		OFLogWarning(Network, "Redirect not allowed: %@ %@", redirectResponse, newRequest);
		newRequest=nil;
	}
	return newRequest;
}

- (void)_releaseConnectionResources
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	OFSafeRelease(mRequestPath);
	OFSafeRelease(mRequestMethod);
	
	OFSafeRelease(mReceivedData);
	OFSafeRelease(mURLConnection);
	OFSafeRelease(mHttpResponse);
	
	mEmail.reset(nil);
	mPassword.reset(nil);
}

- (void)dealloc
{
	// OFLog(@"Dealloc OFHttpRequest for %p", self);
	
	[mBaseUrl release];
	[self _releaseConnectionResources];
	[super dealloc];
}

- (NSString*)sanitizeString:(NSString*)stringToSanitize
{
	stringToSanitize = [stringToSanitize stringByReplacingOccurrencesOfString:@"<" withString:@" "];
	stringToSanitize = [stringToSanitize stringByReplacingOccurrencesOfString:@">" withString:@" "];
	stringToSanitize = [stringToSanitize stringByReplacingOccurrencesOfString:@"[" withString:@" "];
	stringToSanitize = [stringToSanitize stringByReplacingOccurrencesOfString:@"]" withString:@" "];
	stringToSanitize = [stringToSanitize stringByReplacingOccurrencesOfString:@"&" withString:@" "];
	return stringToSanitize;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this method is called when the server has determined that it
	// has enough information to create the NSURLResponse
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	// OFLog(@"Did receive response (%d)", [httpResponse statusCode]);

	if (mHandleCookies)
	{
		// Store Authentication Cookie
		//OFLogDebug(Network, "Response Headers: \n%@", [response allHeaderFields]);
		NSArray * all = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:[NSURL URLWithString:mBaseUrl]];
		if ([all count] > 0)
		{
			OFLogDebug(Network, "# of valid Cookies: %d", [all count]);
			[self addCookies:all];
#ifdef _DEBUG
			for (NSHTTPCookie *cookie in all)
			{
				OFLogDebug(Network, "Name: %@ : Value: %@, Expires: %@", cookie.name, cookie.value, cookie.expiresDate); 
			}
#endif
		}
	}

	[mHttpResponse release];
	mHttpResponse = [httpResponse retain];
		
	// it can be called multiple times, for example in the case of a
	// redirect, so each time we reset the data.
	// receivedData is declared as a method instance elsewhere
	[mReceivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// OFLog(@"Did receive data");
	// append the new data to the receivedData
	// receivedData is declared as a method instance elsewhere
	[mReceivedData appendData:data];
}

- (void)cancelImmediately
{
	// OFLog(@"Cancelling request %@", mRequestPath);

	mObserver = NULL;

	if(mIsRequestInProgress)
	{
		[mURLConnection cancel];
		mIsRequestInProgress = false;
		[self _releaseConnectionResources];
	}
}
	 
@end
