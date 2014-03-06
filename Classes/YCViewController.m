//
//  YCViewController.m
//  BlueBeacon
//
//  Created by Linlinqi on 13-11-1.
//  Copyright (c) 2013年 Linlinqi Studio. All rights reserved.
//

#import "YCViewController.h"
#import <ReactiveCoreBluetooth/ReactiveCoreBluetooth.h>
#import "YCDefine.h"
#import "YCDeviceViewController.h"

@interface YCViewController ()

@property (nonatomic, strong) BluetoothLEService *bleService;
@property (nonatomic, strong) NSMutableArray *availableDevices;

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.availableDevices = [NSMutableArray array];
    _bleService = [[BluetoothLEService alloc] init];
    _bleService.connectOnDiscovery = NO;
    
    [_bleService.availableDevicesSignal subscribeNext:^(NSArray *devices) {
        for (CBPeripheral *p in devices) {
            if (![_availableDevices containsObject:p]) {
                [_availableDevices addObject:p];
            }
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
    [_bleService.peripheralConnectedSignal subscribeNext:^(CBPeripheral *device) {
        NSLog(@"Connected to %@", device.name);
        [device discoverServices:nil];
    }];
    
    [_bleService.peripheralDisconnectedSignal subscribeNext:^(CBPeripheral *device) {
        [_deviceController.navigationController popViewControllerAnimated:YES];
    }];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(startScan)
                  forControlEvents:UIControlEventValueChanged];

}

- (void)viewDidAppear:(BOOL)animated {
    [self startScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_availableDevices count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"deviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    if (cell) {
        CBPeripheral *p = _availableDevices[indexPath.row];
        cell.textLabel.text = p.name;
        cell.detailTextLabel.text = [p.identifier UUIDString];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *device = _availableDevices[indexPath.row];
    [self performSegueWithIdentifier:@"deviceSegue" sender:device];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _deviceController = (YCDeviceViewController *)segue.destinationViewController;
    BluetoothLEPeripheral *device = [[BluetoothLEPeripheral alloc] initWithPeripheral:sender];
    _deviceController.device = device;
    _deviceController.bleService = _bleService;
    [_bleService connectDevice:sender];
}

#pragma mark - IBAction


#pragma mark - Custom

- (void)startScan {
    [_availableDevices removeAllObjects];
    [self.tableView reloadData];
    [_bleService scanForAvailableDevices];
}

@end
