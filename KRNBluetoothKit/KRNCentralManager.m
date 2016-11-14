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
    BOOL _scanAndConnect; // should scan and connect if delegate message was called
    KRNConnectionStateClosure _connectionCompletion;
    KRNConnectionStateClosure _disconnectByUserCompletion;
    KRNReadRSSIClosure _readRSSIClosure;

}
@property (assign, nonatomic) KRNConnectionState connectionState;
@end



@implementation KRNCentralManager

@synthesize connectionState = _connectionState;


- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID {
    self = [super initWithServiceUUID:serviceUUID writeCharacteristicUUID:writeCharUUID andReadCharacteristicUUID:readCharUUID];
    if (self) {
        _bluetoothManagerQueue = dispatch_queue_create("com.KRNCentralManager.queue", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:_bluetoothManagerQueue options:nil];
        
    }
    return self;
}

- (void)scanAndConnectToPeripheral:(KRNConnectionStateClosure)completion {
    _connectionCompletion = completion;
    if (self.state == KRNBluetoothManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceUUIDString]] options:nil];
    } else {
        _scanAndConnect = YES; //connect when state will be on
    }
}
    
- (void)stopScan {
    //iOS 9+
    if ([self.centralManager respondsToSelector:@selector(isScanning)]) {
        if ([self.centralManager isScanning]) {
            [self.centralManager stopScan];
        }
    } else { //iOS 8
        [self.centralManager stopScan];
    }
}

- (BOOL)readPeripheralsRSSI:(void(^)(NSInteger RSSIValue, NSError* error))completion {
    if (self.connectionState == KRNConnectionStateConnected) {
        _readRSSIClosure = completion;
        [self.connectedPeripheral readRSSI];
        return YES;
    } else {
        return NO;
    }
}

- (void)disconnectFromPeripheral:(KRNConnectionStateClosure)completion {
    if (self.connectedPeripheral) {
        _disconnectByUserCompletion = completion;
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    } else {
        if (completion) {
            completion(self.connectionState);
        }
    }
}
    
- (void)sendPacket:(NSData *)packet {
    if (self.connectedPeripheral) {
        if (_remoteWriteCharacteristic) {
            [self.connectedPeripheral writeValue:packet forCharacteristic:_remoteWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
    }
}

- (KRNBluetoothManagerState) state {
    return [self convertToBluetoothManagerState:self.centralManager.state];
}

#pragma mark - Helpers -



#pragma mark - CBCentralManagerDelegate -

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.state == KRNBluetoothManagerStatePoweredOn) {
        if (_scanAndConnect) {
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceUUIDString]] options:nil];
            _scanAndConnect = NO;
        }
    }
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
    
    self.connectionState = KRNConnectionStateDisconnected;

    if (error) {  // if disconnect not by user - try reconnect
        if (KRNBluetoothManagerDebugMode) {
            NSLog(@"Disconnect peripheral. Trying reconnect");
        }
        [self.centralManager connectPeripheral:_connectedPeripheral options:nil];
    } else {
       
        if (self.disconnectCompletion) {
            self.disconnectCompletion();
        }
        if (_disconnectByUserCompletion) {
            _disconnectByUserCompletion(self.connectionState);
        }
    }
    
}

#pragma mark - CBPeripheralDelegate -

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (!error && peripheral.services) {
        if (peripheral.services.count > 0) {
            [peripheral discoverCharacteristics:nil forService:peripheral.services.firstObject];
        }
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
                    //call connection completion after discovering all characteristics
                    if (_connectionCompletion) {
                        _connectionCompletion(self.connectionState);
                    }
                    [self sendPacket:[KRNBluetoothMessages connectionMessage]];
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

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
    if (_readRSSIClosure) {
        _readRSSIClosure(RSSI.integerValue, error); //call closure
    }
}


@end

