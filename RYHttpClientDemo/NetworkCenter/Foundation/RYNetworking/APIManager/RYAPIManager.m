//
//  RYAPIManager.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYAPIManager.h"
#import "RYBaseAPICmd.h"
#import "AFNetworking.h"
#import "RYAPILogger.h"
#import "RYApiProxy.h"
#import "RYURLResponse.h"
#import "RYServicePrivate.h"

#define RYCallAPI(REQUEST_METHOD, REQUEST_ID)                                                       \
{                                                                                       \
__weak __typeof(baseAPICmd) weakBaseAPICmd = baseAPICmd;                                          \
REQUEST_ID = [[RYApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:baseAPICmd.reformParams serviceIdentifier:baseAPICmd.serviceIdentifier url:urlString success:^(RYURLResponse *response) { \
__strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;\
[self successedOnCallingAPI:response baseAPICmd:strongBaseAPICmd];                                          \
} fail:^(RYURLResponse *response) {                                                \
__strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;\
[self failedOnCallingAPI:response withErrorType:RYBaseAPICmdErrorTypeDefault baseAPICmd:strongBaseAPICmd];  \
}];                                                                                 \
[self.requestIdList addObject:@(REQUEST_ID)];                                          \
}


@interface RYAPIManager ()

@property (nonatomic, strong) NSMutableArray *requestIdList;
@end

@implementation RYAPIManager
#pragma mark - life cycle
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static RYAPIManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[RYAPIManager alloc] init];
    });
    return manager;
}
#pragma mark - public metods
- (NSInteger)performCmd:(RYBaseAPICmd *)baseAPICmd
{
    NSInteger requestId = 0;
    if (baseAPICmd) {
        NSString *urlString = [baseAPICmd absouteUrlString];
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmdStartLoadData:)]) {
            [baseAPICmd.interceptor apiCmdStartLoadData:baseAPICmd];
        }
        if ([self isReachable]) {
            switch (baseAPICmd.child.requestType) {
                case RYBaseAPICmdRequestTypeGet:
                    RYCallAPI(GET, requestId);
                    break;
                case RYBaseAPICmdRequestTypePost:
                    RYCallAPI(POST, requestId);
                    break;
                case RYBaseAPICmdRequestTypeGetNormal:
                    RYCallAPI(GETNormal, requestId);
                    break;
                case RYBaseAPICmdRequestTypePostNormal:
                    RYCallAPI(POSTNormal, requestId);
                    break;
                default:
                    break;
            }
        } else {
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformFailWithResponse:nil];
            }
            if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:errorType:)]) {
                [baseAPICmd.delegate apiCmdDidFailed:baseAPICmd errorType:RYBaseAPICmdErrorTypeNoNetWork];
            }
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformFailWithResponse:nil];
            }
        }
    }
    return requestId;
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[RYApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)cancelAllRequest
{
    [[RYApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}


- (BOOL)isLoadingWithRequestID:(NSInteger)requestID
{
    for (NSNumber *number in self.requestIdList) {
        if (number.integerValue == requestID) {
            return YES;
        }
    }
    return NO;
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

#pragma mark - private methods

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
