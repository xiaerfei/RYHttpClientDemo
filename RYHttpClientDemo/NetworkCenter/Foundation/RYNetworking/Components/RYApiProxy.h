//
//  RYApiProxy.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYURLResponse.h"

typedef void(^RYCallback)(RYURLResponse *response);

@interface RYApiProxy : NSObject


+ (instancetype)sharedInstance;

- (NSInteger)callGETNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail;
- (NSInteger)callPOSTNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail;

- (NSInteger)callGETWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail;
- (NSInteger)callPOSTWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(RYCallback)success fail:(RYCallback)fail;


- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
