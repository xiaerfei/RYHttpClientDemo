//
//  RYRequestGenerator.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYRequestGenerator : NSObject

+ (instancetype)sharedInstance;

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

@end
