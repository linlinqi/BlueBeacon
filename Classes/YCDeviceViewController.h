//
//  YCDeviceViewController.h
//  BlueBeacon
//
//  Created by yy on 13-11-19.
//  Copyright (c) 2013年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BluetoothLEPeripheral;
@class JVFloatLabeledTextField;

@interface YCDeviceViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) BluetoothLEPeripheral *device;

@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *serviceText;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *majorText;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *minorText;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *powerText;
@property (strong, nonatomic) IBOutlet UILabel *txPowerLabel;
@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *passcodeText;

- (IBAction)saveTapped:(id)sender;

@end
