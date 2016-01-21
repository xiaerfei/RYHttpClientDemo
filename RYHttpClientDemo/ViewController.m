//
//  ViewController.m
//  RYHttpClientDemo
//
//  Created by xiaerfei on 15/7/22.
//  Copyright (c) 2015年 RongYu100. All rights reserved.
//

#import "ViewController.h"
#import "ItemListAPICmd.h"


@interface ViewController ()<APICmdApiCallBackDelegate,APICmdParamSourceDelegate,APICmdParamSourceDelegate,APICmdAspect>

@property (nonatomic,strong) ItemListAPICmd *itemListAPICmd;
@property (weak, nonatomic) IBOutlet UITextField *cityPinyin;
@property (weak, nonatomic) IBOutlet UITextView  *responseResult;

- (IBAction)beginRequestAction:(id)sender;


@end

@implementation ViewController

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - APICmdApiCallBackDelegate
- (void)apiCmdDidSuccess:(RYBaseAPICmd *)baseAPICmd response:(RYURLResponse *)response
{
    self.responseResult.text = response.contentString;
}
- (void)apiCmdDidFailed:(RYBaseAPICmd *)baseAPICmd errorType:(RYBaseAPICmdErrorType)errorType
{
    
}
#pragma mark APICmdParamSourceDelegate
- (NSDictionary *)paramsForApi:(RYBaseAPICmd *)apiCmd
{
    if (self.itemListAPICmd == apiCmd) {
        return @{@"city":self.cityPinyin.text};
    }
    return nil;
}
#pragma mark APICmdAspect
- (void)apiCmd:(RYBaseAPICmd *)apiCmd request:(NSMutableURLRequest *)request
{
    
}

#pragma mark - event responses
- (IBAction)beginRequestAction:(id)sender {
    if (self.cityPinyin.text.length != 0) {
        //开始请求数据
        [self.itemListAPICmd loadData];
    }
}
 
#pragma mark - getters

- (ItemListAPICmd *)itemListAPICmd
{
    if (!_itemListAPICmd) {
        _itemListAPICmd = [[ItemListAPICmd alloc] init];
        _itemListAPICmd.delegate    = self;
        _itemListAPICmd.paramSource = self;
        _itemListAPICmd.aspect      = self;
    }
    return _itemListAPICmd;
}



@end
