//
//  RYAPILogger.h
//  FinaCustomer
//
//  Created by xiaerfei on 15/7/23.
//  Copyright (c) 2015年 rongyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RYService;

@interface RYAPILogger : NSObject

+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams responseParams:(id)responseParams httpMethod:(NSString *)httpMethod requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName;
+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod error:(NSError *)error requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName;
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;
+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(RYService *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;

@end
