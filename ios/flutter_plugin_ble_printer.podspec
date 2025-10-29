#
#  flutter_plugin_ble_printer.podspec
#
Pod::Spec.new do |s|
  # —— 基本信息 ——
  s.name             = 'flutter_plugin_ble_printer'
  s.version          = '0.0.1'
  s.summary          = 'Bluetooth BLE printer Flutter plugin.'
  s.description      = <<-DESC
A Flutter plugin for Bluetooth BLE thermal printer.
                       DESC
  s.homepage         = 'https://example.com'   # 换成你的仓库或主页
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # —— 源码 ——
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files= 'Classes/**/*.h'

  # —— 第三方 framework ——
  s.vendored_frameworks = 'MyFramework/PrinterSDK.xcframework'

  # —— 依赖 ——
  s.dependency 'Flutter'

  # —— 平台 & 编译 ——
  s.platform = :ios, '11.0'   # 2025 年建议最低 iOS 11
  # 1. 让 Xcode 知道去哪里找头文件
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # 新增两行
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_XCFRAMEWORKS_BUILD_DIR}/PrinterSDK"',
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_XCFRAMEWORKS_BUILD_DIR}/PrinterSDK/PrinterSDK.framework/Headers"'
  }

  # 2. 把需要暴露的头文件显式列出来（module map 需要）
  s.public_header_files = [
    'Classes/**/*.h',
    'MyFramework/PrinterSDK.xcframework/ios-arm64/PrinterSDK.framework/Headers/*.h'
  ]

  # —— 资源（可选）——
  # s.resource_bundles = {'flutter_plugin_ble_printer' => ['Assets/**/*']}
end