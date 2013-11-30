//
//  YCViewController.m
//  BlueBeacon
//
//  Created by yy on 13-11-1.
//  Copyright (c) 2013年 yy. All rights reserved.
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
            if (![_availableDevices containsObject:p] && [p.name isEqualToString:kBeaconName]) {
                [_availableDevices addObject:p];
            }
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
    [_bleService.peripheralConnectedSignal subscribeNext:^(CBPeripheral* device) {
        NSLog(@"Connected to %@", device.name);
        if (_deviceController != nil) {
            device.delegate = _deviceController;
        }
        [device discoverServices:nil];
    }];
    
    [self startScan];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(startScan)
                  forControlEvents:UIControlEventValueChanged];

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _deviceController = (YCDeviceViewController *)segue.destinationViewController;
    BluetoothLEPeripheral *device = [[BluetoothLEPeripheral alloc] initWithPeripheral:sender];
    _deviceController.device = device;
    [_bleService connectDevice:sender];
}

#pragma mark - IBAction


#pragma mark - Custom

- (void)startScan {
    [_availableDevices removeAllObjects];
    [_bleService scanForAvailableDevices];
}

@end
