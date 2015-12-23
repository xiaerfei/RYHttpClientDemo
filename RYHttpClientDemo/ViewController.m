//
//  ViewController.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ViewController.h"
#import "ItemListAPICmd.h"


@interface ViewController ()<APICmdApiCallBackDelegate,APICmdParamSourceDelegate,APICmdParamSourceDelegate>

@property (nonatomic,strong) ItemListAPICmd *itemListAPICmd;

@end

@implementation ViewController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //开始请求数据
    [self.itemListAPICmd loadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd response:(RYURLResponse *)response
{
    
}
- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd errorType:(RYBaseAPICmdErrorType)errorType
{
    
}
#pragma mark APICmdParamSourceDelegate
- (NSDictionary *)paramsForApi:(RYBaseAPICmd *)manager
{
    if (self.itemListAPICmd == manager) {
        return @{@"city":@"shanghai"};
    }
    return nil;
}

#pragma mark - getters

- (ItemListAPICmd *)itemListAPICmd
{
    if (!_itemListAPICmd) {
        _itemListAPICmd = [[ItemListAPICmd alloc] init];
        _itemListAPICmd.delegate = self;
        _itemListAPICmd.paramSource = self;
    }
    return _itemListAPICmd;
}


@end
