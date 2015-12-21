//
//  RYServiceFactory.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RYService.h"

@interface RYServiceFactory : NSObject

+ (instancetype)sharedInstance;
- (RYService<RYServiceProtocal> *)serviceWithIdentifier:(NSString *)identifier;

@end
