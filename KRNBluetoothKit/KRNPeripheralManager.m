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
    
    CBMutableService* _service; //service that manager will advertise
    CBMutableCharacteristic* _readCharacteristic;
    CBMutableCharacteristic* _writeCharacteristic;
    
    BOOL _startAdvertising; // if true - start advertising in did change state
    KRNConnectionStateClosure _connectionCompletion;

}
@property (assign, nonatomic) KRNConnectionState connectionState;
@end

@implementation KRNPeripheralManager
@synthesize connectionState = _connectionState;


- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID {
    self = [super initWithServiceUUID:serviceUUID writeCharacteristicUUID:writeCharUUID andReadCharacteristicUUID:readCharUUID];
    if (self) {
        _bluetoothManagerQueue = dispatch_queue_create("com.KRNPeripheralManager.queue", DISPATCH_QUEUE_SERIAL);
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:_bluetoothManagerQueue];
        _advertising = NO;
    }
    return self;
}
- (void)startAdvertising:(KRNConnectionStateClosure)completion {
    _connectionCompletion = completion;
    if (self.state == KRNBluetoothManagerStatePoweredOn) {
        [self performStartAdvertisingOperations];
    } else {
        _startAdvertising = YES;
    }
}

- (void)performStartAdvertisingOperations {
    if (self.state == KRNBluetoothManagerStatePoweredOn) {
        _service = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:self.serviceUUIDString] primary:YES];
        _readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:self.readCharacteristicUUIDString] properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        _writeCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:self.writeCharacteristicUUIDString] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
        _service.characteristics = @[_readCharacteristic, _writeCharacteristic];
        
        [self.peripheralManager addService:_service];
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[_service.UUID]}];
        
    }
}
    
- (void)stopAdvertising {
    [self.peripheralManager stopAdvertising];
    _advertising = NO;
}


- (void)sendPacket:(NSData *)packet {
    if (_readCharacteristic) {
        [self.peripheralManager updateValue:packet forCharacteristic:_readCharacteristic onSubscribedCentrals:nil];
    }
}


- (KRNBluetoothManagerState) state {
    return [self convertToBluetoothManagerState:self.peripheralManager.state];
}


#pragma mark - CBPeripheralManagerDelegate -

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (self.state == KRNBluetoothManagerStatePoweredOn) {
        if (_startAdvertising) {
            [self performStartAdvertisingOperations];
            _startAdvertising = NO;
        }
    }
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
        _advertising = YES;
    } else {
        NSLog(@"Error advertising = %@", error.localizedDescription);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests.firstObject;
    if (request) {
        if ([request.characteristic.UUID.UUIDString isEqualToString:self.writeCharacteristicUUIDString]) {
            if (request.value) {
                if ([KRNBluetoothMessages checkIfConnectionMessage:request.value]) {
                    self.connectionState = KRNConnectionStateConnected;
                    if (_connectionCompletion) {
                        _connectionCompletion(self.connectionState);
                    }
                } else {
                    if (self.getMessageCompletion) {
                        self.getMessageCompletion(request.value);
                    }
                }
            }
        }
    }
}

@end


