#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint arculus_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'arculus_sdk'
  s.version          = '1.0.0'
  s.summary          = 'Arculus SDK Flutter plugin.'
  s.description      = <<-DESC
Arculus SDK plugin for integration into flutter projects
                       DESC
  s.homepage         = 'https://github.com/santium/arculus-sdk-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Santium' => 'contact@santium.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  # Add the Arculus CSDK XCFramework
  s.vendored_frameworks = 'CSDK.xcframework'
  s.source_files = 'Classes/**/*'
end 