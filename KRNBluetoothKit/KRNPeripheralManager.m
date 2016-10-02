//
//  KRNPeripheralManager.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "KRNPeripheralManager.h"

@interface KRNPeripheralManager() <CBPeripheralManagerDelegate>
{
    dispatch_queue_t _bluetoothManagerQueue;  //queue for bluetooth
    CBMutableCharacteristic* _readCharacteristic;
    CBMutableCharacteristic* _writeCharacteristic;
}

@end

@implementation KRNPeripheralManager


- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID {
    self = [super initWithServiceUUID:serviceUUID writeCharacteristicUUID:writeCharUUID andReadCharacteristicUUID:readCharUUID];
    if (self) {
        _bluetoothManagerQueue = dispatch_queue_create("com.KRNPeripheralManager.queue", DISPATCH_QUEUE_SERIAL);
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:_bluetoothManagerQueue];
        _peripheralManager.delegate = self;
    }
    return self;
}

- (void)startAdvertising {
    CBMutableService *service = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:self.serviceUUIDString] primary:YES];
    _readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:self.readCharacteristicUUIDString] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    _writeCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:self.writeCharacteristicUUIDString] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    service.characteristics = @[_readCharacteristic, _writeCharacteristic];
    
    [self.peripheralManager addService:service];
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey :@[service.UUID]}];
}

- (void)sendPacket:(NSData *)packet {
    if (_readCharacteristic) {
        [self.peripheralManager updateValue:packet forCharacteristic:_readCharacteristic onSubscribedCentrals:nil];
    }
}


- (KRNBluetoothManagerState) state {
    return [self getBluetoothManagerState:self.peripheralManager.state];
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

#pragma mark - CBPeripheralManagerDelegate -

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (self.updateStateCompletion) {
        self.updateStateCompletion(self.state);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error {
    if (!error) {
        NSLog(@"Did add service");
    } else {
        NSLog(@"Error adding service = %@", error.localizedDescription);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    if (!error) {
        NSLog(@"Did start advertising");
    } else {
        NSLog(@"Error advertising = %@", error.localizedDescription);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests.firstObject;
    if (request) {
        if ([request.characteristic.UUID.UUIDString isEqualToString:self.writeCharacteristicUUIDString]) {
            if (request.value) {
                if (self.getMessageCompletion) {
                    self.getMessageCompletion(request.value);
                }
            }
        }
    }
}

@end


