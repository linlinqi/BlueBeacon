//
//  YCDeviceViewController.h
//  BlueBeacon
//
//  Created by yy on 13-11-19.
//  Copyright (c) 2013年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BluetoothLEService;
@class CBPeripheral;

@interface YCDeviceViewController : UITableViewController

@property (nonatomic, weak) CBPeripheral *device;
@property (nonatomic, weak) BluetoothLEService *bleService;

@end
