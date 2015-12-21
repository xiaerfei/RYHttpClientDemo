//
//  NSURLRequest+RYNetworkingMethods.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "NSURLRequest+RYNetworkingMethods.h"
#import <objc/runtime.h>

static void *RYNetworkingRequestParams;

@implementation NSURLRequest (RYNetworkingMethods)

- (void)setRequestParams:(id)requestParams
{
    objc_setAssociatedObject(self, &RYNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (id)requestParams
{
    return objc_getAssociatedObject(self, &RYNetworkingRequestParams);
}

@end
