#
# Be sure to run `pod spec lint HTTumblrAPIClient.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "HTTumblrAPIClient"
  s.version      = "0.0.1"
  s.summary      = "Additions to TMTumblrSDK that includes many private methods."
  s.homepage     = "https://github.com/HT154/HTTumblrAPIClient"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author       = { "HT154" => "ht154@ht154.com" }
  s.source       = { :git => "https://github.com/HT154/HTTumblrAPIClient.git", :tag => "0.0.1" }
  s.source_files = '*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.dependency 'TMTumblrSDK', '~> 1.0.2'
end
