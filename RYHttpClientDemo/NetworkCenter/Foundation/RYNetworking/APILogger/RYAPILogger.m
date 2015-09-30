//
//  RYAPILogger.m
//  FinaCustomer
//
//  Created by xiaerfei on 15/7/23.
//  Copyright (c) 2015年 rongyu. All rights reserved.
//

#import "RYAPILogger.h"

@implementation RYAPILogger

+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams responseParams:(id)responseParams httpMethod:(NSString *)httpMethod requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName
{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"URL:\t\t\t%@\n",[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [logString appendFormat:@"Method:\t\t%@\n", httpMethod];
    [logString appendFormat:@"requestId:\t\t%@\n",requestId];
    [logString appendFormat:@"apiName:\t\t%@\n",apiName];
    [logString appendFormat:@"description:\t%@\n",apiCmdDescription];
    [logString appendFormat:@"requestParams:\t%@\n",requestParams];
    [logString appendFormat:@"responseParams:\n%@", responseParams];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);

}


+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod error:(NSError *)error requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName
{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"URL:\t\t\t%@\n",url];
    [logString appendFormat:@"Method:\t\t%@\n", httpMethod];
    [logString appendFormat:@"requestId:\t\t%@\n",requestId];
    [logString appendFormat:@"apiName:\t\t%@\n",apiName];
    [logString appendFormat:@"description:\t%@\n",apiCmdDescription];
    [logString appendFormat:@"requestParams:\t%@\n",requestParams];
    [logString appendFormat:@"Error Domain:\t\t\t\t\t%@\n", error.domain];
    [logString appendFormat:@"Error Domain Code:\t\t\t\t%ld\n", (long)error.code];
    [logString appendFormat:@"Error Localized Description:\t\t%@\n", error.localizedDescription];
    [logString appendFormat:@"Error Localized Failure Reason:\t\t%@\n", error.localizedFailureReason];
    [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
}


@end
