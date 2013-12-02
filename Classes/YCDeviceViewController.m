//
//  YCDeviceViewController.m
//  BlueBeacon
//
//  Created by yy on 13-11-19.
//  Copyright (c) 2013年 yy. All rights reserved.
//

#import "YCDeviceViewController.h"
#import <ReactiveCoreBluetooth/ReactiveCoreBluetooth.h>
#import "YCDefine.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface YCDeviceViewController ()

@property (nonatomic, strong) CBService *beaconService;
@property (nonatomic, strong) CBCharacteristic *proximityChar;
@property (nonatomic, strong) CBCharacteristic *majorChar;
@property (nonatomic, strong) CBCharacteristic *minorChar;
@property (nonatomic, strong) CBCharacteristic *measuredPowerChar;
@property (nonatomic, strong) CBCharacteristic *txPowerChar;
@property (nonatomic, strong) CBCharacteristic *passcodeChar;

@end

@implementation YCDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [[_device.discoveredServicesSignal
      filter:^(CBPeripheral *p) {
          CBUUID *serviceUUID = [CBUUID UUIDWithString:kBeaconServiceUUID];
          for (CBService *s in p.services) {
              if ([serviceUUID isEqual:s.UUID]) {
                  _beaconService = s;
                  return YES;
              }
          }
          return NO;
      }]
     subscribeNext:^(CBPeripheral *p) {
//         NSArray *chars = @[[CBUUID UUIDWithString:kBeaconProximityUUID],
//                            [CBUUID UUIDWithString:kBeaconMajorUUID],
//                            [CBUUID UUIDWithString:kBeaconMinorUUID],
//                            [CBUUID UUIDWithString:kBeaconMeasuredPowerUUID],
//                            [CBUUID UUIDWithString:kBeaconPasscodeUUID]];
         NSArray *chars = nil;
         [p discoverCharacteristics:chars forService:_beaconService];
         NSLog(@"Discovering chars");
     }];
    
    CBUUID *proximityUUID = [CBUUID UUIDWithString:kBeaconProximityUUID];
    CBUUID *majorUUID = [CBUUID UUIDWithString:kBeaconMajorUUID];
    CBUUID *minorUUID = [CBUUID UUIDWithString:kBeaconMinorUUID];
    CBUUID *measuredPowerUUID = [CBUUID UUIDWithString:kBeaconMeasuredPowerUUID];
    CBUUID *txPowerUUID = [CBUUID UUIDWithString:kBeaconTxPowerUUID];
    CBUUID *passcodeUUID = [CBUUID UUIDWithString:kBeaconPasscodeUUID];
    
    [_device.discoveredCharacteristicsSignal subscribeNext:^(CBService *service) {
        for (CBCharacteristic *i in service.characteristics) {
            if ([i.UUID isEqual:proximityUUID]) {
                _proximityChar = i;
            } else if ([i.UUID isEqual:majorUUID]) {
                _majorChar = i;
            } else if ([i.UUID isEqual:minorUUID]) {
                _minorChar = i;
            } else if ([i.UUID isEqual:measuredPowerUUID]) {
                _measuredPowerChar = i;
            } else if ([i.UUID isEqual:txPowerUUID]) {
                _txPowerChar = i;
            } else if ([i.UUID isEqual:passcodeUUID]) {
                _passcodeChar = i;
            }
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
