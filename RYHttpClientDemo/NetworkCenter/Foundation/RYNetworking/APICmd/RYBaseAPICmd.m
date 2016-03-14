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
#import "RYServiceKeys.h"
#import "RYApiProxy.h"
#import "Aspects.h"

@interface RYBaseAPICmd ()
@property (nonatomic, copy,   readwrite) NSString     *absouteUrlString;
@property (nonatomic, assign, readwrite) NSInteger    requestId;
@property (nonatomic, copy,   readwrite) NSDictionary *cookie;
@property (nonatomic, copy,   readwrite) NSString     *serviceIdentifier;
@property (nonatomic, assign, readwrite) BOOL         isLoading;
@end

@implementation RYBaseAPICmd

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(RYBaseAPICmdDelegate)]) {
            self.child = (id<RYBaseAPICmdDelegate>) self;
            if ([self.child respondsToSelector:@selector(isRequestHook)]) {
                if ([self.child isRequestHook]) {
                    [RYApiProxy aspect_hookSelector:NSSelectorFromString(@"callApiWithRequest:success:fail:") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, NSMutableURLRequest *request,id success,id fail) {
                        [self hookCallWithRequest:request];
                    } error:NULL];
                }
            }
        } else {
#ifdef DEBUGLOGGER
            NSAssert(0, @"子类必须要实现APIManager这个protocol。");
#endif
        }
    }
    return self;
}

#pragma mark - hook methods
- (void)hookCallWithRequest:(NSMutableURLRequest *)request
{
    if ([self.aspect respondsToSelector:@selector(apiCmd:request:)]) {
        [self.aspect apiCmd:self request:request];
    }
}

- (NSString *)absouteUrlString
{
    if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
        // 解析参数：URL 以及 上传的参数
        NSMutableString *methodName = [[NSMutableString alloc] initWithString:self.child.methodName];
        NSMutableDictionary *requestURLParam = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] init];
        
        NSDictionary *paramDict = [self.paramSource paramsForApi:self];
        NSArray *requestArray = paramDict[kReformParamArray];
        [paramDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            if ([key rangeOfString:@"||"].length) {
                NSRange range = [methodName rangeOfString:key];
                [methodName replaceCharactersInRange:range withString:value];
            } else if ([key rangeOfString:@":"].length) {
                NSMutableString *valueKey = [NSMutableString stringWithString:key];
                NSRange range = [valueKey rangeOfString:@":"];
                [valueKey replaceCharactersInRange:range withString:@""];
                requestParam[valueKey] = value;
            } else {
                requestURLParam[key] = value;
            }
        }];
        
        if (requestArray.count != 0) {
            self.reformParams = requestArray;
        } else {
            self.reformParams = requestParam;
        }
        
        NSString *methodNameURL = [NSString stringWithFormat:@"%@?%@",methodName,[requestURLParam RY_urlParamsString]];
        _absouteUrlString = [methodNameURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        _absouteUrlString = [self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return _absouteUrlString;
}

- (NSString *)serviceIdentifier
{
    if ([self.child respondsToSelector:@selector(serviceType)]) {
        _serviceIdentifier = [self.child serviceType];
    } else {
        _serviceIdentifier = kGenerateRequestService;
    }
    return _serviceIdentifier;
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
 *   @author xiaerfei, 15-08-25 14:08:05
 *
 *   开始请求数据
 */
- (void)loadData
{
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
