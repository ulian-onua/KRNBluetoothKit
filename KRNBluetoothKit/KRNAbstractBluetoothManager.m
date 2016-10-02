//
//  KRNAbstractBluetoothManager.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "KRNAbstractBluetoothManager.h"

@implementation KRNAbstractBluetoothManager

- (instancetype) init {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must call initWithServiceUUID:writeCharacteristicUUID:andReadCharacteristicUUID method instead of this one"];
    return nil;
}

- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID {
    self = [super init];
    [self checkForAbstractClass];
    if (self) {
        _serviceUUIDString = [serviceUUID copy];
        _writeCharacteristicUUIDString = [writeCharUUID copy];
        _readCharacteristicUUIDString = [readCharUUID copy];
        _connectionState = KRNConnectionStateDisconnected;
    }
    return self;
}



-(void) sendPacket:(NSData *)packet {
    [self checkForAbstractClass];
}


- (void)checkForAbstractClass {
    if ([self isMemberOfClass:[KRNAbstractBluetoothManager class]]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    }
}
    
#pragma mark - Convert to Bluetooth Manager State -
- (KRNBluetoothManagerState)convertToBluetoothManagerState:(CBManagerState)state {
    switch (state) {
        case CBManagerStateUnknown:
        return KRNBluetoothManagerStateUnknown;
        break;
        case CBManagerStatePoweredOff:
        return KRNBluetoothManagerStatePoweredOff;
        break;
        case CBManagerStatePoweredOn:
        return KRNBluetoothManagerStatePoweredOn;
        break;
        case CBManagerStateUnsupported:
        return KRNBluetoothManagerStateUnsupported;
        break;
        case CBManagerStateUnauthorized:
        return KRNBluetoothManagerStateUnauthorized;
        break;
        default:
        return KRNBluetoothManagerStateUnknown;
    }
}



@end
