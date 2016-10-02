//
//  BluetoothManagerViewController.h
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    KRNPeripheralMode = 0,
    KRNCentralMode
} KRNBluetoothManagerMode;

@interface BluetoothManagerViewController : UIViewController

@property (assign, nonatomic) KRNBluetoothManagerMode managerMode;


@end
