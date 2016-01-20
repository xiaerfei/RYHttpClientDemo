//
//  SimplePingHelper.h
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimplePing.h"

@interface SimplePingHelper : NSObject <SimplePingDelegate>

+ (void)simpleHostpings:(NSArray *)hostPings completeBlock:(void (^)(NSArray *hostPingTimeArray))completeBlock;

@end
