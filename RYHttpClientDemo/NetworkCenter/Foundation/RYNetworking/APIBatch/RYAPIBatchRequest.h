//
//  RYAPIBatchRequest.h
//  RongYu100
//
//  Created by xiaerfei on 16/5/4.
//  Copyright © 2016年 ___RongYu100___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RYBaseAPICmd;
@interface RYAPIBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSArray *requestArray;

- (id)initWithRequestArray:(NSArray *)requestArray;
- (void)requestUsingBlockSuccess:(void (^)(NSDictionary *responseData))successCompletionBlock
                   failed:(void (^)(NSError *error))failureCompletionBlock;

@end
