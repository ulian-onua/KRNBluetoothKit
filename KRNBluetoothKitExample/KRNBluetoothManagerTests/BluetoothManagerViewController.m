//
//  BluetoothManagerViewController.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

@import CoreBluetooth;

#import "KRNCentralManager.h"
#import "KRNPeripheralManager.h"

#import "BluetoothManagerViewController.h"


static NSString* const kServiceUUID = @"BCA96A6D-9128-4B82-AAB1-426323F1A38B";
static NSString* const kWriteCharacteristicUUID = @"0ACAD532-C68A-4BF2-A7A0-7C4448BAECD1";
static NSString* const kReadCharacteristicUUID = @"7BFC528D-1857-4EFE-8C28-392A56176CCD";


@interface BluetoothManagerViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *incomingMessageLabel;

@property (weak, nonatomic) IBOutlet UITextField *outgoingMessageTextField;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;


@property (strong, nonatomic) KRNAbstractBluetoothManager *bluetoothManager;

@end

@implementation BluetoothManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outgoingMessageTextField.delegate = self;
    
    
    // Do any additional setup after loading the view.
    if (self.managerMode == KRNPeripheralMode) {
        self.connectButton.hidden = YES;
        self.connectionStatusLabel.hidden = YES;
        self.bluetoothManager = [[KRNPeripheralManager alloc]initWithServiceUUID:kServiceUUID writeCharacteristicUUID:kWriteCharacteristicUUID andReadCharacteristicUUID:kReadCharacteristicUUID];
        
    } else {
        self.bluetoothManager = [[KRNCentralManager alloc] initWithServiceUUID:kServiceUUID writeCharacteristicUUID:kWriteCharacteristicUUID andReadCharacteristicUUID:kReadCharacteristicUUID];
;
        [self addObserver:self forKeyPath:@"self.bluetoothManager.connectionState" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    __weak typeof(self) weakSelf = self;
    
    _bluetoothManager.getMessageCompletion = ^(NSData *message) {
      dispatch_async(dispatch_get_main_queue(), ^{
          NSString *strFromData = [[NSString alloc]initWithData:message encoding:NSUTF8StringEncoding];
          weakSelf.incomingMessageLabel.text = strFromData;
          
          NSLog(@"Incoming message = %@", message);
      });
    };
    
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.managerMode == KRNPeripheralMode) {
        [((KRNPeripheralManager *)self.bluetoothManager)startAdvertising];
    }
}
- (void) viewWillDisappear:(BOOL)animated {
    if (self.managerMode == KRNCentralMode) {
        [self removeObserver:self forKeyPath:@"self.bluetoothManager.connectionState"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.bluetoothManager.connectionState"]) {

            dispatch_async(dispatch_get_main_queue(), ^{
                _connectionStatusLabel.text = self.bluetoothManager.connectionState == KRNConnectionStateConnected ? @"CONNECTED" :@"NOT CONNECTED";
                
        });
        
    }
}

#pragma mark - Actions -

- (IBAction)connect:(id)sender {
    [((KRNCentralManager *)self.bluetoothManager) scanAndConnectToPeripheral];
}
- (IBAction)sendMessage:(id)sender {
    NSData *packet = [self.outgoingMessageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.bluetoothManager sendPacket:packet];
}


#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



@end
