//
//  HostsReplaceURLProtocol.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 16/1/20.
//  Copyright (c) 2016年 RongYu100. All rights reserved.
//

#import "HostsReplaceURLProtocol.h"
#import "RYNetworkingConfiguration.h"


@interface HostsReplaceConfiguration : NSObject <HostsReplaceConfigurationDelegate>
@property (nonatomic, copy) NSMutableDictionary *iPAddressesHostName;
- (NSString *)IPAddressForHostName:(NSString *)hostName;
@end

@implementation HostsReplaceConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *hostHistory = [userDefaults objectForKey:kConnectionIPAddressKey];
        if (hostHistory.count != 0) {
            self.iPAddressesHostName[hostHistory[@"shost"]] = hostHistory[@"dhost"];
        }
    }
    return self;
}


- (NSString *)IPAddressForHostName:(NSString *)hostName
{
    return self.iPAddressesHostName[hostName];
}

#pragma mark - HostsReplaceConfigurationDelegate
- (void)replaceHostName:(NSString *)hostName toIPAddress:(NSString *)IPAddress
{
    if (hostName != nil && IPAddress != nil) {
        self.iPAddressesHostName[[hostName lowercaseString]] = IPAddress;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@{@"shost":hostName.lowercaseString,
                                 @"dhost":IPAddress,
                                 @"time":@(time)} forKey:kConnectionIPAddressKey];
        [userDefaults synchronize];
    }
}

#pragma mark - getter
- (NSMutableDictionary *)iPAddressesHostName
{
    if (_iPAddressesHostName == nil) {
        _iPAddressesHostName = [[NSMutableDictionary alloc] init];
    }
    return _iPAddressesHostName;
}

@end

@interface HostsReplaceURLProtocol ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection * connection;

@end


@implementation HostsReplaceURLProtocol

+ (HostsReplaceConfiguration *)sharedConfiguration {
    static HostsReplaceConfiguration * _sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[HostsReplaceConfiguration alloc] init];
    });
    
    return _sharedConfiguration;
}

+ (void)configureHostsWithBlock:(void (^)(id <HostsReplaceConfigurationDelegate> configuration))block {
    if (block) {
        block([self sharedConfiguration]);
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    /*
     防止无限循环，因为一个请求在被拦截处理过程中，也会发起一个请求，这样又会走到这里，如果不进行处理，就会造成无限循环
     */
    if ([NSURLProtocol propertyForKey:kConnectionProtocolKey inRequest:request]) {
        return NO;
    } else {
        return YES;
    }

    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    // 修改了请求的头部信息
    NSMutableURLRequest * mutableReq = [request mutableCopy];
    NSURLComponents *URLComponents = [NSURLComponents componentsWithString:[[mutableReq URL] absoluteString]];
    URLComponents.scheme = @"http";
    URLComponents.host = [[[self class] sharedConfiguration] IPAddressForHostName:URLComponents.host];
    mutableReq.URL = [URLComponents URL];
    return [mutableReq copy];
}

/**
 *  开始加载，在该方法中，加载一个请求
 */
- (void)startLoading {
    NSMutableURLRequest * request = [self.request mutableCopy];
    // 表示该请求已经被处理，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:kConnectionProtocolKey inRequest:request];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

/**
 *  取消请求
 */
- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
