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

@interface RYAPIManager ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

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
- (NSInteger)performCmd:(RYBaseAPICmd *)RYBaseAPICmd
{
    NSInteger requestId = 0;
    if (RYBaseAPICmd) {
        NSString *urlString = [RYBaseAPICmd absouteUrlString];
        
        if ([self isReachable]) {
            switch (RYBaseAPICmd.child.requestType) {
                case RYBaseAPICmdRequestTypeGet:
                    requestId = [self callGETWithParams:RYBaseAPICmd.reformParams urlString:urlString RYBaseAPICmd:RYBaseAPICmd];
                    
                    break;
                case RYBaseAPICmdRequestTypePost:
                    requestId = [self callPOSTWithParams:RYBaseAPICmd.reformParams urlString:urlString RYBaseAPICmd:RYBaseAPICmd];
                    break;
                default:
                    break;
            }
            [RYBaseAPICmd apiRequestId:requestId];
        } else {
            if ([RYBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:errorType:)]) {
                [RYBaseAPICmd.delegate apiCmdDidFailed:RYBaseAPICmd error:nil errorType:RYBaseAPICmdErrorTypeNoNetWork];
            }
        }
    }
    return requestId;
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID
{
    AFHTTPRequestOperation *operation = self.dispatchTable[@(requestID)];
    [operation cancel];
    [self.dispatchTable removeObjectForKey:@(requestID)];
}

- (void)cancelAllRequest
{
    for (NSNumber *requestId in self.dispatchTable.allKeys) {
        [self cancelRequestWithRequestID:[requestId integerValue]];
    }
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:[requestId integerValue]];
    }
}

#pragma mark - APICall
- (NSInteger)callGETWithParams:(NSDictionary *)params urlString:(NSString *)urlString RYBaseAPICmd:(RYBaseAPICmd *)RYBaseAPICmd
{
    NSNumber *requestId = [self generateRequestId];
    
    __weak typeof(RYBaseAPICmd) weakRYBaseAPICmd = RYBaseAPICmd;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            // 请求已经完成，将requestId移除
            [self.dispatchTable removeObjectForKey:requestId];
        }
        if ([weakRYBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:responseData:)]) {
            [weakRYBaseAPICmd.delegate apiCmdDidSuccess:weakRYBaseAPICmd responseData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        if ([RYBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:errorType:)]) {
            [RYBaseAPICmd.delegate apiCmdDidFailed:RYBaseAPICmd error:nil errorType:RYBaseAPICmdErrorTypeDefault];
        }
    }];
    if (RYBaseAPICmd.cookie) {
        [(NSMutableURLRequest *)operation.request setAllHTTPHeaderFields:RYBaseAPICmd.cookie];
    }
    self.dispatchTable[requestId] = operation;
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params urlString:(NSString *)urlString RYBaseAPICmd:(RYBaseAPICmd *)RYBaseAPICmd
{
    NSNumber *requestId = [self generateRequestId];
    __weak typeof(RYBaseAPICmd) weakRYBaseAPICmd = RYBaseAPICmd;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            // 请求已经完成，将requestId移除
            [self.dispatchTable removeObjectForKey:requestId];
        }
        if ([weakRYBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:responseData:)]) {
            [weakRYBaseAPICmd.delegate apiCmdDidSuccess:weakRYBaseAPICmd responseData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        if ([RYBaseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:error:errorType:)]) {
            [RYBaseAPICmd.delegate apiCmdDidFailed:RYBaseAPICmd error:nil errorType:RYBaseAPICmdErrorTypeDefault];
        }
    }];
    if (RYBaseAPICmd.cookie) {
        [(NSMutableURLRequest *)operation.request setAllHTTPHeaderFields:RYBaseAPICmd.cookie];
    }
    self.dispatchTable[requestId] = operation;
    return [requestId integerValue];
}

#pragma mark - private methods
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
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

- (NSMutableDictionary *)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

@end
