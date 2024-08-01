
Pod::Spec.new do |spec|
  spec.name         = "LiGPlayerKit"
  spec.version      = "1.7.30"
  spec.summary      = "A short description of LiGPlayerKit."
  spec.description  = "AR solution for iOS mobile device"
  spec.homepage     = "https://gitlab.com/lig-corp/rd/ios/ios-player-sdk"
  spec.license      = "Commercial"
  spec.author             = { "Steven Lin" => "steven.lin@lig.com.tw", "Plain Wu":"plain.wu@lig.com.tw" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://gitlab.com/lig-corp/ios-player-sdk-sample.git", :branch => "main", :tag => "#{spec.version.to_s}"}
  spec.ios.deployment_target  = '15.0'
  spec.source_files  = "ios-player-sdk-sample/Framework/LiGPlayerKit.xcframework/ios-arm64/LiGPlayerKit.framework/Headers/*.h"
  vendored_frameworks = "LiGPlayerKit.xcframework"

end
