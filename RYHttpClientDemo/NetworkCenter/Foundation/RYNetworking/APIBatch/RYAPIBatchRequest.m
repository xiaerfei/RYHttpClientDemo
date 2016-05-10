//
//  RYAPIBatchRequest.m
//  RongYu100
//
//  Created by xiaerfei on 16/5/4.
//  Copyright © 2016年 ___RongYu100___. All rights reserved.
//

#import "RYAPIBatchRequest.h"
#import "RYBaseAPICmd.h"

@interface RYAPIBatchRequest ()<APICmdApiCallBackDelegate>

@property (nonatomic, copy) NSMutableDictionary *responseDataDictionary;

@property (nonatomic) NSInteger finishedCount;

@property (nonatomic, copy) void (^requestCompletionBlock)(NSArray **baseRequestArray);

@property (nonatomic, copy) void (^successCompletionBlock)(NSDictionary *responseData);

@property (nonatomic, copy) void (^failureCompletionBlock)(NSError *error);

@end

@implementation RYAPIBatchRequest


- (id)initWithRequestArray:(NSArray *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
    }
    return self;
}

- (void)requestUsingBlockSuccess:(void (^)(NSDictionary *responseData))successCompletionBlock
                   failed:(void (^)(NSError *error))failureCompletionBlock
{
    _responseDataDictionary = [[NSMutableDictionary alloc] init];
    self.successCompletionBlock = successCompletionBlock;
    self.failureCompletionBlock = failureCompletionBlock;
    for (RYBaseAPICmd *base in _requestArray) {
        base.delegate = self;
        [base loadData];
    }
}
#pragma mark APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd responseData:(id)responseData
{
    self.finishedCount ++;
    for (RYBaseAPICmd *base in _requestArray) {
        if (base == baseAPICmd) {
            NSInteger index = [_requestArray indexOfObject:base];
            self.responseDataDictionary[@(index)] = responseData;
        }
    }
    
    if (self.finishedCount == _requestArray.count) {
        
        self.successCompletionBlock(self.responseDataDictionary);
        [self configStopRequest];
    }
}
- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd error:(NSError *)error
{
    self.failureCompletionBlock(error);
    [self configStopRequest];
}

#pragma mark - 配置请求

- (void)configStopRequest
{
    self.requestCompletionBlock = nil;
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.finishedCount = 0;
}



@end
