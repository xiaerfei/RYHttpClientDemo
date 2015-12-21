//
//  RYBaseAPICmd.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYBaseAPICmd.h"
#import "RYAPIManager.h"
#import "NSDictionary+RYNetworkingMethods.h"

@interface RYBaseAPICmd ()
@property (nonatomic, copy,readwrite) NSString *absouteUrlString;
@property (nonatomic, assign,readwrite) NSInteger requestId;
@property (nonatomic, copy,readwrite) NSDictionary *cookie;
@property (nonatomic, assign,readwrite) BOOL isLoading;
@end

@implementation RYBaseAPICmd

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(RYBaseAPICmdDelegate)]) {
            self.child = (id<RYBaseAPICmdDelegate>) self;
        } else {
#ifdef DEBUGLOGGER
            NSAssert(0, @"子类必须要实现APIManager这个protocol。");
#endif
        }
    }
    return self;
}

- (NSString *)absouteUrlString
{
    if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
        NSString *url = nil;
        // 解析参数：URL 以及 上传的参数
        NSMutableString *urlStr = [[NSMutableString alloc] initWithString:self.child.methodName];
        NSMutableDictionary *requestURLParam = [[NSMutableDictionary alloc] init];
        
        NSDictionary *paramDict = [self.paramSource paramsForApi:self];
        if (self.child.requestType == RYBaseAPICmdRequestTypeGet) {
            [paramDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                // 判断是否包含 ||
                if ([key rangeOfString:@"||"].length) {
                    NSRange range = [urlStr rangeOfString:key];
                    [urlStr replaceCharactersInRange:range withString:value];
                } else {
                    requestURLParam[key] = value;
                }
            }];
            url = [NSString stringWithFormat:@"%@%@?%@",self.host,urlStr,[requestURLParam RY_urlParamsString]];
            NSLog(@"url %@",url);
        } else if (self.child.requestType == RYBaseAPICmdRequestTypePost) {
            NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] init];
            NSArray *requestArray = paramDict[kReformParamArray];
            [paramDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                if ([key rangeOfString:@"||"].length) {
                    NSRange range = [urlStr rangeOfString:key];
                    [urlStr replaceCharactersInRange:range withString:value];
                } else if ([key rangeOfString:@":"].length) {
                    NSMutableString *valueKey = [NSMutableString stringWithString:key];
                    NSRange range = [valueKey rangeOfString:@":"];
                    [valueKey replaceCharactersInRange:range withString:@""];
                    requestParam[valueKey] = value;
                } else {
                    requestURLParam[key] = value;
                }
            }];
            
            url = [NSString stringWithFormat:@"%@%@?%@",self.host,urlStr,[requestURLParam RY_urlParamsString]];
            NSLog(@"url %@ \nrequestParam %@",url,requestParam);
            if (requestArray.count != 0) {
                self.reformParams = requestArray;
            } else {
                self.reformParams = requestParam;
            }
        }
        _absouteUrlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return _absouteUrlString;
}

- (NSString *)host
{
    if ([self.child respondsToSelector:@selector(apiHost)]) {
        return [self.child apiHost];
    }
    return @"";
}
/**
 *   @author xiaerfei, 15-09-08 11:09:14
 *
 *   isLoading
 *
 *   @return
 */
- (BOOL)isLoading
{
    _isLoading = [[RYAPIManager manager] isLoadingWithRequestID:self.requestId];
    return _isLoading;
}
/**
 *   @author xiaerfei, 15-09-08 11:09:59
 *
 *   取消当前的请求
 */
- (void)cancelRequest
{
    [[RYAPIManager manager] cancelRequestWithRequestID:self.requestId];
}

/**
 *   @author xiaerfei, 15-08-25 14:08:51
 *
 *   加载cookie
 *
 *   @return
 */
- (NSDictionary *)cookie
{
    if ([self.child respondsToSelector:@selector(apiCookie)]) {
        return [self.child apiCookie];
    }
    
    NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]];

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in arcCookies){
        [cookieStorage setCookie: cookie];
    }
    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookies];
    _cookie = sheaders;
    return _cookie;
}
/**
 *   @author xiaerfei, 15-08-25 14:08:05
 *
 *   开始请求数据
 */
- (void)loadData
{
    if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
        [self.paramSource paramsForApi:self];
    }
    self.requestId = [[RYAPIManager manager] performCmd:self];
}

- (void)dealloc
{
    if ([self.child respondsToSelector:@selector(isCancelled)]) {
        if ([self.child isCacelRequest]) {
            [self cancelRequest];
        }
    } else {
        [self cancelRequest];
    }
}
@end
