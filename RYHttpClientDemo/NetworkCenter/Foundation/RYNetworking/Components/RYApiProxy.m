//
//  RYApiProxy.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYApiProxy.h"
#import "AFNetworking.h"
#import "RYRequestGenerator.h"
#import "RYURLResponse.h"
#import "RYAPILogger.h"
#import "RYNetworkingConfiguration.h"

@interface RYApiProxy ()

@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

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

- (NSInteger)callGETNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateNormalGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateNormalPOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}


- (NSInteger)callGETWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generateGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail
{
    NSMutableURLRequest *request = [[RYRequestGenerator sharedInstance] generatePOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSOperation *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}


#pragma mark - private methods

/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSMutableURLRequest *)request success:(RYCallback)success fail:(RYCallback)fail
{
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        [RYAPILogger logDebugInfoWithResponse:operation.response
                             resposeString:operation.responseString
                                   request:operation.request
                                     error:NULL];
        RYURLResponse *response = [[RYURLResponse alloc] initWithResponseString:operation.responseString requestId:requestId request:request responseData:responseObject status:RYURLResponseStatusSuccess];
        success?success(response):nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        [RYAPILogger logDebugInfoWithResponse:operation.response
                                resposeString:operation.responseString
                                      request:operation.request
                                        error:error];
        RYURLResponse *response = [[RYURLResponse alloc] initWithResponseString:operation.responseString requestId:requestId request:request responseData:operation.responseObject error:error];
        fail?fail(response):nil;
    }];
    
    self.dispatchTable[requestId] = httpRequestOperation;
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    return requestId;
}

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

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)operationManager
{
    if (_operationManager == nil) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        _operationManager.operationQueue.maxConcurrentOperationCount = 10;
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _operationManager.requestSerializer.timeoutInterval = kNetworkingTimeoutSeconds;
    }
    return _operationManager;
}

@end
