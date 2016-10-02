//
//  KRNBluetoothMessages.h
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 02.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KRNBluetoothMessages : NSObject

+ (NSData *)connectionMessage;  //message which central sends to peripheral to notify that it has been connected
    
+ (BOOL)checkIfConnectionMessage:(NSData *)message; //return YES if this message is connectionMessage, otherwise - NO

@end
