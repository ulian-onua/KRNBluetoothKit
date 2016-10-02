//
//  KRNAbstractBluetoothManager.h
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static BOOL KRNBluetoothManagerDebugMode = YES;

typedef enum : NSUInteger {
    KRNBluetoothManagerStateUnknown = 0,
    KRNBluetoothManagerStateResetting,
    KRNBluetoothManagerStateUnsupported,
    KRNBluetoothManagerStateUnauthorized,
    KRNBluetoothManagerStatePoweredOff,
    KRNBluetoothManagerStatePoweredOn
} KRNBluetoothManagerState;

typedef enum : NSUInteger {
    KRNConnectionStateConnected,
    KRNConnectionStateDisconnected
} KRNConnectionState;


typedef void(^KRNCompletionClosure)(void);
typedef void(^KRNUpdateStateClosure)(KRNBluetoothManagerState state);
typedef void(^KRNGetDataBlock)(NSData* data);




@interface KRNAbstractBluetoothManager : NSObject

@property (strong, nonatomic) KRNUpdateStateClosure updateStateCompletion; // update state block that called when closure state updated
@property (strong, nonatomic) KRNCompletionClosure disconnectCompletion; // block is called if remote was disconnected
@property (strong, nonatomic) KRNGetDataBlock getMessageCompletion;

@property (assign, nonatomic, readonly) KRNConnectionState connectionState;
@property (assign, nonatomic, readonly) KRNBluetoothManagerState state;

//characteristics UUID strings
@property (strong, nonatomic, readonly) NSString *serviceUUIDString;
@property (strong, nonatomic, readonly) NSString *writeCharacteristicUUIDString;
@property (strong, nonatomic, readonly) NSString *readCharacteristicUUIDString;



- (instancetype) initWithServiceUUID:(NSString *)serviceUUID writeCharacteristicUUID:(NSString *)writeCharUUID andReadCharacteristicUUID:(NSString *)readCharUUID;

- (void)sendPacket:(NSData *)packet; //send packet to remote bluetooth. Abstract Method that must be overriden by classes that inherit from this class


@end





