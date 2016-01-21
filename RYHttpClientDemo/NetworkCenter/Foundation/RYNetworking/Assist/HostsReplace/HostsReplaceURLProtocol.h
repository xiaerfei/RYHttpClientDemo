//
//  HostsReplaceURLProtocol.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 16/1/20.
//  Copyright (c) 2016年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HostsReplaceConfigurationDelegate <NSObject>

- (void)replaceHostName:(NSString *)hostName toIPAddress:(NSString *)IPAddress;

@end



@interface HostsReplaceURLProtocol : NSURLProtocol

+ (void)configureHostsWithBlock:(void (^)(id <HostsReplaceConfigurationDelegate> configuration))block;


@end
