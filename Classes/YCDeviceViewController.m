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

@interface YCDeviceViewController ()

@property (nonatomic, strong) CBService *beaconService;

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
         NSArray *chars = @[[CBUUID UUIDWithString:kBeaconProximityUUID],
                            [CBUUID UUIDWithString:kBeaconMajorUUID],
                            [CBUUID UUIDWithString:kBeaconMinorUUID],
                            [CBUUID UUIDWithString:kBeaconMeasuredPowerUUID],
                            [CBUUID UUIDWithString:kBeaconProximityUUID]];
         [p discoverCharacteristics:chars forService:_beaconService];
     }];
    
    [[_device.discoveredCharacteristicsSignal
     filter:^BOOL(CBService *service) {
         NSLog(@"service %@", service);
         for (CBCharacteristic *i in service.characteristics) {
//             NSLog(@"i %@", i);
         }

         return YES;
     }]
    subscribeNext:^(id x) {
        NSLog(@"safadfa %@", x);
    }];

}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
        // Create a new instance of the appropriate class, insert it into the array, and add a n    ew row to the table view
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

@end
