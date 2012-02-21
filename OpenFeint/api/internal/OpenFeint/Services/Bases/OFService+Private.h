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

#import "OFService.h"
#import "OFActionRequestType.h"
#import "OFNotificationData.h"

class OFHttpNestedQueryStringWriter;
@class OFNotificationData;

@interface OFService ( Private )

- (OFRequestHandle*)_performAction:(NSString*)action
		withParameters:(OFHttpNestedQueryStringWriter*)params
		withHttpMethod:(NSString*)httpMethod
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)notice
		requiringAuthentication:(bool)requiringAuthentication;
		
- (OFRequestHandle*)getAction:(NSString*)action
		withParameters:(OFHttpNestedQueryStringWriter*)params
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)notice;

- (OFRequestHandle*)postAction:(NSString*)action
		withParameters:(OFHttpNestedQueryStringWriter*)params
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)notice;

- (OFRequestHandle*)putAction:(NSString*)action
		withParameters:(OFHttpNestedQueryStringWriter*)params
		withSuccess:(const OFDelegate&)onSuccess 
		withFailure:(const OFDelegate&)onFailure
		withRequestType:(OFActionRequestType)requestType
		withNotice:(OFNotificationData*)notice;

- (OFRequestHandle*)deleteAction:(NSString*)action
	  withParameters:(OFHttpNestedQueryStringWriter*)params
		 withSuccess:(const OFDelegate&)onSuccess 
		 withFailure:(const OFDelegate&)onFailure
	 withRequestType:(OFActionRequestType)requestType
		  withNotice:(OFNotificationData*)notice;
				
@end
