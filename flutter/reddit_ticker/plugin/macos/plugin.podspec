#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plugin'
  s.version          = '0.0.1'
  s.summary          = 'Rust bridge.'
  s.description      = <<-DESC
A flutter Rust bridge project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.public_header_files = 'Classes**/*.h'
  s.static_framework = true
  s.vendored_libraries = '**/*.a'
end
