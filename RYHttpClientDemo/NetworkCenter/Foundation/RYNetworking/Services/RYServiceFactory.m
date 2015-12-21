//
//  RYServiceFactory.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYServiceFactory.h"
#import "RYServiceKeys.h"


/*************************************************************************************************/
/*                                        Base services                                          */
/*************************************************************************************************/
// 通用的service 用户基础API
#import "GenerateRequestService.h"

/*************************************************************************************************/
/*                                       third services                                          */
/*************************************************************************************************/


@interface RYServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;

@end

@implementation RYServiceFactory

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RYServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RYServiceFactory alloc] init];
    });
    return sharedInstance;
}

- (RYService<RYServiceProtocal> *)serviceWithIdentifier:(NSString *)identifier
{
    if (self.serviceStorage[identifier] == nil) {
        self.serviceStorage[identifier] = [self newServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}


#pragma mark - private methods
- (RYService<RYServiceProtocal> *)newServiceWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:kGenerateRequestService]) {
        return [[GenerateRequestService alloc] init];
    }
    return nil;
}

#pragma mark - getters and setters
- (NSMutableDictionary *)serviceStorage
{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorage;
}


@end
