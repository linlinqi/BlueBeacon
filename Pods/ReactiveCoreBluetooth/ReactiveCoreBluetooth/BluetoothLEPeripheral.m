
#import "BluetoothLEPeripheral.h"

@interface BluetoothLEPeripheral()

@end

@implementation BluetoothLEPeripheral

- (id)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _device = peripheral;
    }
    return self;
}

- (CBPeripheralState)state {
    return _device.state;
}

@end
