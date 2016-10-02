//
//  KRNCentralManager.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "KRNCentralManager.h"


@interface KRNCentralManager() <CBCentralManagerDelegate, CBPeripheralDelegate>

{
    dispatch_queue_t _bluetoothManagerQueue;  //queue for bluetooth
    CBCharacteristic* _remoteWriteCharacteristic;
}
@property (assign, nonatomic) KRNConnectionState connectionState;
@end



@implementation KRNCentralManager
//@dynamic connectionState;

@synthesize connectionState = _connectionState;


- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID {
    self = [super initWithServiceUUID:serviceUUID writeCharacteristicUUID:writeCharUUID andReadCharacteristicUUID:readCharUUID];
    if (self) {
        _bluetoothManagerQueue = dispatch_queue_create("com.KRNCentralManager.queue", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:_bluetoothManagerQueue options:nil];
        
    }
    return self;
}

- (void)scanAndConnectToPeripheral {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceUUIDString]] options:nil];
     //   [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}
- (void)sendPacket:(NSData *)packet {
    if (self.connectedPeripheral) {
        if (_remoteWriteCharacteristic) {
            [self.connectedPeripheral writeValue:packet forCharacteristic:_remoteWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
    }
}

- (KRNBluetoothManagerState) state {
    return [self getBluetoothManagerState:self.centralManager.state];
}

#pragma mark - Helpers -

- (KRNBluetoothManagerState)getBluetoothManagerState:(CBManagerState)state {
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

#pragma mark - CBCentralManagerDelegate -

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.updateStateCompletion) {
        self.updateStateCompletion(self.state);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (KRNBluetoothManagerDebugMode) {
        NSLog(@"Discover peripheral = %@", peripheral);
    }
    
    _connectedPeripheral = peripheral;
    [self.centralManager connectPeripheral:_connectedPeripheral options:nil];
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    if (KRNBluetoothManagerDebugMode) {
        NSLog(@"Connect peripheral with advertisiment data = %@", peripheral);
    }
    
    self.connectionState = KRNConnectionStateConnected;
    _connectedPeripheral = peripheral;
    _connectedPeripheral.delegate = self;
    [_connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:self.serviceUUIDString]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    if (!error) {  // if disconnect not by user - try reconnect
        if (KRNBluetoothManagerDebugMode) {
            NSLog(@"Disconnect peripheral. Trying reconnect");
        }
        self.connectionState = KRNConnectionStateDisconnected;
        [self.centralManager connectPeripheral:_connectedPeripheral options:nil];
    } else {
       
        if (self.disconnectCompletion) {
            self.disconnectCompletion();
        }
    }
    
}

#pragma mark - CBPeripheralDelegate -

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (!error) {
        [peripheral discoverCharacteristics:nil forService:peripheral.services.firstObject];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (!error) {
        if ([service.UUID.UUIDString isEqualToString:self.serviceUUIDString]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:self.readCharacteristicUUIDString]) {
                    [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([characteristic.UUID.UUIDString isEqualToString:self.writeCharacteristicUUIDString]) {
                    _remoteWriteCharacteristic = characteristic;
                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if (!error) {
        if ([characteristic.UUID.UUIDString isEqualToString:self.readCharacteristicUUIDString]) {
            if (characteristic.value) {
                if (self.getMessageCompletion) {
                    self.getMessageCompletion(characteristic.value);
                }
            }
        }
    }
}


@end

