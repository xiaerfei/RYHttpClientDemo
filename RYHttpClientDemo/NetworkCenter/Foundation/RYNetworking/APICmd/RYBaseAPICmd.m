//
//  RYBaseAPICmd.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYBaseAPICmd.h"
#import "AFNetworking.h"
#import "RYAPILogger.h"
#import "RYApiProxy.h"
#import "RYURLResponse.h"
#import "RYServicePrivate.h"
#import "NSDictionary+RYNetworkingMethods.h"
#import "RYServiceKeys.h"
#import "Aspects.h"

#define RYCallAPI(REQUEST_METHOD, REQUEST_ID)                                                       \
{                                                                                       \
__weak __typeof(self) weakSelf = self;                                          \
REQUEST_ID = [[RYApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:self.reformParams serviceIdentifier:self.serviceIdentifier url:urlString success:^(RYURLResponse *response) { \
__strong __typeof(weakSelf) strongSelf = weakSelf;\
[self successedOnCallingAPI:response baseAPICmd:strongSelf];                                          \
} fail:^(RYURLResponse *response) {                                                \
__strong __typeof(weakSelf) strongSelf = weakSelf;\
[self failedOnCallingAPI:response withErrorType:RYBaseAPICmdErrorTypeDefault baseAPICmd:strongSelf];  \
}];                                                                                 \
[self.requestIdList addObject:@(REQUEST_ID)];                                          \
}

@interface RYBaseAPICmd ()
@property (nonatomic, copy,   readwrite) NSString     *absouteUrlString;
@property (nonatomic, assign, readwrite) NSInteger    requestId;
@property (nonatomic, copy,   readwrite) NSDictionary *cookie;
@property (nonatomic, copy,   readwrite) NSString     *serviceIdentifier;
@property (nonatomic, assign, readwrite) BOOL         isLoading;
@property (nonatomic, strong) NSMutableArray *requestIdList;

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

#pragma mark - public methods
/**
 *   @author xiaerfei, 15-09-08 11:09:14
 *
 *   isLoading
 *
 *   @return
 */
- (BOOL)isLoading
{
    _isLoading = [self isLoadingWithRequestID:self.requestId];
    return _isLoading;
}
/**
 *   @author xiaerfei, 15-09-08 11:09:59
 *
 *   取消当前的请求
 */
- (void)cancelRequest
{
    [self cancelRequestWithRequestID:self.requestId];
}
/**
 *   @author xiaerfei, 15-08-25 14:08:05
 *
 *   开始请求数据
 */
- (void)loadData
{
//    self.requestId = [[RYAPIManager manager] performCmd:self];
    
    NSString *urlString = [self absouteUrlString];
    
    if ([self.validator respondsToSelector:@selector(apiCmd:isCorrectWithParamsData:)]) {
        BOOL isValidator = [self.validator apiCmd:self isCorrectWithParamsData:self.reformParams];
        if (isValidator == NO) {
            return;
        }
    }
    
    if ([self.interceptor respondsToSelector:@selector(apiCmdStartLoadData:)]) {
        [self.interceptor apiCmdStartLoadData:self];
    }
    
    if ([self isReachable]) {
        switch (self.child.requestType) {
            case RYBaseAPICmdRequestTypeGet:
                RYCallAPI(GET, self.requestId);
                break;
            case RYBaseAPICmdRequestTypePost:
                RYCallAPI(POST, self.requestId);
                break;
            case RYBaseAPICmdRequestTypeGetNormal:
                RYCallAPI(GETNormal, self.requestId);
                break;
            case RYBaseAPICmdRequestTypePostNormal:
                RYCallAPI(POSTNormal, self.requestId);
                break;
            default:
                break;
        }
    } else {
        if ([self.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
            [self.interceptor apiCmd:self beforePerformFailWithResponse:nil];
        }
        if ([self.delegate respondsToSelector:@selector(apiCmdDidFailed:errorType:)]) {
            [self.delegate apiCmdDidFailed:self errorType:RYBaseAPICmdErrorTypeNoNetWork];
        }
        if ([self.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
            [self.interceptor apiCmd:self afterPerformFailWithResponse:nil];
        }
    }
}
#pragma mark - APICall

- (void)successedOnCallingAPI:(RYURLResponse *)response baseAPICmd:(RYBaseAPICmd *)baseAPICmd
{
    [self removeRequestIdWithRequestID:response.requestId];
    if ([baseAPICmd.child respondsToSelector:@selector(jsonValidator)]) {
        id json = [baseAPICmd.child jsonValidator];
        if ([RYServicePrivate checkJson:response.content withValidator:json] == NO) {
            [self failedOnCallingAPI:response withErrorType:RYAPIManagerErrorTypeNoContent baseAPICmd:baseAPICmd];
            return;
        }
    }
    if ([self.validator respondsToSelector:@selector(apiCmd:isCorrectWithCallBackData:)]) {
        BOOL isValidator = [self.validator apiCmd:self isCorrectWithCallBackData:response.content];
        if (isValidator == NO) {
            return;
        }
    }
    if (response.content) {
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformSuccessWithResponse:)]) {
            [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformSuccessWithResponse:response];
        }
        if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:response:)]) {
            [baseAPICmd.delegate apiCmdDidSuccess:baseAPICmd response:response];
        }
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformSuccessWithResponse:)]) {
            [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformSuccessWithResponse:response];
        }
    } else {
        [self failedOnCallingAPI:response withErrorType:RYAPIManagerErrorTypeNoContent baseAPICmd:baseAPICmd];
    }
}

- (void)failedOnCallingAPI:(RYURLResponse *)response withErrorType:(RYBaseAPICmdErrorType)errorType baseAPICmd:(RYBaseAPICmd *)baseAPICmd
{
    [self removeRequestIdWithRequestID:response.requestId];
    if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
        [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformFailWithResponse:response];
    }
    if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:errorType:)]) {
        [baseAPICmd.delegate apiCmdDidFailed:baseAPICmd errorType:errorType];
    }
    if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
        [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformFailWithResponse:response];
    }
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



#pragma mark - private methods

- (BOOL)isLoadingWithRequestID:(NSInteger)requestID
{
    for (NSNumber *number in self.requestIdList) {
        if (number.integerValue == requestID) {
            return YES;
        }
    }
    return NO;
}

- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
            break;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[RYApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - getters
- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

@end
