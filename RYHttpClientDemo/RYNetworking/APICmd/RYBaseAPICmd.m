//
//  RYBaseAPICmd.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYBaseAPICmd.h"

@interface RYBaseAPICmd ()
@property (nonatomic,strong,readwrite) NSString *absouteUrlString;
@property (nonatomic, assign,readwrite) NSInteger requestId;
@end

@implementation RYBaseAPICmd

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(RYBaseAPICmdDelegate)]) {
            self.child = (id<RYBaseAPICmdDelegate>) self;
        } else {
            NSLog(@"子类必须要实现APIManager这个protocol。");
        }
    }
    return self;
}

- (NSString *)absouteUrlString
{
    
    return [NSString stringWithFormat:@"%@%@",self.host,self.path];
}

- (NSString *)host
{
    return @"http://api.ycapp.yiche.com/";
}

- (void)apiRequestId:(NSInteger)requestId
{
    self.requestId = requestId;
}



- (NSDictionary *)cookie
{
    NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]];

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in arcCookies){
        [cookieStorage setCookie: cookie];
    }
    
    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookies];
    return sheaders;
}


@end
