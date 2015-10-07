//
//  ViewController.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ViewController.h"
#import "ItemListAPICmd.h"
#import "RYAPIManager.h"

@interface ViewController ()<APICmdApiCallBackDelegate>

@property (nonatomic,strong) ItemListAPICmd *itemListAPICmd;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RYAPIManager manager] performCmd:self.itemListAPICmd];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)RYBaseAPICmd responseData:(NSDictionary *)responseData
{
    NSLog(@"%@",responseData);
}

- (void)apiCmdDidFailed:(RYBaseAPICmd *)RYBaseAPICmd error:(NSError *)error errorType:(RYBaseAPICmdErrorType)errorType
{
    
}

#pragma mark - getters

- (ItemListAPICmd *)itemListAPICmd
{
    if (!_itemListAPICmd) {
        _itemListAPICmd = [[ItemListAPICmd alloc] init];
        _itemListAPICmd.path = @"appforum/cheyouhome/?deviceid=000000000000000";
        _itemListAPICmd.delegate = self;
    }
    return _itemListAPICmd;
}


@end
