#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint adit_lin_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'adit_lin_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  # s.source           = { :git => 'https://gitlab.linphone.org/BC/public/podspec.git' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'linphone-sdk' , '5.2.110-pre.2+20cb52c5'
  # s.framework = 'linphone-sdk'
  s.platform = :ios, '11.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
