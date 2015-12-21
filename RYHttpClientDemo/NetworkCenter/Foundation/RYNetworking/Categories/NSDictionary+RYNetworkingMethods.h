//
//  NSDictionary+RYNetworkingMethods.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RYNetworkingMethods)
- (NSString *)RY_urlParamsString;
/** 字典变json */
- (NSString *)RY_jsonString;

/** 转义参数 */
- (NSArray *)RY_transformedUrlParamsArray;
@end
