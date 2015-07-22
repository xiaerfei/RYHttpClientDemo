//
//  RYBaseAPICmd.h
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RYBaseAPICmd;
typedef NS_ENUM (NSUInteger, RYBaseAPICmdRequestType){
    RYBaseAPICmdRequestTypeGet,
    RYBaseAPICmdRequestTypePost,
};

typedef NS_ENUM (NSUInteger, RYBaseAPICmdErrorType){
    RYBaseAPICmdErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    RYBaseAPICmdErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    RYBaseAPICmdErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    RYBaseAPICmdErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    RYBaseAPICmdErrorTypeTimeout,       //请求超时。设置的是20秒超时。
    RYBaseAPICmdErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

/*************************************************************************************************/
/*                                         RTAPIManager                                          */
/*************************************************************************************************/
/*
 RYBaseAPICmd的派生类必须符合这些protocal
 */
@protocol RYBaseAPICmdDelegate <NSObject>
@required
- (RYBaseAPICmdRequestType)requestType;
@end

/*************************************************************************************************/
/*                               APIManagerApiCallBackDelegate                                   */
/*************************************************************************************************/
//api回调 返回数据，由controller或者持有者实现
@protocol APICmdApiCallBackDelegate <NSObject>
@required
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)RYBaseAPICmd responseData:(NSDictionary *)responseData;
- (void)apiCmdDidFailed:(RYBaseAPICmd *)RYBaseAPICmd error:(NSError *)error errorType:(RYBaseAPICmdErrorType)errorType;
@end




@interface RYBaseAPICmd : NSObject

@property (nonatomic, strong) NSObject<RYBaseAPICmdDelegate> *child;
@property (nonatomic, weak) id<APICmdApiCallBackDelegate> delegate;

@property (nonatomic, copy) NSDictionary *reformParams;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign,readonly) NSInteger requestId;
@property (nonatomic,strong,readonly) NSString *absouteUrlString;

- (void)apiRequestId:(NSInteger)requestId;
// 如果子类没有cookie，请重载
- (NSDictionary *)cookie;

// 如果子类变化，请重载
- (NSString *)host;



@end
