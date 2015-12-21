//
//  RYApiProxy.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYApiProxy.h"

@implementation RYApiProxy

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYApiProxy alloc] init];
    });
    return sharedInstance;
}

- (NSInteger)callGETNormalWithParams:(NSDictionary *)params url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    return 0;
}

- (NSInteger)callPOSTNormalWithParams:(NSDictionary *)params url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    return 0;
}


- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    return 0;
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    return 0;
}

@end
