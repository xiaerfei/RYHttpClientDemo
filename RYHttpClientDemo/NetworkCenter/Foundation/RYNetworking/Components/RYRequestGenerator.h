//
//  RYRequestGenerator.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYRequestGenerator : NSObject

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

@end
