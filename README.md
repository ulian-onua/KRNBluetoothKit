KRNBluetoothKit
===============

KRNBluetoothKit is a simple library for fast interaction between two iOS bluetooth devices using Bluetooth 4.0 LE.
It will take you a few minutes to set up this lib and use it without no need of deep knowledge of Core Bluetooth Framework.
Specifications of Bluetooth 4.0 LE base on relationship between central and peripheral devices. Peripheral devices advertise some data and allow to be connected to. In contrast, central devices scan for advertising peripherals and are able to connect them.
KRNBluetoothKit requires that one iOS-device will play role of central device whereas other iOS-device will play role of peripheral device. Every of those devices after connection are able to send NSData messages to another device.


## Installation
####CocoaPods

(Unfamiliar with [CocoaPods](http://cocoapods.org/) yet? It's a dependency management tool for iOS and Mac, check it out!)

Just add `pod 'KRNBluetoothKit'` to your Podfile and run 'pod install' in Terminal from your project folder.

## How to set up and use

##### 1. Create UUID Strings for service and characteristics and use these strings for managers initialization.
You must have or create UUIDs strings for service, write and read characteristics. These values must be passed during initialization or central or peripheral manager to method  initWithServiceUUID:writeCharacteristicUUID:andReadCharacteristicUUID .

To create UUID codes open terminal in your macOS and use command «uuidgen» to generate new, with very possibility unique, UUID code. If you still don’t have UUID codes just generate three new codes and use it for managers initialization.
You must use the same UUID codes for both central and peripheral managers.

```objc
static NSString* const kServiceUUID = @"BCA96A6D-9128-4B82-AAB1-426323F1A38B";
static NSString* const kWriteCharacteristicUUID = @"0ACAD532-C68A-4BF2-A7A0-7C4448BAECD1";
static NSString* const kReadCharacteristicUUID = @"7BFC528D-1857-4EFE-8C28-392A56176CCD";
…

//iOS device that will play role of peripheral manager
self.peripheralManager = [[KRNPeripheralManager alloc]initWithServiceUUID:kServiceUUID writeCharacteristicUUID:kWriteCharacteristicUUID andReadCharacteristicUUID:kReadCharacteristicUUID];

//iOS device that will play role of central manager
self.centralManager = [[KRNPeripheralManager alloc]initWithServiceUUID:kServiceUUID writeCharacteristicUUID:kWriteCharacteristicUUID andReadCharacteristicUUID:kReadCharacteristicUUID];

```
##### 2. Play the role of peripheral iOS device
If you want that central device will be able to connect to you peripheral device you should start advertising.
Before starting advertising you should set up the block that is handler for incoming message from central device.
```objc
self.bluetoothManager.getMessageCompletion = ^(NSData *message) {
NSLog(@"Incoming message = %@", message);
//write custom code here to handle and parse incoming message from central device
};
```
After that you start advertising with completion handler that called after remote central was connected:
```objc
[self.bluetoothManager startAdvertising:^(KRNConnectionState state) {
    if (state == KRNConnectionStateConnected) {
     // remote central connected
     // you are able to send data                   
    }
}];
```
Аfter connection use sendPacket: method to send packets to central device:
```objc
[self.bluetoothManager sendPacket:somePacket];
```

##### 3. Play the role of central iOS device:

Setup of central device is straightforward.

Set up the block that is handler for incoming message from peripheral device (same as for peripheral in Step 2):

```objc
self.bluetoothManager.getMessageCompletion = ^(NSData *message) {
NSLog(@"Incoming message = %@", message);
//write custom code here to handle and parse incoming message from peripheral device
};
```

After creating and initialization the instance of KRNCentralManager, setting getMessageCompletion handler call next method to scan and connect to peripheral, that you set up in Step 2.
```objc
[self.bluetoothManager scanAndConnectToPeripheral:^(KRNConnectionState state) {
    if (state == KRNConnectionStateConnected) {
     // connected to remote peripheral
     // you are able to send data 
    }
}];
```
If KRNCentralManager discovers appropriate peripheral device it will automatically connect it. Completion will be called. 
You may also observe, using KVO, property connectionState of KRNCentralManager instance to handle changing of connection status (connected / not connected).

Use sendPacket: method to send packets to peripheral device:
```objc
[self.bluetoothManager sendPacket:somePacket];
```

## Requirements

* iOS 8.0 and above
* XCode 8+

## License

KRNBluetoothKit is released under the MIT license. See LICENSE for details.

## Contact

Any suggestion or question? Please create a Github issue or reach me out.

[LinkedIn](https://www.linkedin.com/in/julian-drapaylo)
