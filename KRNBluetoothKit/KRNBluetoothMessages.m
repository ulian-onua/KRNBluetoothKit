//
//  KRNBluetoothMessages.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 02.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "KRNBluetoothMessages.h"

static NSString* const kKRNConnectionMessage = @"5CONN5";

@implementation KRNBluetoothMessages
+ (NSData *)connectionMessage {
    return [kKRNConnectionMessage dataUsingEncoding:NSUTF8StringEncoding];
}
    
+ (BOOL)checkIfConnectionMessage:(NSData *)message {
    NSString *str = [[NSString alloc]initWithData:message encoding:NSUTF8StringEncoding];
    if (str) {
        if ([str isEqualToString:kKRNConnectionMessage]) {
            return YES;
        }
    }
    return NO;
}

@end
