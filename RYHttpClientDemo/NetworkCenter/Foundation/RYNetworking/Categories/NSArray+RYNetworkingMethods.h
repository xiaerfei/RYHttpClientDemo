//
//  NSArray+RYNetworkingMethods.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (RYNetworkingMethods)
- (NSString *)RY_paramsString;
/** 数组变json */
- (NSString *)RY_jsonString;
@end
