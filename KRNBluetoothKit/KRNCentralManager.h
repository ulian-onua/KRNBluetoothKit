//
//  KRNCentralManager.h
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "KRNAbstractBluetoothManager.h"

typedef void(^KRNReadRSSIClosure)(NSInteger RSSIValue, NSError* error);

@interface KRNCentralManager : KRNAbstractBluetoothManager

@property (strong, nonatomic, readonly) CBCentralManager* centralManager;
@property (strong, nonatomic, readonly) CBPeripheral* connectedPeripheral;

- (void)scanAndConnectToPeripheral:(KRNConnectionStateClosure)completion; //scan and connect to peripheral
- (void)stopScan; //stop scan

- (BOOL)readPeripheralsRSSI:(KRNReadRSSIClosure)completion;  //return NO if device is not connected

- (void)disconnectFromPeripheral:(KRNConnectionStateClosure)completion; //completion called if disconnected


@end



