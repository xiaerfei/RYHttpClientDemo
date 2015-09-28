//
//  RYNetApiProxy.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/9/28.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetCallBack)(id response);


@interface RYNetApiProxy : NSObject


+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail;

- (NSInteger)callNormalGETWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail;
- (NSInteger)callNormalPOSTWithParams:(NSDictionary *)params serviceIdentifier:(NSString *)servieIdentifier methodName:(NSString *)methodName success:(NetCallBack)success fail:(NetCallBack)fail;


- (void)cancelRequestWithRequestID:(NSNumber *)requestID;

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;


@end
