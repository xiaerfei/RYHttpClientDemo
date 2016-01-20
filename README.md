#RYNetworking
###Version 2.0

本次版本更新的内容很多，主要由以下几点：

1. Request（RYRequestGenerator） 和 Response（RYURLResponse） 分离，加入中间层 RYApiProxy;
2. 增加service层，可配置API host 以及 key、cookies等等。GenerateRequestService为默认的service，根据需求可以增加其它的service;
3. 参数回调更改（兼容之前的回调方法） 实现协议“- (NSDictionary *)paramsForApi:(RYBaseAPICmd *)manager ” 可以统一回调参数，具体使用方法在RYBaseAPICmd中的APICmdParamSourceDelegate查看;

###Version 2.0.1
1. 添加[AOP](https://github.com/steipete/Aspects.git)，主要拦截发起请求的 <font color=red size=5>NSMutableURLRequest</font> 以便能够对待特殊的请求，比如header加入key；

###Version 2.0.2
1. 添加SimplePing。
<br/>
功能：在应用启动的时候获得本地列表中所有IP的ping值，然后将请求URL中的HOST修改为我们找到的最快的IP，一般是每天第一次启动的时候读一次Ping值，然后更新到本地。
