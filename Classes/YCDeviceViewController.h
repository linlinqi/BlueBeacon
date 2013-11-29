//
//  YCDeviceViewController.h
//  BlueBeacon
//
//  Created by yy on 13-11-19.
//  Copyright (c) 2013年 yy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CBPeripheral;

@interface YCDeviceViewController : UITableViewController <CBPeripheralDelegate>

@property (nonatomic, weak) CBPeripheral *device;

@end
