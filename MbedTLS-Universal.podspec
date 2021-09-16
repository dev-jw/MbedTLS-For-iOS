#
# Be sure to run `pod lib lint TuyaSmartMbedTLS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MbedTLS-Universal'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MbedTLS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "MbedTLS is an SSL/TLS and Crypto toolkit. gone in iOS, this spec gives your project non-deprecated MbedTLS support. Supports iOS including Simulator (armv7,armv7s,arm64,x86_64)."

  s.homepage         = 'https://github.com/hjw/MbedTLS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hjw' => 'Estenian.huang@tuya.com' }
  s.source           = { :git => 'https://github.com/hjw/MbedTLS.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.cocoapods_version = '>= 1.9'
  s.ios.deployment_target = '9.0'
  s.vendored_frameworks = 'Frameworks/MbedTLS.xcframework'
end
