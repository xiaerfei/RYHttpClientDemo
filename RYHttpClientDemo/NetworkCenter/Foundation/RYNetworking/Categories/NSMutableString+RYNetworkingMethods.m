//
//  NSMutableString+RYNetworkingMethods.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "NSMutableString+RYNetworkingMethods.h"
#import "NSObject+RYNetworkingMethods.h"

@implementation NSMutableString (RYNetworkingMethods)

- (void)appendURLRequest:(NSURLRequest *)request
{
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] RY_defaultValue:@"\t\t\t\tN/A"]];
}


@end
