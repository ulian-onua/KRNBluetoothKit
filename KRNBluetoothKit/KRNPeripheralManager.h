//
//  KRNPeripheralManager.h
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//


#import "KRNAbstractBluetoothManager.h"

@interface KRNPeripheralManager : KRNAbstractBluetoothManager

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (assign, nonatomic, readonly) BOOL advertising; //current status of advertising

- (void)startAdvertising:(KRNConnectionStateClosure)completion;
- (void)stopAdvertising;

@end



