//
//  SimplePingHelper.m
//  PingTester
//
//  Created by Chris Hulbert on 18/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimplePingHelper.h"
#import "RYNetworkingConfiguration.h"

#define kHourSecond 86400


typedef void(^SimpleCompleteBlock)(NSString *host,NSTimeInterval pingTime);

@interface SimplePingHelper()

@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, strong) NSNumber   *recordedRequestId;
@property (nonatomic, assign) NSTimeInterval   begin;
@property (nonatomic, assign) NSTimeInterval   pingTime;
@property (nonatomic, copy) SimpleCompleteBlock simpleCompleteBlock;


- (id)initWithAddress:(NSString*)address;
- (void)go;

@end

@implementation SimplePingHelper

#pragma mark - Run it

// Pings the address, and calls the selector when done. Selector must take a NSnumber which is a bool for success
+ (void)simpleHostpings:(NSArray *)hostPings completeBlock:(void (^)(NSArray *hostPingTimeArray))completeBlock {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
#ifdef DEBUGLOG
    [userDefaults removeObjectForKey:kConnectionIPAddressKey];
#endif
    
    NSDictionary *hostHistory = [userDefaults objectForKey:kConnectionIPAddressKey];
    NSTimeInterval time = [hostHistory[@"time"] doubleValue];
    if (time != 0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval value = now - time;
        if (value < kHourSecond) {
            return;
        }
    }
    
    NSMutableArray *simpleArray   = [[NSMutableArray alloc] init];
    __block NSMutableArray *pingTimeArray = [[NSMutableArray alloc] init];
    __block NSInteger hostCount = hostPings.count;

    for (NSString *host in hostPings) {
        NSTimeInterval begin = CACurrentMediaTime();
        SimplePingHelper *help = [[SimplePingHelper alloc] initWithAddress:host];
        help.begin = begin;
        [help setSimpleCompleteBlock:^(NSString *host,NSTimeInterval pingTime){
            [pingTimeArray addObject:@{host:@(pingTime)}];
            if (pingTimeArray.count == hostCount) {
                [pingTimeArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                    NSTimeInterval pingTime1 = [obj1.allValues.lastObject doubleValue];
                    NSTimeInterval pingTime2 = [obj2.allValues.lastObject doubleValue];
                    if (pingTime1 > pingTime2) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    if (pingTime1 < pingTime2) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                completeBlock(pingTimeArray);
            }
        }];
        [help go];
        [simpleArray addObject:help];
    }
}

#pragma mark - Init/dealloc

- (void)dealloc {
	self.simplePing = nil;
}

- (id)initWithAddress:(NSString*)address {
	if (self = [self init]) {
		self.simplePing = [SimplePing simplePingWithHostName:address];
		self.simplePing.delegate = self;
	}
	return self;
}

#pragma mark - Go

- (void)go {
	[self.simplePing start];
	[self performSelector:@selector(endTime) withObject:nil afterDelay:1]; // This timeout is what retains the ping helper
}

#pragma mark - Finishing and timing out

// Called on success or failure to clean up
- (void)killPing {
	[self.simplePing stop];
    self.simplePing = nil;
}

- (void)failPing:(NSString*)reason {
    self.pingTime = 5;
    self.simpleCompleteBlock(self.simplePing.hostName,self.pingTime);
	[self killPing];
}

// Called 1s after ping start, to check if it timed out
- (void)endTime {
	if (self.simplePing) { // If it hasn't already been killed, then it's timed out
		[self failPing:@"timeout"];
	}
}

#pragma mark - Pinger delegate

// When the pinger starts, send the ping immediately
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
	[self.simplePing sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    self.pingTime = 5;
    self.simpleCompleteBlock(self.simplePing.hostName,self.pingTime);
    [self killPing];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
    self.pingTime = 5;
    self.simpleCompleteBlock(self.simplePing.hostName,self.pingTime);
    [self killPing];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    NSTimeInterval end = CACurrentMediaTime();
    self.pingTime = end - self.begin;
//    NSLog(@"host = %@  %8.8fms   \n", pinger.hostName,(end - self.begin)*1000);
    self.simpleCompleteBlock(self.simplePing.hostName,self.pingTime);
    [self killPing];
}

@end
