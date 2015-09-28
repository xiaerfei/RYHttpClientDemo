//
//  RYNetApiProxy.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/9/28.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYNetApiProxy.h"
#import "AFNetworking.h"

@interface RYNetApiProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation RYNetApiProxy

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYNetApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYNetApiProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail
{
    return 0;
}
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail
{
    return 0;
}

- (NSInteger)callNormalGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail
{
    return 0;
}
- (NSInteger)callNormalPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail
{
    return 0;
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


- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(NetCallBack)success fail:(NetCallBack)fail
{
    NSNumber *requestId = [self generateRequestId];
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            // 请求已经完成，将requestId移除
            [self.dispatchTable removeObjectForKey:requestId];
        }
        
        success?success(responseObject):nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }

        fail?fail(error):nil;
    }];
    self.dispatchTable[requestId] = httpRequestOperation;
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    return requestId;
}

- (void)setCookieWithRequest:(NSMutableURLRequest *)request
{
    NSArray *arcCookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"]];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in arcCookies){
        [cookieStorage setCookie: cookie];
    }
    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookies];
    
    [request setAllHTTPHeaderFields:sheaders];
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

- (AFHTTPRequestOperationManager *)operationManager
{
    if (!_operationManager) {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _operationManager;
}

- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}


@end
