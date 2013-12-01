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
