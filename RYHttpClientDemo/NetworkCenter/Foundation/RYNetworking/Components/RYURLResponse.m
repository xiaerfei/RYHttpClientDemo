//
//  RYURLResponse.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYURLResponse.h"
#import "NSURLRequest+RYNetworkingMethods.h"

@interface RYURLResponse ()

@property (nonatomic, assign, readwrite) RYURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation RYURLResponse

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData status:(RYURLResponseStatus)status
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content       = responseData;
        self.status        = status;
        self.requestId     = [requestId integerValue];
        self.request       = request;
//        self.responseData  = responseData;
        self.requestParams = request.requestParams;
        self.isCache       = NO;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.status        = [self responseStatusWithError:error];
        self.requestId     = [requestId integerValue];
        self.request       = request;
//        self.responseData  = responseData;
        self.requestParams = request.requestParams;
        self.isCache       = NO;
        
        if (responseData) {
            self.content   = responseData;
        } else {
            self.content   = nil;
        }
    }
    return self;
}

#pragma mark - private methods
- (RYURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        RYURLResponseStatus result = RYURLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = RYURLResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return RYURLResponseStatusSuccess;
    }
}

@end
