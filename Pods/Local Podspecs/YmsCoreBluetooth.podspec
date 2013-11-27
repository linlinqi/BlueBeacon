Pod::Spec.new do |s|
  s.name                  = "YmsCoreBluetooth"
  s.version               = "1.06"
  s.summary               = "A block-based framework for building Bluetooth 4.0 Low Energy"
  s.homepage              = "https://github.com/MattCBowman/ReactiveCoreBluetooth"
  s.license               = { :type => 'Apache', :file => 'LICENSE' }
  s.author                = {
                                'Charles Y. Choi' => 'charles.choi@yummymelon.com',
                            }
  s.source                = { :git => 'https://github.com/volca/YmsCoreBluetooth.git', :tag => '1.06' }
  s.platform              = :ios
  s.ios.deployment_target = '7.0'
  s.source_files          = 'YMSCoreBluetooth.h', 'YmsCoreBluetooth/*.{h,m}'
  s.framework             = 'CoreBluetooth'
  s.requires_arc          = true
end
