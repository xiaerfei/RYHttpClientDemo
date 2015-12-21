//
//  RYRequestGenerator.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/21.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "RYRequestGenerator.h"
#import "AFNetworking.h"
#import "RYBaseAPICmd.h"
#import "RYServiceFactory.h"

#import "NSURLRequest+RYNetworkingMethods.h"

@interface RYRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation RYRequestGenerator


- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    return request;
}
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    RYService *service = [[RYServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:requestParams error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    return request;
}

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"GET";
    request.requestParams = requestParams;
    return nil;
}
- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(NSDictionary *)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:NULL];
    request.requestParams = requestParams;
    return request;
}
#pragma mark - private methods
- (NSDictionary *)commRESTHeadersWithService:(RYService *)service
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionaryWithDictionary:service.cookis];
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    return headerDic;
}


#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
