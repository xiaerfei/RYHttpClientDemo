//
//  RYURLResponse.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYNetworkingConfiguration.h"

@interface RYURLResponse : NSObject

@property (nonatomic, assign, readonly) RYURLResponseStatus status;
@property (nonatomic, copy,   readonly) NSString *contentString;
@property (nonatomic, copy,   readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy,   readonly) NSURLRequest *request;
@property (nonatomic, copy,   readonly) NSData *responseData;
@property (nonatomic, copy)             id requestParams;
@property (nonatomic, assign, readonly) BOOL isCache;


- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData status:(RYURLResponseStatus)status;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData error:(NSError *)error;

@end
