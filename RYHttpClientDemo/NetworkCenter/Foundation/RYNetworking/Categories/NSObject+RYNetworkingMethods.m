//
//  NSObject+RYNetworkingMethods.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "NSObject+RYNetworkingMethods.h"

@implementation NSObject (RYNetworkingMethods)

- (id)RY_defaultValue:(id)defaultData
{
    if (![defaultData isKindOfClass:[self class]]) {
        return defaultData;
    }
    
    if ([self RY_isEmptyObject]) {
        return defaultData;
    }
    
    return self;
}

- (BOOL)RY_isEmptyObject
{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;
}

@end
