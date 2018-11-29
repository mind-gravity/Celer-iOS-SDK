platform :ios, '9.0'

target 'MultiplayerGameSample' do
  use_frameworks!

  pod 'Celer', :git => 'https://github.com/celer-network/CelerPod.git', :tag => '0.0.1'
end

target 'OffchainPaymentSample' do
  use_frameworks!
  
  pod 'Celer', :git => 'https://github.com/celer-network/CelerPod.git', :tag => '0.0.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
