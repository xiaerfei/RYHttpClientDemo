# RYHttpClient

##RYNetworking
###Version 2.0

本次版本更新的内容很多，主要由以下几点：

1. Request（RYRequestGenerator） 和 Response（RYURLResponse） 分离，加入中间层 RYApiProxy;
2. 增加service层，可配置API host 以及 key、cookies等等。GenerateRequestService为默认的service，根据需求可以增加其它的service;
3. 参数回调更改（兼容之前的回调方法） 实现协议“- (NSDictionary *)paramsForApi:(RYBaseAPICmd *)manager ” 可以统一回调参数，具体使用方法在RYBaseAPICmd中的APICmdParamSourceDelegate查看;