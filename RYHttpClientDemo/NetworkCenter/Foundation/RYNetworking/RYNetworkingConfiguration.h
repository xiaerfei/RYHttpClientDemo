//
//  RYNetworkingConfiguration.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/12/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#ifndef RYHttpClientDemo_RYNetworkingConfiguration_h
#define RYHttpClientDemo_RYNetworkingConfiguration_h

typedef NS_ENUM(NSUInteger, RYURLResponseStatus)
{
    RYURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的RYAPIBaseCmd来决定。
    RYURLResponseStatusErrorTimeout,
    RYURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

static NSTimeInterval kNetworkingTimeoutSeconds = 15.0f;

static NSString *const kReformParamArray        = @"ReformParamArray";

#define DEBUGLOG

#define kConnectionProtocolKey  @"ConnectionProtocolKey"
#define kConnectionIPAddressKey @"ConnectionIPAddressKey"


#endif
