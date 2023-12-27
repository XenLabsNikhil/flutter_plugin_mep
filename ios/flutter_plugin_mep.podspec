#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_plugin_mep.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_plugin_mep'
  s.version          = '8.16.12'
  s.summary          = 'flutter plugin for moxo sdk'
  s.description      = <<-DESC
  flutter plugin for moxo sdk
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Moxo' => 'john.hu@moxo.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/*'
  s.public_header_files = 'Classes/*.h'
  s.swift_version = '5.0'
  s.dependency 'Flutter'
  s.dependency 'MEPSDK', '~> 8.16.12'
  s.static_framework = true
  s.platform = :ios, '13.0'
  s.libraries = "c++", "xml2.2","z"
  # Flutter.framework does not contain a i386 slice.
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'OTHER_LDFLAGS' => '-ObjC' }
end
