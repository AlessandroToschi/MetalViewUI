Pod::Spec.new do |s|
  s.name             = 'MetalViewUI'
  s.version          = '1.0.0'
  s.summary          = 'SwiftUI view wrapper for MTKView.'
  s.homepage         = 'https://github.com/AlessandroToschi/MetalViewUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Alessandro Toschi' => 'ialessandrotoschi@gmail.com' }
  s.source           = { :git => 'https://github.com/AlessandroToschi/MetalViewUI.git' }
  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target  = '10.15'
  s.swift_version = '5.0'
  s.source_files = 'Sources/MetalViewUI/**/*'
end