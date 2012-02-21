//
//  MPOAuthURLRequest.m
//  MPOAuthConnection
//
//  Created by Karl Adam on 08.12.05.
//  Copyright 2008 matrixPointer. All rights reserved.
//

#import "MPOAuthURLRequest.h"
#import "MPURLRequestParameter.h"
#import "MPOAuthSignatureParameter.h"
#import "NSString+URLEscapingAdditions.h"
#import "MPDebug.h"
#import "OFSettings.h"
#import "OpenFeint.h"

static const NSString* gBoundaryString = @"sadf8as9fha3fpaef8ah";

static void addParameter(NSMutableArray* params, NSString* name, NSString* value)
{
	[params addObject:[[[MPURLRequestParameter alloc] initWithName:name	andValue:value] autorelease]];
}

@interface MPOAuthURLRequest ()
@property (nonatomic, readwrite, retain) NSURLRequest *urlRequest;
@end

@implementation MPOAuthURLRequest

- (id)initWithURL:(NSURL *)inURL andParameters:(NSArray *)inParameters {
	self = [super init];
	if (self != nil) {
		self.url = inURL;
		_parameters = inParameters ? [inParameters mutableCopy] : [[NSMutableArray alloc] initWithCapacity:10];
				
		addParameter(_parameters, @"info_client_application_version",	OFSettings::Instance()->getClientBundleVersion());
		addParameter(_parameters, @"info_client_application_bundle_id",	OFSettings::Instance()->getClientBundleIdentifier());
		addParameter(_parameters, @"info_client_openfeint_version",		[NSString stringWithFormat:@"%d", [OpenFeint versionNumber]]);
		addParameter(_parameters, @"info_client_device_locale",			OFSettings::Instance()->getClientLocale());
		
		self.HTTPMethod = @"GET";
	}
	return self;
}

- (oneway void)dealloc {
	self.url = nil;
	self.HTTPMethod = nil;
	self.urlRequest = nil;
	self.parameters = nil;
	
	[super dealloc];
}

@synthesize url = _url;
@synthesize HTTPMethod = _httpMethod;
@synthesize urlRequest = _urlRequest;
@synthesize parameters = _parameters;

#pragma mark -

- (NSString*)getBoundaryMarkerStart
{
	return [NSString stringWithFormat:@"--%@\r\n", gBoundaryString];
}

- (NSString*)getBoundaryMarkerEnd
{
	return [NSString stringWithFormat:@"--%@--", gBoundaryString];
}

- (NSData*)createMultipartFormContent:(NSArray*)parameters
{
	
	const NSData* boundaryMarker = [[self getBoundaryMarkerStart] dataUsingEncoding:NSUTF8StringEncoding];
	const NSString* headerSpacer = @"\r\n";
	
	NSMutableData* multipartData = [[NSMutableData new] autorelease];
	for (MPURLRequestParameter* param in parameters)
	{
		[multipartData appendData:boundaryMarker];
		if (param.value)
		{
			const NSString* headerContentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", param.name];
			[multipartData appendData:[headerContentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
			[multipartData appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
			[multipartData appendData:[param.value dataUsingEncoding:NSUTF8StringEncoding]];	
			[multipartData appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
		}
		else if (param.blob)
		{
			const NSString* headerContentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.%@\"\r\n", param.name, param.name, param.blobDataType];
			const NSString* headerContentType = [NSString stringWithFormat:@"Content-Type: %@\r\n", param.blobDataType];
			const NSString* headerContentEncoding =  [NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n"];	
			
			[multipartData appendData:[headerContentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
			[multipartData appendData:[headerContentType dataUsingEncoding:NSUTF8StringEncoding]];
			[multipartData appendData:[headerContentEncoding dataUsingEncoding:NSUTF8StringEncoding]];
			[multipartData appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];
			[multipartData appendBytes:param.blob.bytes length:param.blob.length];
			[multipartData appendData:[headerSpacer dataUsingEncoding:NSUTF8StringEncoding]];	
			
		}
		else
		{
			OFAssert(false, @"Parameter is neither ASCII nor binary");
		}
	}
	
	const NSString* boundaryEndMarker = [self getBoundaryMarkerEnd];;
	[multipartData appendData:[boundaryEndMarker dataUsingEncoding:NSUTF8StringEncoding]];
	//NSLog([multipartData description]);
	return multipartData;
}

- (NSURLRequest  *)urlRequestSignedWithSecret:(NSString *)inSecret usingMethod:(NSString *)inScheme withExtraParameters:(NSArray*)extraParameters
{
	NSMutableArray* requestParameters = [NSMutableArray arrayWithArray:self.parameters];
	[requestParameters addObjectsFromArray:extraParameters];
	
	// We need sorted parameters to generate the oauth signature but we can't send the parameters over the wire sorted as it will break any arrays of hashes
	NSMutableArray* sortedParametersForSignature = [NSMutableArray new];
	bool sendAsMultiPartForm = false;
	NSMutableArray* blobSigs = [[NSMutableArray new] autorelease];
	for (MPURLRequestParameter* curParam in requestParameters)
	{
		if (curParam.blob == nil)
		{
			[sortedParametersForSignature addObject:curParam];
		}
		else
		{
			sendAsMultiPartForm = true;
			NSString* sig = [MPOAuthSignatureParameter HMAC_SHA1SignatureForText:[NSString stringWithFormat:@"%d", [curParam.blob length]] usingSecret:inSecret];
			NSString* key = [NSString stringWithFormat:@"%@_signature", curParam.name];
			MPURLRequestParameter* sigParameter = [[[MPURLRequestParameter alloc] initWithName:key andValue:sig] autorelease];
			[blobSigs addObject:sigParameter];
		}
	}
	
	[sortedParametersForSignature addObjectsFromArray:blobSigs];
	[requestParameters addObjectsFromArray:blobSigs];
	[sortedParametersForSignature sortUsingSelector:@selector(compare:)];

	
	NSMutableString *sortedParameterForSignatureString = [[NSMutableString alloc] initWithString:[MPURLRequestParameter parameterStringForParameters:sortedParametersForSignature]];
	MPOAuthSignatureParameter *signatureParameter = [[MPOAuthSignatureParameter alloc] initWithText:sortedParameterForSignatureString andSecret:inSecret forRequest:self usingMethod:inScheme];
	[requestParameters addObject:signatureParameter];
	
	NSMutableURLRequest *aRequest = [[NSMutableURLRequest alloc] init];
	[aRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	
	NSMutableString *parameterString = nil;
	if (!sendAsMultiPartForm)
	{		
		parameterString = [[NSMutableString alloc] initWithString:[MPURLRequestParameter parameterStringForParameters:requestParameters]];
	}
	
	[aRequest setHTTPMethod:self.HTTPMethod];
	
	if (([[self HTTPMethod] isEqualToString:@"GET"] || [[self HTTPMethod] isEqualToString:@"PUT"] || [[self HTTPMethod] isEqualToString:@"DELETE"]) && [requestParameters count]) 
	{
		OFAssert(!sendAsMultiPartForm, @"MultiPartForm isn't allowed with GET");
		NSString *urlString = [NSString stringWithFormat:@"%@?%@", [self.url absoluteString], parameterString];
		MPLog( @"urlString - %@", urlString);
		
		[aRequest setURL:[NSURL URLWithString:urlString]];
	} 
	else if ([[self HTTPMethod] isEqualToString:@"POST"]) 
	{
		[aRequest setURL:self.url];
		NSData *postData = nil;
		if (sendAsMultiPartForm)
		{
			postData = [self createMultipartFormContent:requestParameters];
			[aRequest setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
			[aRequest addValue:[NSString stringWithFormat:@"boundary=%@", gBoundaryString] forHTTPHeaderField:@"Content-type"];
		}
		else
		{
			postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
			[aRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			MPLog(@"postDataString - %@", parameterString);
		}
		MPLog(@"urlString - %@", self.url);
		[aRequest setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
		[aRequest setHTTPBody:postData];
		
		static bool sDebugPrint = false;
		if(sDebugPrint)
		{
			OFLog(@"\n------------------------------------------------------------------------------------------\n");
			OFLog([[[NSString alloc] initWithData:aRequest.HTTPBody encoding:NSUTF8StringEncoding] autorelease]);
			OFLog(@"\n------------------------------------------------------------------------------------------\n");
		}
		
	}
	
	[sortedParametersForSignature release];
	[sortedParameterForSignatureString release];

	[parameterString release];
	[signatureParameter release];		
	
	self.urlRequest = aRequest;
	[aRequest release];
		
	return aRequest;
}

- (NSURLRequest  *)urlRequestSignedWithSecret:(NSString *)inSecret usingMethod:(NSString *)inScheme
{
	return [self urlRequestSignedWithSecret:inSecret usingMethod:inScheme withExtraParameters:nil];
}

#pragma mark -

- (void)addParameters:(NSArray *)inParameters {
	[self.parameters addObjectsFromArray:inParameters];
}

@end
