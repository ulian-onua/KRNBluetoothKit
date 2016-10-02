//
//  ViewController.m
//  KRNBluetoothManagerTests
//
//  Created by ulian_onua on 01.10.16.
//  Copyright © 2016 ulian_onua. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothManagerViewController.h"

@interface ViewController ()

@property (assign, nonatomic) KRNBluetoothManagerMode mode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)moveToCentral:(id)sender {
    _mode = KRNCentralMode;
    [self performSegueWithIdentifier:@"toBluetoothManagerVC" sender:self];
}

- (IBAction)moveToPeripheral:(id)sender {
    _mode = KRNPeripheralMode;
    [self performSegueWithIdentifier:@"toBluetoothManagerVC" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toBluetoothManagerVC"]) {
        BluetoothManagerViewController *destVC = segue.destinationViewController;
        destVC.managerMode = self.mode;
    }
}


@end
