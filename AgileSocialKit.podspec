#
# Be sure to run `pod lib lint AgileSocialKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgileSocialKit'
  s.version          = '0.1.0'
  s.summary          = 'Fantastic Agile Social Kit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Third party share, auth, pay kit without static libraries.
  Just use it.
                       DESC

  s.homepage         = 'http://git.2dfire-inc.com/2ye-iOS/AgileSocialKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '紫芋' => 'ziyu@fanhaoyue.com' }
  s.source           = { :git => 'http://git.2dfire-inc.com/2ye-iOS/AgileSocialKit', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.public_header_files = 'AgileSocialKit/Classes/*.h'
  s.source_files = 'AgileSocialKit/Classes/*'
  
  s.subspec 'Base' do |base|
      base.source_files = 'AgileSocialKit/Classes/Base/**/*'
      base.public_header_files = 'AgileSocialKit/Classes/Base/**/*.h'
      base.resource_bundles = {
          'Localize' => ['AgileSocialKit/Assets/*.lproj/*']
      }
  end
  
  s.subspec 'Share' do |share|
      share.source_files = 'AgileSocialKit/Classes/Share/**/*'
      share.public_header_files = 'AgileSocialKit/Classes/Share/**/*.h'
      share.dependency 'AgileSocialKit/Base'
      share.resource_bundles = {
          'Share' => ['AgileSocialKit/Assets/Share/*.png']
      }
  end
  
  s.subspec 'OAuth' do |oauth|
      oauth.source_files = 'AgileSocialKit/Classes/OAuth/**/*'
      oauth.public_header_files = 'AgileSocialKit/Classes/OAuth/**/*.h'
      oauth.dependency 'AgileSocialKit/Base'
  end
  
  s.subspec 'Pay' do |pay|
      pay.source_files = 'AgileSocialKit/Classes/Pay/**/*'
      pay.public_header_files = 'AgileSocialKit/Classes/Pay/**/*.h'
      pay.dependency 'AgileSocialKit/Base'
  end
end
