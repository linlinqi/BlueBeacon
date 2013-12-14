//
//  YCDeviceViewController.m
//  BlueBeacon
//
//  Created by Linlinqi on 13-11-19.
//  Copyright (c) 2013年 Linlinqi Studio. All rights reserved.
//

#import "YCDeviceViewController.h"
#import <ReactiveCoreBluetooth/ReactiveCoreBluetooth.h>
#import "YCDefine.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import <MRProgress/MRProgress.h>

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
@property (nonatomic, strong) CBCharacteristic *advIntervalChar;

@property (nonatomic, strong) NSArray *txPowerIndex;

@property (nonatomic, copy) NSString *deviceService;
@property (nonatomic) UInt16 deviceMajor;
@property (nonatomic) UInt16 deviceMinor;
@property (nonatomic) UInt8 devicePower;
@property (nonatomic) UInt8 deviceTxPower;
@property (nonatomic) UInt8 deviceAdvInterval;

@end

@implementation YCDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    _txPowerIndex = @[@"0dBm", @"4dBm", @"-6dBm", @"-23dBm"];
    
    [MRProgressOverlayView showOverlayAddedTo:self.tableView animated:YES];
    
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
            if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconPasscodeUUID]]) {
                _passcodeChar = i;
                continue;
            }
            [_device.device readValueForCharacteristic:i];
        }
    }];
    
    [_device.updatedValueSignal subscribeNext:^(CBCharacteristic *i) {
        [MRProgressOverlayView dismissAllOverlaysForView:self.tableView animated:NO];
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
            
            [self.minorText setText:[NSString stringWithFormat:@"%d", _deviceMinor]];
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
            _txPowerLabel.text = [self getTxPowerWithIndex:_deviceTxPower];
        } else if ([i.UUID isEqual:[CBUUID UUIDWithString:kBeaconAdvIntervalUUID]]) {
            _advIntervalChar = i;
            
            unsigned char data[1];
            [i.value getBytes:data length:1];
            _deviceAdvInterval = data[0];
            _advIntervalText.text = [NSString stringWithFormat:@"%d", _deviceAdvInterval];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [_bleService disconnectDevice:_device.device];
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
    _txPowerLabel.text = [self getTxPowerWithIndex:_deviceTxPower];
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

- (NSString *)getTxPowerWithIndex:(NSInteger)index {
    NSString *power = _txPowerIndex[index];
    return [NSString stringWithFormat:@"Tx Power: %@", power];
}

#pragma mark - IBAction

- (IBAction)saveTapped:(id)sender {
    [self.tableView endEditing:YES];

    CBUUID *uuid;
    @try {
        uuid = [CBUUID UUIDWithString:[self.serviceText text]];
        [self.serviceText setText:[self convertCBUUIDToString:uuid]];
        
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"UUID string not valid!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    int major = [[self.majorText text] intValue];
    if ((major < 0) || (major > 65535)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Major number not valid!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.majorText setText:[NSString stringWithFormat:@"%d", major]];
    
    int minor = [[self.minorText text] intValue];
    if ((minor < 0) || (minor > 65535)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Minor number not valid!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.minorText setText:[NSString stringWithFormat:@"%d", minor]];
    
    int power = [[self.powerText text] intValue];
    if ((power > -1) || (power < -256)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Power not valid!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.powerText setText:[NSString stringWithFormat:@"%d", power]];

    int passcode = [[self.passcodeText text] intValue];
    
    if ([self.passcodeText.text length]) {
        if ((passcode < 1) || (passcode > 999999)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Passcode not valid!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        [self.passcodeText setText:[NSString stringWithFormat:@"%d", passcode]];
    }

    NSData *data = uuid.data;
    NSLog(@"uuid %@ char %@", uuid, _proximityChar);
    CBPeripheral *p = _device.device;
    [p writeValue:data
forCharacteristic:_proximityChar
             type:CBCharacteristicWriteWithResponse];
    
    uint8_t buf[] = {0x00, 0x00, 0x00};
    buf[1] =  (unsigned int) (major & 0xff);
    buf[0] =  (unsigned int) (major>>8 & 0xff);
    data = [[NSData alloc] initWithBytes:buf length:2];
    [p writeValue:data
forCharacteristic:_majorChar
             type:CBCharacteristicWriteWithResponse];
    
    buf[1] =  (unsigned int) (minor & 0xff);
    buf[0] =  (unsigned int) (minor>>8 & 0xff);
    data = [[NSData alloc] initWithBytes:buf length:2];
    [p writeValue:data
forCharacteristic:_minorChar
             type:CBCharacteristicWriteWithResponse];
    
    power = power + 256;
    buf[0] = power;
    data = [[NSData alloc] initWithBytes:buf length:1];
    [p writeValue:data
forCharacteristic:_measuredPowerChar
             type:CBCharacteristicWriteWithResponse];
    
    if (_txPowerChar) {
        buf[0] = _deviceTxPower;
        data = [[NSData alloc] initWithBytes:buf length:1];
        [p writeValue:data
    forCharacteristic:_txPowerChar
                 type:CBCharacteristicWriteWithResponse];
    }
    
    if (_passcodeChar) {
        NSLog(@"passChar %@", _passcodeChar.UUID);
        if (passcode > 0) {
            buf[0] = (unsigned int) (passcode & 0xff);
            buf[1] = (unsigned int) (passcode>>8 & 0xff);
            buf[2] = (unsigned int) (passcode>>16 & 0xff);
            data = [[NSData alloc] initWithBytes:buf length:3];
            NSLog(@"data %@", data);
            [p writeValue:data
        forCharacteristic:_passcodeChar
                     type:CBCharacteristicWriteWithResponse];
        }

    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Update successful, please restart BlueBeacon!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
