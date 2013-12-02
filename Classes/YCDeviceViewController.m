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

typedef enum {
    BBTxPower0DBM = 0,
    BBTxPower4DBM = 1,
    BBTxPowerMinus6DBM = 2,
    BBTxPowerMinus23DBM = 3
} BBTxPower;

#define kTxPowerCellIndex 0

@interface YCDeviceViewController ()

@property (nonatomic, strong) CBService *beaconService;
@property (nonatomic, strong) CBCharacteristic *proximityChar;
@property (nonatomic, strong) CBCharacteristic *majorChar;
@property (nonatomic, strong) CBCharacteristic *minorChar;
@property (nonatomic, strong) CBCharacteristic *measuredPowerChar;
@property (nonatomic, strong) CBCharacteristic *txPowerChar;
@property (nonatomic, strong) CBCharacteristic *passcodeChar;

@property (nonatomic, strong) NSArray *txPowerIndex;

@property (nonatomic, copy) NSString *deviceService;
@property (nonatomic) UInt16 deviceMajor;
@property (nonatomic) UInt16 deviceMinor;
@property (nonatomic) UInt8 devicePower;
@property (nonatomic) UInt8 deviceTxPower;

@end

@implementation YCDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    _txPowerIndex = @[@"0dBm", @"4dBm", @"-6dBm", @"-23dBm"];
    
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
         NSArray *chars = nil;
         [p discoverCharacteristics:chars forService:_beaconService];
         NSLog(@"Discovering chars");
     }];
    
    [_device.discoveredCharacteristicsSignal subscribeNext:^(CBService *service) {
        for (CBCharacteristic *i in service.characteristics) {
            [_device.device readValueForCharacteristic:i];
        }
    }];
    
    [_device.updatedValueSignal subscribeNext:^(CBCharacteristic *i) {
        if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconProximityUUID]]) {
            _proximityChar = i;
            NSString *temp = [self getHexString:i.value];
            
            NSRange r1 = NSMakeRange(8, 4);
            NSRange r2 = NSMakeRange(12, 4);
            NSRange r3 = NSMakeRange(16, 4);
            
            _deviceService = [temp substringToIndex:8];
            _deviceService = [_deviceService stringByAppendingString:@"-"];
            _deviceService = [_deviceService stringByAppendingString:[temp substringWithRange:r1]];
            _deviceService = [_deviceService stringByAppendingString:@"-"];
            _deviceService = [_deviceService stringByAppendingString:[temp substringWithRange:r2]];
            _deviceService = [_deviceService stringByAppendingString:@"-"];
            _deviceService = [_deviceService stringByAppendingString:[temp substringWithRange:r3]];
            _deviceService = [_deviceService stringByAppendingString:@"-"];
            _deviceService = [_deviceService stringByAppendingString:[temp substringFromIndex:20]];
            _deviceService = [_deviceService uppercaseString];
            
            [self.serviceText setText:_deviceService];
            
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconMajorUUID]]) {
            _majorChar = i;
            
            unsigned char data[2];
            [i.value getBytes:data length:2];
            _deviceMajor = data[0] << 8 | data[1];
            
            [self.majorText setText:[NSString stringWithFormat:@"%d", _deviceMajor]];
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconMinorUUID]]) {
            _minorChar = i;
            
            unsigned char data[2];
            [i.value getBytes:data length:2];
            _deviceMinor = data[0] << 8 | data[1];
            
            [self.minorText setText:[NSString stringWithFormat:@"%d", _deviceMajor]];
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconMeasuredPowerUUID]]) {
            _measuredPowerChar = i;
            
            unsigned char data[1];
            [i.value getBytes:data length:1];
            
            _devicePower = data[0];
            
            [self.powerText setText:[NSString stringWithFormat:@"%d", _devicePower - 256]];
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconTxPowerUUID]]) {
            _txPowerChar = i;
            
            unsigned char data[1];
            [i.value getBytes:data length:1];
            _deviceTxPower = data[0];
            
            NSString *power = _txPowerIndex[_deviceTxPower];
            _txPowerLabel.text = [NSString stringWithFormat:@"Tx Power: %@", power];
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconPasscodeUUID]]) {
            _passcodeChar = i;
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kTxPowerCellIndex) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView endEditing:YES];
        
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Tx Power"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil, nil];
        for (NSString *i in _txPowerIndex) {
            [action addButtonWithTitle:i];
        }
        [action showInView:self.tableView];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    _deviceTxPower = buttonIndex - 1;
}

#pragma mark - Custom

- (NSString*)getHexString:(NSData*)data {
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength * 2];
    const unsigned char *dataBytes = [data bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [string appendFormat:@"%02x", dataBytes[idx]];
    }
    return string;
}

- (NSString *)convertCBUUIDToString:(CBUUID*)uuid {
    NSData *data = uuid.data;
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++) {
        switch (currentByteIndex) {
            case 3:
            case 5:
            case 7:
            case 9: [outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default: [outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    NSString *result = [outputString uppercaseString];
    
    return result;
}

#pragma mark - IBAction

- (IBAction)saveTapped:(id)sender {

}

@end
