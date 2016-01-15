//
//  ItemListAPICmd.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ItemListAPICmd.h"


@implementation ItemListAPICmd

- (RYBaseAPICmdRequestType)requestType
{
    return RYBaseAPICmdRequestTypeGet;
}

- (NSString *)methodName
{
    return @"heweather/weather/free";
}

- (BOOL)isRequestHook
{
    return YES;
}

@end
