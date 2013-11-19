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

@interface YCViewController ()

@property (nonatomic, strong) BluetoothLEService *bleService;
@property (nonatomic, strong) NSMutableArray *availableDevices;

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _availableDevices = [NSMutableArray array];
    _bleService = [[BluetoothLEService alloc] init];
    _bleService.connectOnDiscovery = NO;
    
    [_bleService.availableDevicesSignal subscribeNext:^(NSArray *devices) {
        for (CBPeripheral *p in devices) {
            if (![_availableDevices containsObject:p] && [p.name isEqualToString:kBeaconName]) {
                [_availableDevices addObject:p];
                [self.tableView reloadData];
            }
        }
        
        [self.tableView reloadData];
    }];
    
    [_bleService scanForAvailableDevices];


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
    // Configure the cell...
    
    return cell;
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - IBAction

- (IBAction)refreshTapped:(id)sender {
}

@end
